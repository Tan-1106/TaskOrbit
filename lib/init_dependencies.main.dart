part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await _initCore();
}

// Initialize Core Modules
Future<void> _initCore() async {
  // Navigation Key
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  serviceLocator.registerLazySingleton(() => navigatorKey);

  // Firebase Initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  serviceLocator.registerLazySingleton(() => FirebaseAuth.instance);
  serviceLocator.registerLazySingleton(() => FirebaseFirestore.instance);
}
