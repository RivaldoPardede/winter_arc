import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:winter_arc/models/workout_log.dart';
import 'package:winter_arc/models/group_member.dart';

class ActivityFeedItem extends StatelessWidget {
  final WorkoutLog workout;
  final GroupMember member;

  const ActivityFeedItem({
    super.key,
    required this.workout,
    required this.member,
  });

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgo = _getTimeAgo(workout.date);
    final dateFormat = DateFormat('MMM dd, h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar + Name + Time
            Row(
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      member.avatarEmoji ?? '👤',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name and Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            member.user.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'completed a workout',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$timeAgo • ${dateFormat.format(workout.date)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Reaction Icon
                Icon(
                  Icons.favorite_border,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Workout Stats
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatChip(
                    context,
                    Icons.fitness_center,
                    '${workout.exercises.length}',
                    'exercises',
                  ),
                  _buildStatChip(
                    context,
                    Icons.repeat,
                    '${workout.totalSets}',
                    'sets',
                  ),
                  _buildStatChip(
                    context,
                    Icons.trending_up,
                    '${workout.totalReps}',
                    'reps',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Exercise List
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: workout.exercises.map((exercise) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    exercise.exercise.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),

            // Notes if available
            if (workout.notes?.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.format_quote,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        workout.notes!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
