import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winter_arc/utils/constants.dart';
import 'package:winter_arc/providers/user_provider.dart';
import 'package:winter_arc/providers/workout_provider.dart';
import 'package:winter_arc/widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load workouts when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final userProvider = context.read<UserProvider>();
    final workoutProvider = context.read<WorkoutProvider>();
    
    // Ensure user is loaded first
    if (userProvider.currentUser == null) {
      await userProvider.loadUser();
    }
    
    // Then load workouts
    await workoutProvider.loadWorkouts(userProvider.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: Consumer2<UserProvider, WorkoutProvider>(
            builder: (context, userProvider, workoutProvider, child) {
              if (userProvider.isLoading || workoutProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWinterArcTimer(context),
                    const SizedBox(height: 24),
                    _buildTodaySummary(context, workoutProvider),
                    const SizedBox(height: 24),
                    _buildWinterArcStats(context, workoutProvider),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWinterArcTimer(BuildContext context) {
    final daysRemaining = AppConstants.daysRemaining;
    final progress = AppConstants.winterArcProgress;
    final isActive = AppConstants.isWinterArcActive;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Winter Arc 2024-2025',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (isActive) ...[
              Text(
                '$daysRemaining',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Days Remaining',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toStringAsFixed(1)}% Complete',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ] else if (daysRemaining > 0) ...[
              const Icon(Icons.ac_unit, size: 48, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                'Starting Soon',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'November 1st',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ] else ...[
              const Icon(Icons.celebration, size: 48, color: Colors.orange),
              const SizedBox(height: 8),
              Text(
                'Complete!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'You finished Winter Arc!',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummary(BuildContext context, WorkoutProvider workoutProvider) {
    final todayWorkouts = workoutProvider.todayWorkouts;
    final totalReps = workoutProvider.todayTotalReps;
    final totalSets = workoutProvider.todayTotalSets;
    final streak = workoutProvider.streak;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (todayWorkouts.isNotEmpty)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Workouts',
                value: '${todayWorkouts.length}',
                icon: Icons.fitness_center,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Total Reps',
                value: '$totalReps',
                icon: Icons.repeat,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Streak',
                value: '$streak days',
                icon: Icons.local_fire_department,
                color: streak > 0 ? Colors.orange : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Sets',
                value: '$totalSets',
                icon: Icons.format_list_numbered,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWinterArcStats(BuildContext context, WorkoutProvider workoutProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Winter Arc Progress',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Workouts',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  '${workoutProvider.totalWinterArcWorkouts}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tap the "Log" tab to add a workout'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Log Workout'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}
