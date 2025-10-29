import 'package:flutter/material.dart';
import 'package:winter_arc/utils/constants.dart';
import 'package:winter_arc/services/storage_service.dart';
import 'package:winter_arc/models/workout_log.dart';
import 'package:winter_arc/models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storageService = StorageService();
  bool _isLoading = true;
  List<WorkoutLog> _todayWorkouts = [];
  int _streak = 0;
  int _totalWorkouts = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final user = await _storageService.getCurrentUser();
      final userId = user?.id ?? 'default_user';

      // If no user exists, create a default one
      if (user == null) {
        await _storageService.saveCurrentUser(
          User(
            id: userId,
            name: 'Winter Warrior',
            joinedDate: DateTime.now(),
          ),
        );
      }

      final today = await _storageService.getTodayWorkouts(userId);
      final streak = await _storageService.getWorkoutStreak(userId);
      final total = await _storageService.getTotalWorkoutsInWinterArc(userId);

      setState(() {
        _todayWorkouts = today;
        _streak = streak;
        _totalWorkouts = total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWinterArcTimer(context),
                      const SizedBox(height: 24),
                      _buildTodaySummary(context),
                      const SizedBox(height: 24),
                      _buildWinterArcStats(context),
                      const SizedBox(height: 24),
                      _buildQuickActions(context),
                    ],
                  ),
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

  Widget _buildTodaySummary(BuildContext context) {
    final totalReps = _todayWorkouts.fold<int>(
      0,
      (sum, workout) => sum + workout.totalReps,
    );
    final totalSets = _todayWorkouts.fold<int>(
      0,
      (sum, workout) => sum + workout.totalSets,
    );

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
            if (_todayWorkouts.isNotEmpty)
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
              child: _buildStatCard(
                context,
                'Workouts',
                '${_todayWorkouts.length}',
                Icons.fitness_center,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Total Reps',
                '$totalReps',
                Icons.repeat,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Streak',
                '$_streak days',
                Icons.local_fire_department,
                color: _streak > 0 ? Colors.orange : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Sets',
                '$totalSets',
                Icons.format_list_numbered,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWinterArcStats(BuildContext context) {
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
                  '$_totalWorkouts',
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

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
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
              // The navigation is handled by the bottom nav bar
              // Just show a message
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
