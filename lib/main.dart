import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:winter_arc/firebase_options.dart';
import 'package:winter_arc/providers/user_provider.dart';
import 'package:winter_arc/providers/workout_provider.dart';
import 'package:winter_arc/providers/group_provider.dart';
import 'package:winter_arc/providers/theme_provider.dart';
import 'package:winter_arc/router/app_router.dart';
import 'package:winter_arc/utils/theme.dart';
import 'package:winter_arc/utils/constants.dart';
import 'package:winter_arc/services/notification_service.dart';
import 'package:winter_arc/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // Enable offline persistence for better performance and offline support
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  // Initialize notification service
  await NotificationService().initialize();
  
  runApp(const WinterArcApp());
}

class WinterArcApp extends StatelessWidget {
  const WinterArcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()),
        ChangeNotifierProxyProvider<UserProvider, WorkoutProvider>(
          create: (_) => WorkoutProvider(),
          update: (_, userProvider, workoutProvider) {
            if (workoutProvider != null && userProvider.isAuthenticated) {
              workoutProvider.loadWorkouts(userProvider.userId);
            }
            return workoutProvider ?? WorkoutProvider();
          },
        ),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
      ],
      child: const _AppRouterWidget(),
    );
  }
}

class _AppRouterWidget extends StatefulWidget {
  const _AppRouterWidget();

  @override
  State<_AppRouterWidget> createState() => _AppRouterWidgetState();
}

class _AppRouterWidgetState extends State<_AppRouterWidget> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    _router = AppRouter.createRouter(userProvider);
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
    );
  }
}
