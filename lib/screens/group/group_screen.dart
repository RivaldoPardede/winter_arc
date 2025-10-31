import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winter_arc/providers/group_provider.dart';
import 'package:winter_arc/providers/user_provider.dart';
import 'package:winter_arc/widgets/member_card.dart';
import 'package:winter_arc/widgets/activity_feed_item.dart';
import 'package:winter_arc/widgets/leaderboard_card.dart';
import 'package:winter_arc/widgets/skeleton_loader.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Schedule the data loading after the current build frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadGroupData();
      });
    }
  }

  Future<void> _loadGroupData() async {
    final groupProvider = context.read<GroupProvider>();
    final userProvider = context.read<UserProvider>();

    // Load real group data from Firebase with real-time sync
    await groupProvider.loadMockData(userProvider.userId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupProvider = context.watch<GroupProvider>();
    final userProvider = context.watch<UserProvider>();

    if (groupProvider.isLoading) {
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header Skeleton
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SkeletonLoader(width: 150, height: 24),
                        const SizedBox(height: 8),
                        const SkeletonLoader(width: 200, height: 16),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(
                            3,
                            (_) => const Column(
                              children: [
                                SkeletonLoader(width: 40, height: 40),
                                SizedBox(height: 4),
                                SkeletonLoader(width: 60, height: 16),
                                SizedBox(height: 2),
                                SkeletonLoader(width: 50, height: 12),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Workout Cards Skeletons
                ...List.generate(3, (_) => const WorkoutCardSkeleton()),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with Group Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Squad',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Winter Arc Warriors 🏆',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Group Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildGroupStat(
                        context,
                        Icons.group,
                        '${groupProvider.members.length}',
                        'Members',
                      ),
                      _buildGroupStat(
                        context,
                        Icons.fitness_center,
                        '${groupProvider.totalGroupWorkouts}',
                        'Total Workouts',
                      ),
                      _buildGroupStat(
                        context,
                        Icons.local_fire_department,
                        '${groupProvider.groupStreak}',
                        'Group Streak',
                      ),
                    ],
                  ),

                  // Active Today Banner
                  if (groupProvider.activeMembersToday.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${groupProvider.activeMembersToday.length} member(s) worked out today!',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.green.shade900,
                                fontWeight: FontWeight.w600,
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

            // Tab Bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Feed'),
                Tab(text: 'Leaderboard'),
                Tab(text: 'Members'),
              ],
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Feed Tab
                  _buildFeedTab(groupProvider, userProvider.userId),

                  // Leaderboard Tab
                  _buildLeaderboardTab(groupProvider, userProvider.userId),

                  // Members Tab
                  _buildMembersTab(groupProvider, userProvider.userId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupStat(
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
          color: theme.colorScheme.onPrimaryContainer,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha:0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedTab(GroupProvider groupProvider, String? currentUserId) {
    final allWorkouts = groupProvider.allGroupWorkouts;

    if (allWorkouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.feed_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No activity yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Start working out to see group activity!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await groupProvider.refresh(currentUserId ?? '');
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allWorkouts.length,
        itemBuilder: (context, index) {
          final workout = allWorkouts[index];
          final member = groupProvider.members.firstWhere(
            (m) => m.user.id == workout.userId,
          );

          return ActivityFeedItem(
            workout: workout,
            member: member,
          );
        },
      ),
    );
  }

  Widget _buildLeaderboardTab(
    GroupProvider groupProvider,
    String? currentUserId,
  ) {
    if (groupProvider.members.isEmpty) {
      return const Center(
        child: Text('No members found'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        LeaderboardCard(
          members: groupProvider.leaderboardByWorkouts,
          type: LeaderboardType.workouts,
          currentUserId: currentUserId ?? '',
        ),
        const SizedBox(height: 16),
        LeaderboardCard(
          members: groupProvider.leaderboardByStreak,
          type: LeaderboardType.streak,
          currentUserId: currentUserId ?? '',
        ),
        const SizedBox(height: 16),
        LeaderboardCard(
          members: groupProvider.leaderboardByReps,
          type: LeaderboardType.reps,
          currentUserId: currentUserId ?? '',
        ),
      ],
    );
  }

  Widget _buildMembersTab(GroupProvider groupProvider, String? currentUserId) {
    if (groupProvider.members.isEmpty) {
      return const Center(
        child: Text('No members found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupProvider.members.length,
      itemBuilder: (context, index) {
        final member = groupProvider.members[index];
        return MemberCard(
          member: member,
          isCurrentUser: member.user.id == currentUserId,
        );
      },
    );
  }
}
