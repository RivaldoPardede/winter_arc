import 'package:flutter/material.dart';
import 'package:winter_arc/models/workout_log.dart';
import 'package:winter_arc/widgets/set_row.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseLog exerciseLog;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback onAddSet;
  final Function(int) onRemoveSet;

  const ExerciseCard({
    super.key,
    required this.exerciseLog,
    required this.index,
    required this.onRemove,
    required this.onAddSet,
    required this.onRemoveSet,
    required this.onDuplicate,
    required this.onDuplicateSet,
  });

  final VoidCallback onDuplicate;
  final Function(int) onDuplicateSet;

  @override
  Widget build(BuildContext context) {
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: onDuplicate,
                  tooltip: 'Duplicate Exercise',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onRemove,
                  color: Colors.red,
                  tooltip: 'Remove Exercise',
                ),
              ],
            ),
          ),

          // Sets list
          if (exerciseLog.sets.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: List.generate(
                  exerciseLog.sets.length,
                  (setIndex) => SetRow(
                    set: exerciseLog.sets[setIndex],
                    setNumber: setIndex + 1,
                    onRemove: () => onRemoveSet(setIndex),
                    onDuplicate: () => onDuplicateSet(setIndex),
                  ),
                ),
              ),
            ),

          // Add set button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton.icon(
              onPressed: onAddSet,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add Set'),
            ),
          ),
        ],
      ),
    );
  }
}
