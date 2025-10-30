import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:winter_arc/models/group_member.dart';

class MemberCard extends StatelessWidget {
  final GroupMember member;
  final bool isCurrentUser;
  final VoidCallback? onTap;

  const MemberCard({
    super.key,
    required this.member,
    this.isCurrentUser = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        member.avatarEmoji ?? '👤',
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Name and Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              member.user.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isCurrentUser) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'You',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (member.workedOutToday) ...[
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Worked out today',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ] else if (member.lastWorkoutDate != null) ...[
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Last: ${dateFormat.format(member.lastWorkoutDate!)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ] else ...[
                              Text(
                                'No workouts yet',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Streak Badge
                  if (member.currentStreak > 0)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '🔥',
                            style: const TextStyle(fontSize: 20),
                          ),
                          Text(
                            '${member.currentStreak}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    Icons.fitness_center,
                    '${member.totalWorkouts}',
                    'Workouts',
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  _buildStatItem(
                    context,
                    Icons.trending_up,
                    '${member.totalReps}',
                    'Reps',
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  _buildStatItem(
                    context,
                    Icons.repeat,
                    '${member.totalSets}',
                    'Sets',
                  ),
                ],
              ),

              // Favorite Exercise
              if (member.favoriteExercise != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Favorite: ${member.favoriteExercise}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
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
