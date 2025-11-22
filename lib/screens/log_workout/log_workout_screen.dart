// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:winter_arc/models/exercise.dart';
import 'package:winter_arc/models/workout_log.dart';
import 'package:winter_arc/models/workout_set.dart';
import 'package:winter_arc/models/workout_template.dart';
import 'package:winter_arc/providers/user_provider.dart';
import 'package:winter_arc/providers/workout_provider.dart';
import 'package:winter_arc/services/custom_exercise_service.dart';
import 'package:winter_arc/services/template_service.dart';
import 'package:winter_arc/screens/templates/templates_screen.dart';
import 'package:winter_arc/widgets/exercise_selector.dart';
import 'package:winter_arc/widgets/add_set_dialog.dart';
import 'package:winter_arc/widgets/exercise_card.dart';

class LogWorkoutScreen extends StatefulWidget {
  const LogWorkoutScreen({super.key});

  @override
  State<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends State<LogWorkoutScreen> {
  final List<ExerciseLog> _exerciseLogs = [];
  final _notesController = TextEditingController();
  final _customExerciseService = CustomExerciseService();
  bool _isSaving = false;
  List<Exercise> _allExercises = Exercise.defaultExercises;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() {
    final userProvider = context.read<UserProvider>();
    _customExerciseService.getAllExercisesStream(userProvider.userId).listen((exercises) {
      if (mounted) {
        setState(() {
          _allExercises = exercises;
        });
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _addExercise() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: false, // Use local navigator
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ExerciseSelector(
        exercises: _allExercises,
        onExerciseSelected: (exercise) {
          setState(() {
            _exerciseLogs.add(ExerciseLog(
              exercise: exercise,
              sets: [],
            ));
          });
        },
        onCustomExerciseCreated: (exercise) async {
          final userProvider = context.read<UserProvider>();
          await _customExerciseService.addCustomExercise(userProvider.userId, exercise);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Custom exercise "${exercise.name}" created!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        onExerciseDeleted: (exercise) async {
          final userProvider = context.read<UserProvider>();
          await _customExerciseService.deleteCustomExercise(userProvider.userId, exercise.id);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Deleted "${exercise.name}"'),
              ),
            );
          }
        },
      ),
    );
  }

  void _addSetToExercise(int exerciseIndex) {
    showDialog(
      context: context,
      useRootNavigator: false, // Use local navigator
      builder: (context) => AddSetDialog(
        exercise: _exerciseLogs[exerciseIndex].exercise,
        onSetAdded: (set) {
          setState(() {
            _exerciseLogs[exerciseIndex].sets.add(set);
          });
        },
      ),
    );
  }

  void _removeExercise(int index) {
    setState(() {
      _exerciseLogs.removeAt(index);
    });
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      _exerciseLogs[exerciseIndex].sets.removeAt(setIndex);
    });
  }

  void _duplicateExercise(int index) {
    final originalLog = _exerciseLogs[index];
    setState(() {
      _exerciseLogs.insert(
        index + 1,
        ExerciseLog(
          exercise: originalLog.exercise,
          sets: originalLog.sets.map((s) => s.copyWith()).toList(),
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${originalLog.exercise.name} duplicated!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _duplicateSet(int exerciseIndex, int setIndex) {
    final originalSet = _exerciseLogs[exerciseIndex].sets[setIndex];
    setState(() {
      _exerciseLogs[exerciseIndex].sets.insert(
        setIndex + 1,
        originalSet.copyWith(),
      );
    });
  }

  Future<void> _loadFromTemplate() async {
    final template = await Navigator.of(context).push<WorkoutTemplate>(
      MaterialPageRoute(
        builder: (context) => TemplatesScreen(
          onTemplateSelected: (template) => template,
        ),
      ),
    );

    if (template != null && mounted) {
      setState(() {
        _exerciseLogs.clear();
        for (var exerciseTemplate in template.exercises) {
          _exerciseLogs.add(
            ExerciseLog(
              exercise: exerciseTemplate.exercise,
              sets: List.generate(
                exerciseTemplate.numberOfSets,
                (index) => WorkoutSet(reps: exerciseTemplate.targetReps),
              ),
            ),
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Loaded template: ${template.name}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _saveAsTemplate() async {
    if (_exerciseLogs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add exercises before saving as template'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final nameController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save as Template'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Template Name',
              hintText: 'e.g., Push Day, Leg Day',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && nameController.text.trim().isNotEmpty) {
      try {
        final userProvider = context.read<UserProvider>();
        final templateService = TemplateService();

        final template = WorkoutTemplate(
          id: const Uuid().v4(),
          userId: userProvider.userId,
          name: nameController.text.trim(),
          exercises: _exerciseLogs.map((log) {
            return ExerciseTemplate(
              exercise: log.exercise,
              numberOfSets: log.sets.length,
              targetReps: log.sets.isEmpty
                  ? 10
                  : (log.sets.fold<int>(0, (sum, set) => sum + set.reps) /
                          log.sets.length)
                      .round(),
            );
          }).toList(),
          createdAt: DateTime.now(),
        );

        await templateService.saveTemplate(template);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Template "${template.name}" saved!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving template: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    nameController.dispose();
  }

  Future<void> _saveWorkout() async {
    if (_exerciseLogs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one exercise to save workout'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userProvider = context.read<UserProvider>();
      final workoutProvider = context.read<WorkoutProvider>();

      final workout = WorkoutLog(
        id: const Uuid().v4(),
        userId: userProvider.userId,
        date: DateTime.now(),
        exercises: _exerciseLogs,
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );

      await workoutProvider.addWorkout(workout);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Workout saved! ${workout.totalReps} total reps 💪'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear the form
        setState(() {
          _exerciseLogs.clear();
          _notesController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving workout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout'),
        actions: [
          // Load from template button
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: _loadFromTemplate,
            tooltip: 'Load from template',
          ),
          // Save as template button
          if (_exerciseLogs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.bookmark_add_outlined),
              onPressed: _saveAsTemplate,
              tooltip: 'Save as template',
            ),
        ],
      ),
      body: SafeArea(
        child: _exerciseLogs.isEmpty
            ? _buildEmptyState()
            : _buildWorkoutForm(),
      ),
      floatingActionButton: _exerciseLogs.isEmpty
          ? FloatingActionButton.extended(
              onPressed: _addExercise,
              icon: const Icon(Icons.add),
              label: const Text('Add Exercise'),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha:0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No Exercises Added',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to start logging',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _loadFromTemplate,
            icon: const Icon(Icons.bookmark_outline),
            label: const Text('Or load from template'),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutForm() {
    final totalReps = _exerciseLogs.fold<int>(
      0,
      (sum, log) => sum + log.totalReps,
    );
    final totalSets = _exerciseLogs.fold<int>(
      0,
      (sum, log) => sum + log.sets.length,
    );

    return Column(
      children: [
        // Stats header
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatChip('Exercises', _exerciseLogs.length.toString()),
              _buildStatChip('Sets', totalSets.toString()),
              _buildStatChip('Reps', totalReps.toString()),
            ],
          ),
        ),

        // Exercise list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _exerciseLogs.length,
            itemBuilder: (context, index) {
              return ExerciseCard(
                exerciseLog: _exerciseLogs[index],
                index: index,
                onRemove: () => _removeExercise(index),
                onAddSet: () => _addSetToExercise(index),
                onRemoveSet: (setIndex) => _removeSet(index, setIndex),
                onDuplicate: () => _duplicateExercise(index),
                onDuplicateSet: (setIndex) => _duplicateSet(index, setIndex),
              );
            },
          ),
        ),

        // Notes and save button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'Add notes (optional)',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _addExercise,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Exercise'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveWorkout,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check),
                      label: Text(_isSaving ? 'Saving...' : 'Save Workout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
