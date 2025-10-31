// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winter_arc/models/exercise.dart';
import 'package:winter_arc/models/workout_log.dart';
import 'package:winter_arc/providers/user_provider.dart';
import 'package:winter_arc/providers/workout_provider.dart';
import 'package:winter_arc/services/custom_exercise_service.dart';
import 'package:winter_arc/widgets/exercise_selector.dart';
import 'package:winter_arc/widgets/add_set_dialog.dart';
import 'package:winter_arc/widgets/exercise_card.dart';

class EditWorkoutScreen extends StatefulWidget {
  final WorkoutLog workout;

  const EditWorkoutScreen({
    super.key,
    required this.workout,
  });

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  late List<ExerciseLog> _exerciseLogs;
  late TextEditingController _notesController;
  final _customExerciseService = CustomExerciseService();
  bool _isSaving = false;
  List<Exercise> _allExercises = Exercise.defaultExercises;

  @override
  void initState() {
    super.initState();
    // Create a mutable copy of the exercises
    _exerciseLogs = widget.workout.exercises.map((e) => 
      ExerciseLog(
        exercise: e.exercise,
        sets: List.from(e.sets), // Create mutable copy of sets
      )
    ).toList();
    _notesController = TextEditingController(text: widget.workout.notes ?? '');
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
      useRootNavigator: false,
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
      ),
    );
  }

  void _addSetToExercise(int exerciseIndex) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => AddSetDialog(
        exerciseName: _exerciseLogs[exerciseIndex].exercise.name,
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
      final workoutProvider = context.read<WorkoutProvider>();

      // Create updated workout with same ID and date
      final updatedWorkout = widget.workout.copyWith(
        exercises: _exerciseLogs,
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );

      await workoutProvider.updateWorkout(updatedWorkout);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Workout updated! ${updatedWorkout.totalReps} total reps 💪'),
            backgroundColor: Colors.green,
          ),
        );

        // Go back to previous screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating workout: $e'),
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
        title: const Text('Edit Workout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isSaving ? null : _saveWorkout,
            tooltip: 'Save changes',
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
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No Exercises',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add exercises to this workout',
            style: Theme.of(context).textTheme.bodyLarge,
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
              );
            },
          ),
        ),

        // Notes and action buttons
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
                    child: FilledButton.icon(
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
                          : const Icon(Icons.save),
                      label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
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
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
      ],
    );
  }
}
