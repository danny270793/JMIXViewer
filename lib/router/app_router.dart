import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/settings_page.dart';
import '../pages/splash_page.dart';
import 'navigation_log_observer.dart';

/// Route path segments for deep linking and navigation.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/home';
  static const settings = '/settings';
}

/// Shared app router (single source of truth for navigation).
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  observers: [NavigationLogObserver()],
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (BuildContext context, GoRouterState state) =>
          const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (BuildContext context, GoRouterState state) =>
          const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (BuildContext context, GoRouterState state) =>
          const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (BuildContext context, GoRouterState state) =>
          const SettingsPage(),
    ),
  ],
);
