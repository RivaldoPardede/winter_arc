import 'package:flutter/material.dart';
import 'package:winter_arc/models/group_member.dart';

enum LeaderboardType {
  workouts,
  streak,
  reps,
}

class LeaderboardCard extends StatelessWidget {
  final List<GroupMember> members;
  final LeaderboardType type;
  final String currentUserId;

  const LeaderboardCard({
    super.key,
    required this.members,
    required this.type,
    required this.currentUserId,
  });

  String get _title {
    switch (type) {
      case LeaderboardType.workouts:
        return 'Most Workouts';
      case LeaderboardType.streak:
        return 'Longest Streak';
      case LeaderboardType.reps:
        return 'Total Reps';
    }
  }

  IconData get _icon {
    switch (type) {
      case LeaderboardType.workouts:
        return Icons.fitness_center;
      case LeaderboardType.streak:
        return Icons.local_fire_department;
      case LeaderboardType.reps:
        return Icons.trending_up;
    }
  }

  int _getValue(GroupMember member) {
    switch (type) {
      case LeaderboardType.workouts:
        return member.totalWorkouts;
      case LeaderboardType.streak:
        return member.currentStreak;
      case LeaderboardType.reps:
        return member.totalReps;
    }
  }

  Color _getMedalColor(BuildContext context, int rank) {
    switch (rank) {
      case 0:
        return Colors.amber; // Gold
      case 1:
        return Colors.grey.shade400; // Silver
      case 2:
        return Colors.brown.shade300; // Bronze
      default:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
  }

  IconData? _getMedalIcon(int rank) {
    switch (rank) {
      case 0:
        return Icons.emoji_events; // Trophy
      case 1:
        return Icons.military_tech; // Medal
      case 2:
        return Icons.military_tech; // Medal
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  _icon,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Leaderboard List
            ...members.asMap().entries.map((entry) {
              final rank = entry.key;
              final member = entry.value;
              final value = _getValue(member);
              final isCurrentUser = member.user.id == currentUserId;
              final medalIcon = _getMedalIcon(rank);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? theme.colorScheme.primaryContainer.withValues(alpha:0.3)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: isCurrentUser
                      ? Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    // Rank/Medal
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getMedalColor(context, rank),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: medalIcon != null
                            ? Icon(
                                medalIcon,
                                color: rank == 0
                                    ? Colors.amber.shade900
                                    : Colors.white,
                                size: 20,
                              )
                            : Text(
                                '${rank + 1}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Avatar
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          member.avatarEmoji ?? '👤',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Name
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
                                  color: isCurrentUser
                                      ? theme.colorScheme.primary
                                      : null,
                                ),
                              ),
                              if (isCurrentUser) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'You',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (member.favoriteExercise != null)
                            Text(
                              member.favoriteExercise!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Value
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$value',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isCurrentUser
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        if (type == LeaderboardType.streak && value > 0)
                          const Text(
                            '🔥',
                            style: TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
