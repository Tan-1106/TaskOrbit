import 'init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_orbit/l10n/app_localizations.dart';
import 'package:task_orbit/core/config/theme/theme.dart';
import 'package:task_orbit/core/utils/create_theme.dart';
import 'package:task_orbit/core/config/routes/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:task_orbit/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:task_orbit/features/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:task_orbit/features/profile/presentation/bloc/profile_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(
    MultiBlocProvider(
      // Blocs
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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Delius", "Fugaz One");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp.router(
      // Title and Routing
      title: 'Task Orbit',
      routerConfig: appRouter,

      // Theming
      theme: theme.light(),
      darkTheme: theme.dark(),
      themeMode: ThemeMode.system,

      // Localization
      supportedLocales: const [
        Locale('en', 'US'),
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        for (var locale in supportedLocales) {
          if (locale.languageCode == deviceLocale!.languageCode &&
              locale.countryCode == deviceLocale.countryCode) {
            return deviceLocale;
          }
        }
        return supportedLocales.first;
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Other configurations
      debugShowCheckedModeBanner: false,
    );
  }
}
