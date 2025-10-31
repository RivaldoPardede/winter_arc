import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:winter_arc/screens/auth/login_screen.dart';
import 'package:winter_arc/screens/auth/welcome_screen.dart';
import 'package:winter_arc/screens/home/home_screen.dart';
import 'package:winter_arc/screens/log_workout/log_workout_screen.dart';
import 'package:winter_arc/screens/progress/progress_screen.dart';
import 'package:winter_arc/screens/group/group_screen.dart';
import 'package:winter_arc/screens/profile/profile_screen.dart';
import 'package:winter_arc/services/auth_service.dart';
import 'package:winter_arc/providers/user_provider.dart';
import 'package:winter_arc/utils/responsive_layout.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _authService = AuthService();

  static GoRouter createRouter(UserProvider userProvider) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/home',
      redirect: (context, state) {
        final isLoggedIn = _authService.isLoggedIn;
        final isLoginRoute = state.matchedLocation == '/login';
        final isWelcomeRoute = state.matchedLocation == '/welcome';

        // If not logged in and not already on login page, redirect to login
        if (!isLoggedIn && !isLoginRoute) {
          return '/login';
        }

        // If logged in but no profile and not on welcome screen, redirect to welcome
        if (isLoggedIn && !userProvider.hasProfile && !isWelcomeRoute && !isLoginRoute) {
          return '/welcome';
        }

        // If logged in, has profile, and on login/welcome page, redirect to home
        if (isLoggedIn && userProvider.hasProfile && (isLoginRoute || isWelcomeRoute)) {
          return '/home';
        }

        // No redirect needed
        return null;
      },
      refreshListenable: Listenable.merge([
        GoRouterRefreshStream(_authService.authStateChanges),
        userProvider, // Also listen to UserProvider changes
      ]),
    routes: [
      // Login Route (no bottom nav)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Welcome Route (first-time setup)
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),

      // Profile Route (full screen, outside main nav)
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Main App Routes (with bottom nav)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/log',
                builder: (context, state) => const LogWorkoutScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/group',
                builder: (context, state) => const GroupScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    );
  }
}

// Helper class to make GoRouter respond to auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}


class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  void _onItemTapped(BuildContext context, int index) {
    // If switching to a different tab, close any open modals/dialogs
    if (index != navigationShell.currentIndex) {
      // Try to pop any route that's on top (modals, dialogs, bottom sheets)
      final navigator = Navigator.of(context);
      while (navigator.canPop()) {
        navigator.pop();
      }
    }
    
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final theme = Theme.of(context);

    if (isDesktop) {
      // Desktop: Use sidebar navigation
      return Scaffold(
        body: Row(
          children: [
            // Sidebar
            Container(
              width: 280,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border(
                  right: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // App branding
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Icon(
                          Icons.ac_unit,
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Winter Arc',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(height: 1),
                  
                  // Navigation items
                  _buildNavItem(
                    context,
                    icon: Icons.home,
                    selectedIcon: Icons.home,
                    label: 'Home',
                    index: 0,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.add_circle_outline,
                    selectedIcon: Icons.add_circle,
                    label: 'Log Workout',
                    index: 1,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.trending_up_outlined,
                    selectedIcon: Icons.trending_up,
                    label: 'Progress',
                    index: 2,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.group_outlined,
                    selectedIcon: Icons.group,
                    label: 'Squad',
                    index: 3,
                  ),
                  
                  const Divider(height: 1),
                  
                  _buildNavItem(
                    context,
                    icon: Icons.person_outline,
                    selectedIcon: Icons.person,
                    label: 'Profile',
                    index: -1, // Special case for profile
                    isProfile: true,
                  ),
                  
                  const Spacer(),
                  
                  // Footer
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '90-Day Winter Arc Challenge',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            
            // Main content
            Expanded(
              child: CenteredContentContainer(
                maxWidth: 1400,
                child: navigationShell,
              ),
            ),
          ],
        ),
      );
    }

    // Mobile/Tablet: Use bottom navigation
    return Scaffold(
      appBar: AppBar(
        title: const Text('Winter Arc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              context.push('/profile');
            },
            tooltip: 'Profile',
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => _onItemTapped(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Log',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group),
            label: 'Group',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    bool isProfile = false,
  }) {
    final theme = Theme.of(context);
    final isSelected = !isProfile && navigationShell.currentIndex == index;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        selected: isSelected,
        leading: Icon(isSelected ? selectedIcon : icon),
        title: Text(label),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        selectedTileColor: theme.colorScheme.primaryContainer,
        selectedColor: theme.colorScheme.onPrimaryContainer,
        onTap: () {
          if (isProfile) {
            context.push('/profile');
          } else {
            _onItemTapped(context, index);
          }
        },
      ),
    );
  }
}
