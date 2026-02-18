import 'init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_orbit/core/config/routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();

  // runApp(
  //   MultiProvider(
  //     // Providers
  //     providers: [],
  //     child: MultiBlocProvider(
  //       // Blocs
  //       providers: [],
  //       child: const MyApp(),
  //     ),
  //   ),
  // );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Task Orbit',
      routerConfig: appRouter,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
    );
  }
}
