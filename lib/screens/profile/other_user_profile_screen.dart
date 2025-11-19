import 'package:flutter/material.dart';
import 'package:winter_arc/models/user.dart';
import 'package:winter_arc/models/workout_log.dart';
import 'package:winter_arc/services/firestore_service.dart';
import 'package:intl/intl.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final User user;

  const OtherUserProfileScreen({super.key, required this.user});

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  final _firestoreService = FirestoreService();
  List<WorkoutLog> _workouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    try {
      final workouts = await _firestoreService.getWorkoutLogs(widget.user.id);
      if (mounted) {
        setState(() {
          _workouts = workouts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    backgroundImage: widget.user.avatarUrl != null
                        ? NetworkImage(widget.user.avatarUrl!)
                        : null,
                    child: widget.user.avatarUrl == null
                        ? Text(
                            widget.user.avatarEmoji ?? widget.user.name[0].toUpperCase(),
                            style: const TextStyle(fontSize: 40),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.user.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department, size: 20, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.user.currentStreak} Day Streak',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Recent Activity Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Workout List
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_workouts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'No workouts logged yet.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.5),
                      ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _workouts.length,
                itemBuilder: (context, index) {
                  final workout = _workouts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.fitness_center),
                      ),
                      title: Text(
                        DateFormat('EEEE, MMM d').format(workout.date),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${workout.exercises.length} Exercises • ${workout.totalReps} Reps',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Show workout details (optional, can reuse existing detail screen if available)
                        _showWorkoutDetails(context, workout);
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showWorkoutDetails(BuildContext context, WorkoutLog workout) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Workout Details',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMMM d, yyyy').format(workout.date),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ...workout.exercises.map((exerciseLog) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exerciseLog.exercise.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...exerciseLog.sets.asMap().entries.map((entry) {
                  final setIndex = entry.key;
                  final set = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Row(
                      children: [
                        Text(
                          'Set ${setIndex + 1}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        Text('${set.reps} reps'),
                        if (set.weight != null && set.weight! > 0)
                          Text(' • ${set.weight} kg'),
                      ],
                    ),
                  );
                }),
                const Divider(height: 24),
              ],
            )),
            if (workout.notes != null && workout.notes!.isNotEmpty) ...[
              const Text(
                'Notes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(workout.notes!),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}
