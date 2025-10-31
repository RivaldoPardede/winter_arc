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
    
    // Group exercises by category
    final Map<ExerciseCategory, List<Exercise>> exercisesByCategory = {};
    for (final exercise in exercises) {
      if (!exercisesByCategory.containsKey(exercise.category)) {
        exercisesByCategory[exercise.category] = [];
      }
      exercisesByCategory[exercise.category]!.add(exercise);
    }
    
    // Order categories: push, pull, legs, core
    final orderedCategories = [
      ExerciseCategory.push,
      ExerciseCategory.pull,
      ExerciseCategory.legs,
      ExerciseCategory.core,
    ];

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
                itemCount: orderedCategories.length,
                itemBuilder: (context, categoryIndex) {
                  final category = orderedCategories[categoryIndex];
                  final categoryExercises = exercisesByCategory[category] ?? [];
                  
                  if (categoryExercises.isEmpty) return const SizedBox.shrink();
                  
                  return ExpansionTile(
                    initiallyExpanded: true,
                    leading: Text(
                      category.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      category.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      category.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    children: categoryExercises.map((exercise) {
                      return ListTile(
                        contentPadding: const EdgeInsets.only(left: 72, right: 16),
                        title: Text(exercise.name),
                        subtitle: Text(exercise.description),
                        trailing: const Icon(Icons.add_circle_outline),
                        onTap: () {
                          onExerciseSelected(exercise);
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
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
