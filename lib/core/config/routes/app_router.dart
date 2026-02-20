import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_orbit/core/auth/app_auth_notifier.dart';
import 'package:task_orbit/features/authentication/presentation/pages/forgot_password_page.dart';
import 'package:task_orbit/features/authentication/presentation/pages/sign_in_page.dart';
import 'package:task_orbit/features/authentication/presentation/pages/sign_up_page.dart';
import 'package:task_orbit/init_dependencies.dart';
import 'package:task_orbit/core/common/layout/app_shell_layout.dart';

final _appShellNavigatorKey = GlobalKey<NavigatorState>();

// Auth routes — accessible only when logged OUT
const _authRoutes = ['/sign-in', '/sign-up', '/forgot-password'];

// App (protected) routes — accessible only when logged IN
const _appRoutes = ['/agenda', '/pomodoro', '/profile'];

final GoRouter appRouter = GoRouter(
  initialLocation: '/sign-in',
  navigatorKey: serviceLocator<GlobalKey<NavigatorState>>(),

  // Re-run redirect every time auth state changes
  refreshListenable: serviceLocator<AppAuthNotifier>(),

  redirect: (context, state) {
    final isAuthenticated =
        serviceLocator<AppAuthNotifier>().isAuthenticated;
    final location = state.uri.path;

    final isOnAuthRoute = _authRoutes.any((r) => location.startsWith(r));
    final isOnAppRoute = _appRoutes.any((r) => location.startsWith(r));

    // Logged in + on auth page → send to home
    if (isAuthenticated && isOnAuthRoute) return '/agenda';

    // Not logged in + on protected page → send to sign in
    if (!isAuthenticated && isOnAppRoute) return '/sign-in';

    return null; // No redirect needed
  },

  routes: <RouteBase>[
    // ── Authentication routes ──────────────────────────────────
    GoRoute(
      name: 'sign-in',
      path: '/sign-in',
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      name: 'sign-up',
      path: '/sign-up',
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      name: 'forgot-password',
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),

    // ── Application Shell Routes ───────────────────────────────
    ShellRoute(
      navigatorKey: _appShellNavigatorKey,
      builder: (context, state, child) {
        return AppShellLayout(child: child);
      },
      routes: [
        GoRoute(
          name: 'agenda',
          path: '/agenda',
          builder: (context, state) =>
              const Center(child: Text('Agenda Page')),
        ),
        GoRoute(
          name: 'pomodoro',
          path: '/pomodoro',
          builder: (context, state) =>
              const Center(child: Text('Pomodoro Page')),
        ),
        GoRoute(
          name: 'profile',
          path: '/profile',
          builder: (context, state) =>
              const Center(child: Text('Profile Page')),
        ),
      ],
    ),
  ],
);
