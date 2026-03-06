import 'init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_orbit/l10n/app_localizations.dart';
import 'package:task_orbit/core/config/theme/theme.dart';
import 'package:task_orbit/core/utils/create_theme.dart';
import 'package:task_orbit/core/config/routes/app_router.dart';
import 'package:task_orbit/core/common/locale/locale_notifier.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:task_orbit/core/services/notification_service.dart';

import 'package:task_orbit/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:task_orbit/features/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:task_orbit/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:task_orbit/features/pomodoro/presentation/bloc/pomodoro_bloc.dart';
import 'package:task_orbit/features/pomodoro/presentation/bloc/pomodoro_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();

  final notificationService = serviceLocator<NotificationService>();
  await notificationService.init();
  await notificationService.requestPermission();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => serviceLocator<AuthBloc>(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<AgendaBloc>(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<ProfileBloc>(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<PomodoroBloc>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final LocaleNotifier _localeNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _localeNotifier = serviceLocator<LocaleNotifier>();
    _localeNotifier.addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() => setState(() {});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final pomodoroBloc = serviceLocator<PomodoroBloc>();
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        pomodoroBloc.add(const PomodoroAppPaused());
        break;
      case AppLifecycleState.resumed:
        pomodoroBloc.add(const PomodoroAppResumed());
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _localeNotifier.removeListener(_onLocaleChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Delius", "Gabriela");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp.router(
      title: 'Task Orbit',
      routerConfig: appRouter,

      theme: theme.light(),
      darkTheme: theme.dark(),
      themeMode: ThemeMode.system,

      locale: _localeNotifier.value,
      supportedLocales: const [
        Locale('en'),
        Locale('vi'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      debugShowCheckedModeBanner: false,
    );
  }
}
