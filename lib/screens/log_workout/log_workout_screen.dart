import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:winter_arc/models/exercise.dart';
import 'package:winter_arc/models/workout_log.dart';
import 'package:winter_arc/models/workout_set.dart';
import 'package:winter_arc/services/storage_service.dart';

class LogWorkoutScreen extends StatefulWidget {
  const LogWorkoutScreen({super.key});

  @override
  State<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends State<LogWorkoutScreen> {
  final _storageService = StorageService();
  final List<ExerciseLog> _exerciseLogs = [];
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _addExercise() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ExerciseSelector(
        onExerciseSelected: (exercise) {
          setState(() {
            _exerciseLogs.add(ExerciseLog(
              exercise: exercise,
              sets: [],
            ));
          });
        },
      ),
    );
  }

  void _addSetToExercise(int exerciseIndex) {
    showDialog(
      context: context,
      builder: (context) => _AddSetDialog(
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
      final user = await _storageService.getCurrentUser();
      final userId = user?.id ?? 'default_user';

      final workout = WorkoutLog(
        id: const Uuid().v4(),
        userId: userId,
        date: DateTime.now(),
        exercises: _exerciseLogs,
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );

      await _storageService.saveWorkoutLog(workout);

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
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
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
              return _buildExerciseCard(index);
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
                color: Colors.black.withOpacity(0.1),
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

  Widget _buildExerciseCard(int index) {
    final exerciseLog = _exerciseLogs[index];
    final exercise = exerciseLog.exercise;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Exercise header
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                exercise.name[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              exercise.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${exerciseLog.totalReps} total reps'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _removeExercise(index),
              color: Colors.red,
            ),
          ),

          // Sets list
          if (exerciseLog.sets.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: List.generate(
                  exerciseLog.sets.length,
                  (setIndex) => _buildSetRow(index, setIndex),
                ),
              ),
            ),

          // Add set button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton.icon(
              onPressed: () => _addSetToExercise(index),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add Set'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(int exerciseIndex, int setIndex) {
    final set = _exerciseLogs[exerciseIndex].sets[setIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${setIndex + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${set.reps} reps',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          if (set.duration != null)
            Text(
              '${set.duration}s',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => _removeSet(exerciseIndex, setIndex),
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}

// Exercise Selector Bottom Sheet
class _ExerciseSelector extends StatelessWidget {
  final Function(Exercise) onExerciseSelected;

  const _ExerciseSelector({required this.onExerciseSelected});

  @override
  Widget build(BuildContext context) {
    final exercises = Exercise.defaultExercises;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select Exercise',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        exercise.name[0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(exercise.name),
                    subtitle: Text(exercise.description ?? ''),
                    trailing: const Icon(Icons.add_circle_outline),
                    onTap: () {
                      onExerciseSelected(exercise);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// Add Set Dialog
class _AddSetDialog extends StatefulWidget {
  final String exerciseName;
  final Function(WorkoutSet) onSetAdded;

  const _AddSetDialog({
    required this.exerciseName,
    required this.onSetAdded,
  });

  @override
  State<_AddSetDialog> createState() => _AddSetDialogState();
}

class _AddSetDialogState extends State<_AddSetDialog> {
  final _repsController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _repsController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addSet() {
    final reps = int.tryParse(_repsController.text);
    if (reps == null || reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid reps'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final duration = _durationController.text.isEmpty
        ? null
        : int.tryParse(_durationController.text);

    final set = WorkoutSet(
      reps: reps,
      duration: duration,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    widget.onSetAdded(set);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Set - ${widget.exerciseName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _repsController,
              decoration: const InputDecoration(
                labelText: 'Reps *',
                hintText: 'Enter number of reps',
                prefixIcon: Icon(Icons.repeat),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (seconds)',
                hintText: 'Optional',
                prefixIcon: Icon(Icons.timer),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Optional',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addSet,
          child: const Text('Add Set'),
        ),
      ],
    );
  }
}
