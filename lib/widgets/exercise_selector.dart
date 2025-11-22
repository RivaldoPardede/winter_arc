import 'package:flutter/material.dart';
import 'package:winter_arc/models/exercise.dart';
import 'package:winter_arc/widgets/create_custom_exercise_dialog.dart';

class ExerciseSelector extends StatelessWidget {
  final Function(Exercise) onExerciseSelected;
  final List<Exercise> exercises;
  final Function(Exercise)? onCustomExerciseCreated;
  final Function(Exercise)? onExerciseDeleted;

  const ExerciseSelector({
    super.key,
    required this.onExerciseSelected,
    required this.exercises,
    this.onCustomExerciseCreated,
    this.onExerciseDeleted,
  });

  void _showCreateExerciseDialog(BuildContext context) async {
    final exercise = await showDialog<Exercise>(
      context: context,
      builder: (context) => const CreateCustomExerciseDialog(),
    );
    
    if (exercise != null && onCustomExerciseCreated != null) {
      onCustomExerciseCreated!(exercise);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      ExerciseCategory.cardio,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Exercise',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (onCustomExerciseCreated != null)
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          tooltip: 'Create Custom Exercise',
                          onPressed: () => _showCreateExerciseDialog(context),
                        ),
                    ],
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
                      final isCustom = exercise.id.startsWith('custom_');
                      return ListTile(
                        contentPadding: const EdgeInsets.only(left: 72, right: 16),
                        title: Row(
                          children: [
                            Expanded(child: Text(exercise.name)),
                            if (isCustom)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'CUSTOM',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(exercise.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isCustom && onExerciseDeleted != null)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Exercise'),
                                      content: Text('Are you sure you want to delete "${exercise.name}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  
                                  if (confirm == true) {
                                    onExerciseDeleted!(exercise);
                                  }
                                },
                              ),
                            const Icon(Icons.add_circle_outline),
                          ],
                        ),
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
