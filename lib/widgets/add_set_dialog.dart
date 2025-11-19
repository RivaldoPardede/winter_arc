import 'package:flutter/material.dart';
import 'package:winter_arc/models/workout_set.dart';

import 'package:winter_arc/models/exercise.dart';

class AddSetDialog extends StatefulWidget {
  final Exercise exercise;
  final Function(WorkoutSet) onSetAdded;

  const AddSetDialog({
    super.key,
    required this.exercise,
    required this.onSetAdded,
  });

  @override
  State<AddSetDialog> createState() => _AddSetDialogState();
}

class _AddSetDialogState extends State<AddSetDialog> {
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _durationController = TextEditingController();
  final _distanceController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    _durationController.dispose();
    _distanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addSet() {
    final requiredFields = widget.exercise.requiredFields;
    
    int? reps;
    if (requiredFields.contains('reps')) {
      reps = int.tryParse(_repsController.text);
      if (reps == null || reps <= 0) {
        _showError('Please enter valid reps');
        return;
      }
    } else {
      reps = 0; // Default for cardio/duration only exercises
    }

    double? weight;
    if (requiredFields.contains('weight')) {
      weight = double.tryParse(_weightController.text);
    }

    int? duration;
    if (requiredFields.contains('duration')) {
      duration = int.tryParse(_durationController.text);
      if (duration == null || duration <= 0) {
        _showError('Please enter valid duration');
        return;
      }
    }

    double? distance;
    if (requiredFields.contains('distance')) {
      distance = double.tryParse(_distanceController.text);
      if (distance == null || distance <= 0) {
        _showError('Please enter valid distance');
        return;
      }
    }

    final set = WorkoutSet(
      reps: reps,
      weight: weight,
      duration: duration,
      distance: distance,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    widget.onSetAdded(set);
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requiredFields = widget.exercise.requiredFields;

    return AlertDialog(
      title: Text('Add Set - ${widget.exercise.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (requiredFields.contains('reps')) ...[
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
            ],
            
            if (requiredFields.contains('weight')) ...[
              TextField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  hintText: 'Optional',
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
            ],

            if (requiredFields.contains('distance')) ...[
              TextField(
                controller: _distanceController,
                decoration: const InputDecoration(
                  labelText: 'Distance (km) *',
                  hintText: 'Enter distance',
                  prefixIcon: Icon(Icons.directions_run),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
            ],

            if (requiredFields.contains('duration')) ...[
              TextField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (seconds) *',
                  hintText: 'Enter duration',
                  prefixIcon: Icon(Icons.timer),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
            ],
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
