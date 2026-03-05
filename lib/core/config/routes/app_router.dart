import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_orbit/core/auth/app_auth_notifier.dart';
import 'package:task_orbit/features/authentication/presentation/pages/email_verification_page.dart';
import 'package:task_orbit/features/authentication/presentation/pages/forgot_password_page.dart';
import 'package:task_orbit/features/authentication/presentation/pages/sign_in_page.dart';
import 'package:task_orbit/features/authentication/presentation/pages/sign_up_page.dart';
import 'package:task_orbit/features/agenda/presentation/pages/agenda_page.dart';
import 'package:task_orbit/features/agenda/presentation/pages/task_detail_page.dart';
import 'package:task_orbit/features/agenda/domain/entities/task.dart' as task_domain;
import 'package:task_orbit/features/profile/presentation/pages/profile_page.dart';
import 'package:task_orbit/features/pomodoro/presentation/pages/pomodoro_page.dart';
import 'package:task_orbit/init_dependencies.dart';
import 'package:task_orbit/core/common/layout/app_shell_layout.dart';

final _appShellNavigatorKey = GlobalKey<NavigatorState>();

const _authRoutes = [
  '/sign-in',
  '/sign-up',
  '/forgot-password',
];

final GoRouter appRouter = GoRouter(
  initialLocation: '/agenda',
  refreshListenable: serviceLocator<AppAuthNotifier>(),
  navigatorKey: serviceLocator<GlobalKey<NavigatorState>>(),

  redirect: (context, state) {
    final location = state.uri.path;
    final isOnAuthRoute = _authRoutes.any((r) => location.startsWith(r));
    final isAuthenticated = serviceLocator<AppAuthNotifier>().isAuthenticated;

    // Redirect authenticated users to the agenda.
    if (isAuthenticated && isOnAuthRoute) return '/agenda';

    // Guests are allowed to access all app routes freely.
    return null;
  },

  routes: <RouteBase>[
    GoRoute(
      name: 'sign-in',
      path: '/sign-in',
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      name: 'sign-up',
      path: '/sign-up',
      builder: (context, state) => const SignUpPage(),
      routes: [
        GoRoute(
          name: 'email-verification',
          path: 'email-verification',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return EmailVerificationPage(
              name: (extra['name'] as String?) ?? '',
              email: (extra['email'] as String?) ?? '',
            );
          },
        ),
      ],
    ),
    GoRoute(
      name: 'forgot-password',
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),

    ShellRoute(
      navigatorKey: _appShellNavigatorKey,
      builder: (context, state, child) {
        return AppShellLayout(child: child);
      },
      routes: [
        GoRoute(
          name: 'agenda',
          path: '/agenda',
          builder: (context, state) => const AgendaPage(),
        ),
        GoRoute(
          name: 'task-detail',
          path: '/agenda/task-detail',
          builder: (context, state) {
            final task = state.extra as task_domain.Task;
            return TaskDetailPage(task: task);
          },
        ),
        GoRoute(
          name: 'pomodoro',
          path: '/pomodoro',
          builder: (context, state) => const PomodoroPage(),
        ),
        GoRoute(
          name: 'profile',
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
  ],
);
