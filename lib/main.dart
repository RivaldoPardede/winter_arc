import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:winter_arc/firebase_options.dart';
import 'package:winter_arc/providers/user_provider.dart';
import 'package:winter_arc/providers/workout_provider.dart';
import 'package:winter_arc/providers/group_provider.dart';
import 'package:winter_arc/router/app_router.dart';
import 'package:winter_arc/utils/theme.dart';
import 'package:winter_arc/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Enable offline persistence for better performance and offline support
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  runApp(const WinterArcApp());
}

class WinterArcApp extends StatelessWidget {
  const WinterArcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            routerConfig: AppRouter.createRouter(userProvider),
          );
        },
      ),
    );
  }
}
