part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await _initCore();
  _initAuth();
  _initAgenda();
  _initProfile();
  _initPomodoro();
}

Future<void> _initCore() async {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  serviceLocator.registerLazySingleton(() => navigatorKey);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  serviceLocator.registerLazySingleton(() => FirebaseAuth.instance);
  serviceLocator.registerLazySingleton(() => FirebaseFirestore.instance);

  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton(() => sharedPreferences);

  // Sign out if "Remember Me" was not checked on last login.
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

  serviceLocator.registerLazySingleton(() => NotificationService());
}

void _initAuth() {
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerFactory<IAuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetCurrentUser(
        serviceLocator(),
      ),
    )
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
    ..registerFactory(
      () => SendEmailVerification(serviceLocator()),
    )
    ..registerFactory(
      () => CheckEmailVerified(serviceLocator()),
    )
    ..registerFactory(
      () => DeleteCurrentUser(serviceLocator()),
    )
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        forgotPassword: serviceLocator(),
        sendEmailVerification: serviceLocator(),
        checkEmailVerified: serviceLocator(),
        deleteCurrentUser: serviceLocator(),
      ),
    );
}

void _initAgenda() {
  serviceLocator
    ..registerFactory<TaskLocalDataSource>(
      () => TaskLocalDataSourceImpl(serviceLocator()),
    )
    ..registerFactory<TaskRemoteDataSource>(
      () => TaskRemoteDataSourceImpl(serviceLocator()),
    )
    ..registerFactory<ITaskRepository>(
      () => TaskRepositoryImpl(
        localDataSource: serviceLocator(),
        remoteDataSource: serviceLocator(),
        connectivityService: serviceLocator(),
      ),
    )
    ..registerFactory(() => GetTasksByDate(serviceLocator()))
    ..registerFactory(() => CreateTask(serviceLocator(), serviceLocator(), serviceLocator()))
    ..registerFactory(() => UpdateTask(serviceLocator(), serviceLocator(), serviceLocator()))
    ..registerFactory(() => DeleteTask(serviceLocator(), serviceLocator()))
    ..registerFactory(() => ToggleTaskComplete(serviceLocator()))
    ..registerFactory(() => SearchTasks(serviceLocator()))
    ..registerFactory(() => SyncTasks(serviceLocator()))
    ..registerFactory(() => GetTasksForPeriod(serviceLocator()))
    ..registerFactory<CategoryLocalDataSource>(
      () => CategoryLocalDataSourceImpl(serviceLocator()),
    )
    ..registerFactory<CategoryRemoteDataSource>(
      () => CategoryRemoteDataSourceImpl(serviceLocator()),
    )
    ..registerFactory<ICategoryRepository>(
      () => CategoryRepositoryImpl(
        localDataSource: serviceLocator(),
        remoteDataSource: serviceLocator(),
        connectivityService: serviceLocator(),
      ),
    )
    ..registerFactory(() => GetCategories(serviceLocator()))
    ..registerFactory(() => CreateCategory(serviceLocator()))
    ..registerFactory(() => DeleteCategory(serviceLocator()))
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
  serviceLocator.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getTasksForPeriod: serviceLocator(),
      changePassword: serviceLocator(),
      getCurrentUser: serviceLocator(),
      firebaseAuth: serviceLocator(),
    ),
  );
}

void _initPomodoro() {
  serviceLocator
    ..registerFactory<PomodoroPresetLocalDataSource>(
      () => PomodoroPresetLocalDataSourceImpl(serviceLocator()),
    )
    ..registerFactory<PomodoroPresetRemoteDataSource>(
      () => PomodoroPresetRemoteDataSourceImpl(serviceLocator()),
    )
    ..registerFactory<IPomodoroPresetRepository>(
      () => PomodoroRepositoryImpl(
        localDataSource: serviceLocator(),
        remoteDataSource: serviceLocator(),
        connectivityService: serviceLocator(),
      ),
    )
    ..registerFactory(() => GetPresets(serviceLocator()))
    ..registerFactory(() => SavePreset(serviceLocator()))
    ..registerFactory(() => DeletePreset(serviceLocator()))
    ..registerFactory(() => SyncPresets(serviceLocator()))
    ..registerLazySingleton(
      () => PomodoroBloc(
        getPresets: serviceLocator(),
        savePreset: serviceLocator(),
        deletePreset: serviceLocator(),
        syncPresets: serviceLocator(),
        firebaseAuth: serviceLocator(),
        notificationService: serviceLocator(),
        sharedPreferences: serviceLocator(),
        localeNotifier: serviceLocator(),
      ),
    );
}
