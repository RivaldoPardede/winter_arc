import 'package:flutter/material.dart';
import 'package:winter_arc/models/workout_set.dart';

class SetRow extends StatelessWidget {
  final WorkoutSet set;
  final int setNumber;
  final VoidCallback onRemove;

  const SetRow({
    super.key,
    required this.set,
    required this.setNumber,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
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
              '$setNumber',
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
            onPressed: onRemove,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
