import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExerciseProgressCard extends StatelessWidget {
  final String exerciseName;
  final List<Map<String, dynamic>> progressData;
  final Map<String, dynamic>? personalRecord;

  const ExerciseProgressCard({
    super.key,
    required this.exerciseName,
    required this.progressData,
    this.personalRecord,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (progressData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No data for $exerciseName yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    final latestData = progressData.last;
    final firstData = progressData.first;
    
    // Calculate improvement
    final repsImprovement = latestData['totalReps'] - firstData['totalReps'];
    final setsImprovement = latestData['totalSets'] - firstData['totalSets'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Name
            Row(
              children: [
                Icon(
                  Icons.fitness_center,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    exerciseName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Personal Records
            if (personalRecord != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Personal Records',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPRStat(
                          context,
                          'Max Reps\n(Single Set)',
                          '${personalRecord!['maxRepsInSet']}',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha:0.2),
                        ),
                        _buildPRStat(
                          context,
                          'Max Reps\n(Workout)',
                          '${personalRecord!['maxRepsInWorkout']}',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.2),
                        ),
                        _buildPRStat(
                          context,
                          'Max Sets',
                          '${personalRecord!['maxSets']}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Recent Progress
            Text(
              'Recent Progress',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Progress Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Latest Session',
                    '${latestData['totalReps']} reps',
                    '${latestData['totalSets']} sets',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Improvement',
                    '${repsImprovement >= 0 ? '+' : ''}$repsImprovement reps',
                    '${setsImprovement >= 0 ? '+' : ''}$setsImprovement sets',
                    isImprovement: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Timeline
            Text(
              'Last ${progressData.length} Workouts',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: progressData.length > 10 ? 10 : progressData.length,
                itemBuilder: (context, index) {
                  final startIndex = progressData.length > 10
                      ? progressData.length - 10
                      : 0;
                  final data = progressData[startIndex + index];
                  final date = data['date'] as DateTime;
                  
                  return _buildTimelineItem(
                    context,
                    DateFormat('MMM dd').format(date),
                    data['totalReps'],
                    data['totalSets'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPRStat(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String primary,
    String secondary, {
    bool isImprovement = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            primary,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isImprovement && primary.startsWith('+')
                  ? Colors.green
                  : null,
            ),
          ),
          Text(
            secondary,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isImprovement && secondary.startsWith('+')
                  ? Colors.green
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    String date,
    int reps,
    int sets,
  ) {
    final theme = Theme.of(context);
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$reps reps',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '$sets sets',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
