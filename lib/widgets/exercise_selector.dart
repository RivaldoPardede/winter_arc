import 'package:flutter/material.dart';
import 'package:winter_arc/models/exercise.dart';

class ExerciseSelector extends StatelessWidget {
  final Function(Exercise) onExerciseSelected;

  const ExerciseSelector({
    super.key,
    required this.onExerciseSelected,
  });

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
