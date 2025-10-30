import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:winter_arc/screens/auth/login_screen.dart';
import 'package:winter_arc/screens/home/home_screen.dart';
import 'package:winter_arc/screens/log_workout/log_workout_screen.dart';
import 'package:winter_arc/screens/progress/progress_screen.dart';
import 'package:winter_arc/screens/group/group_screen.dart';
import 'package:winter_arc/services/auth_service.dart';
import 'package:winter_arc/providers/user_provider.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _authService = AuthService();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) {
      final isLoggedIn = _authService.isLoggedIn;
      final isLoginRoute = state.matchedLocation == '/login';

      // If not logged in and not already on login page, redirect to login
      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }

      // If logged in and on login page, redirect to home
      if (isLoggedIn && isLoginRoute) {
        return '/home';
      }

      // No redirect needed
      return null;
    },
    refreshListenable: GoRouterRefreshStream(_authService.authStateChanges),
    routes: [
      // Login Route (no bottom nav)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
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

  void _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Use the provider to sign out
      final userProvider = context.read<UserProvider>();
      await userProvider.signOut();
      
      // Router will automatically redirect to login screen
      // because of the auth state listener
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Winter Arc'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 12),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
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
}
