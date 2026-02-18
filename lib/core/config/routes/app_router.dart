import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_orbit/init_dependencies.dart';
import 'package:task_orbit/core/common/layout/app_shell_layout.dart';

final _appShellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  initialLocation: '/sign-in',
  navigatorKey: serviceLocator<GlobalKey<NavigatorState>>(),
  routes: <RouteBase>[
    // Authentication routes
    GoRoute(
      name: 'sign-in',
      path: '/sign-in',
      builder: (context, state) => const Center(child: Text('Sign In Page')),
    ),
    GoRoute(
      name: 'sign-up',
      path: '/sign-up',
      builder: (context, state) => const Center(child: Text('Sign Up Page')),
    ),
    GoRoute(
      name: 'forgot-password',
      path: '/forgot-password',
      builder: (context, state) => const Center(child: Text('Forgot Password Page')),
    ),

    // Application Shell Routes
    ShellRoute(
      navigatorKey: _appShellNavigatorKey,
      builder: (context, state, child) {
        return AppShellLayout(child: child);
      },
      routes: [
        GoRoute(
          name: 'agenda',
          path: '/agenda',
          builder: (context, state) => const Center(child: Text('Agenda Page')),
        ),
        GoRoute(
          name: 'pomodoro',
          path: '/pomodoro',
          builder: (context, state) => const Center(child: Text('Pomodoro Page')),
        ),
        GoRoute(
          name: 'profile',
          path: '/profile',
          builder: (context, state) => const Center(child: Text('Profile Page')),
        ),
      ],
    ),
  ],
);
