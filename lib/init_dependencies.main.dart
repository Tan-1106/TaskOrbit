part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await _initCore();
  _initAuth();
  _initAgenda();
  _initProfile();
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

  // SharedPreferences — for persisting Remember Me flag
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton(() => sharedPreferences);

  // Remember Me startup check:
  // If user did not check "Remember Me" on last login → sign out immediately
  // Default is false: if flag was never set, don't preserve the session
  final rememberMe = sharedPreferences.getBool('remember_me') ?? false;
  if (!rememberMe) {
    await FirebaseAuth.instance.signOut();
  }

  serviceLocator.registerLazySingleton(
    () => AppAuthNotifier(serviceLocator()),
  );

  serviceLocator.registerLazySingleton(
    () => LocaleNotifier(serviceLocator()),
  );

  serviceLocator.registerLazySingleton(() => AppDatabase());

  serviceLocator.registerLazySingleton(() => ConnectivityService());
}

void _initAuth() {
  // DataSource
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<IAuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator(),
      ),
    )
    // Use cases
    ..registerFactory(
      () => UserSignUp(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserLogin(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ForgotPassword(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ChangePassword(
        serviceLocator(),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        forgotPassword: serviceLocator(),
      ),
    );
}

void _initAgenda() {
  serviceLocator
    // Task DataSources
    ..registerFactory<TaskLocalDataSource>(
      () => TaskLocalDataSourceImpl(serviceLocator()),
    )
    ..registerFactory<TaskRemoteDataSource>(
      () => TaskRemoteDataSourceImpl(serviceLocator()),
    )
    // Task Repository
    ..registerFactory<ITaskRepository>(
      () => TaskRepositoryImpl(
        localDataSource: serviceLocator(),
        remoteDataSource: serviceLocator(),
        connectivityService: serviceLocator(),
      ),
    )
    // Task Use Cases
    ..registerFactory(() => GetTasksByDate(serviceLocator()))
    ..registerFactory(() => CreateTask(serviceLocator()))
    ..registerFactory(() => UpdateTask(serviceLocator()))
    ..registerFactory(() => DeleteTask(serviceLocator()))
    ..registerFactory(() => ToggleTaskComplete(serviceLocator()))
    ..registerFactory(() => SearchTasks(serviceLocator()))
    ..registerFactory(() => SyncTasks(serviceLocator()))
    ..registerFactory(() => GetTasksForPeriod(serviceLocator()))
    // Category DataSources
    ..registerFactory<CategoryLocalDataSource>(
      () => CategoryLocalDataSourceImpl(serviceLocator()),
    )
    ..registerFactory<CategoryRemoteDataSource>(
      () => CategoryRemoteDataSourceImpl(serviceLocator()),
    )
    // Category Repository
    ..registerFactory<ICategoryRepository>(
      () => CategoryRepositoryImpl(
        localDataSource: serviceLocator(),
        remoteDataSource: serviceLocator(),
        connectivityService: serviceLocator(),
      ),
    )
    // Category Use Cases
    ..registerFactory(() => GetCategories(serviceLocator()))
    ..registerFactory(() => CreateCategory(serviceLocator()))
    ..registerFactory(() => DeleteCategory(serviceLocator()))
    // Bloc
    ..registerLazySingleton(
      () => AgendaBloc(
        getTasksByDate: serviceLocator(),
        createTask: serviceLocator(),
        updateTask: serviceLocator(),
        deleteTask: serviceLocator(),
        toggleTaskComplete: serviceLocator(),
        searchTasks: serviceLocator(),
        syncTasks: serviceLocator(),
        getCategories: serviceLocator(),
        createCategory: serviceLocator(),
        deleteCategory: serviceLocator(),
        firebaseAuth: serviceLocator(),
        connectivityService: serviceLocator(),
      ),
    );
}

void _initProfile() {
  serviceLocator.registerLazySingleton(
    () => ProfileBloc(
      getTasksForPeriod: serviceLocator(),
      changePassword: serviceLocator(),
      firebaseAuth: serviceLocator(),
    ),
  );
}
