import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winter_arc/providers/user_provider.dart';
import 'package:winter_arc/providers/workout_provider.dart';
import 'package:winter_arc/providers/group_provider.dart';
import 'package:winter_arc/router/app_router.dart';
import 'package:winter_arc/utils/theme.dart';
import 'package:winter_arc/utils/constants.dart';

void main() {
  runApp(const WinterArcApp());
}

class WinterArcApp extends StatelessWidget {
  const WinterArcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
