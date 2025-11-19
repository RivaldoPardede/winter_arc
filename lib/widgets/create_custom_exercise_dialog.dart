import 'package:flutter/material.dart';
import 'package:winter_arc/models/exercise.dart';

class CreateCustomExerciseDialog extends StatefulWidget {
  const CreateCustomExerciseDialog({super.key});

  @override
  State<CreateCustomExerciseDialog> createState() => _CreateCustomExerciseDialogState();
}

class _CreateCustomExerciseDialogState extends State<CreateCustomExerciseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  ExerciseCategory _selectedCategory = ExerciseCategory.push;
  
  // Tracked metrics
  bool _trackReps = true;
  bool _trackWeight = true;
  bool _trackDuration = false;
  bool _trackDistance = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createExercise() {
    if (_formKey.currentState?.validate() ?? false) {
      final requiredFields = <String>[];
      if (_trackReps) requiredFields.add('reps');
      if (_trackWeight) requiredFields.add('weight');
      if (_trackDuration) requiredFields.add('duration');
      if (_trackDistance) requiredFields.add('distance');

      // Ensure at least one metric is tracked
      if (requiredFields.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one metric to track')),
        );
        return;
      }

      final exercise = Exercise(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        type: _selectedCategory == ExerciseCategory.cardio 
            ? ExerciseType.cardio 
            : ExerciseType.other,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        requiredFields: requiredFields,
      );
      Navigator.pop(context, exercise);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Custom Exercise'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Exercise Name',
                  hintText: 'e.g., Diamond Push-ups',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an exercise name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'e.g., Tricep-focused variation',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ExerciseCategory>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                isExpanded: true,
                items: ExerciseCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text('${category.icon} ${category.displayName}'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                      // Auto-select appropriate metrics based on category
                      if (value == ExerciseCategory.cardio) {
                        _trackReps = false;
                        _trackWeight = false;
                        _trackDuration = true;
                        _trackDistance = true;
                      } else {
                        _trackReps = true;
                        _trackWeight = true;
                        _trackDuration = false;
                        _trackDistance = false;
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              
              // Metrics Selection
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tracked Metrics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Reps'),
                value: _trackReps,
                onChanged: (val) => setState(() => _trackReps = val ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: const Text('Weight'),
                value: _trackWeight,
                onChanged: (val) => setState(() => _trackWeight = val ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: const Text('Duration (Time)'),
                value: _trackDuration,
                onChanged: (val) => setState(() => _trackDuration = val ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: const Text('Distance'),
                value: _trackDistance,
                onChanged: (val) => setState(() => _trackDistance = val ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),  // Column
        ),    // SingleChildScrollView
      ),      // Form
      ),      // SizedBox (content)
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _createExercise,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
