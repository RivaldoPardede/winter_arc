import 'package:flutter/material.dart';
import 'package:winter_arc/models/workout_set.dart';

class AddSetDialog extends StatefulWidget {
  final String exerciseName;
  final Function(WorkoutSet) onSetAdded;

  const AddSetDialog({
    super.key,
    required this.exerciseName,
    required this.onSetAdded,
  });

  @override
  State<AddSetDialog> createState() => _AddSetDialogState();
}

class _AddSetDialogState extends State<AddSetDialog> {
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
