import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

// Auth dependencies
import 'package:taskmanager/data/repositories/auth_repository_impl.dart';
import 'package:taskmanager/domain/repositories/auth_repository.dart';
import 'package:taskmanager/domain/usecases/auth_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmanager/presentation/blocs/auth_cubit.dart';
//task
import 'package:taskmanager/data/repositories/task_repository_impl.dart';
import 'package:taskmanager/data/sources/local/task_local_data_source.dart';
import 'package:taskmanager/data/sources/remote/tast_remote_data_source.dart';
import 'package:taskmanager/domain/repositories/task_repository.dart';
import 'package:taskmanager/presentation/blocs/task_bloc.dart';

final getIt = GetIt.instance;

void init({required bool useSQLite}) {
  // Register Firebase dependencies
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Register Auth Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<FirebaseAuth>(),
      getIt<GoogleSignIn>(),
      getIt<FirebaseFirestore>(),
    ),
  );

  // Register Auth Use Cases
  getIt.registerLazySingleton(() => SignInWithGoogleUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignUpWithEmailUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LoginWithEmailUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => ForgotPasswordUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));

  // Register Auth Cubit
  getIt.registerFactory(
    () => AuthCubit(
      signInWithGoogleUseCase: getIt<SignInWithGoogleUseCase>(),
      signUpWithEmailUseCase: getIt<SignUpWithEmailUseCase>(),
      loginWithEmailUseCase: getIt<LoginWithEmailUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
    ),
  );

  // Register Remote (Firebase Firestore) for tasks
  getIt.registerLazySingleton<TaskRemoteDataSource>(
    () => FirebaseTaskRemoteDataSource(firestore: getIt<FirebaseFirestore>()),
  );

  // Register Local (Hive or SQLite based on the flag)
  if (useSQLite) {
    getIt.registerLazySingleton<TaskLocalDataSource>(
      () => SQLiteTaskLocalDataSource(),
    );
  } else {
    getIt.registerLazySingleton<TaskLocalDataSource>(
      () => HiveTaskLocalDataSource(taskBox: Hive.box('tasks')),
    );
  }

  // Register Task Repository
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      localDataSource: getIt<TaskLocalDataSource>(),
      remoteDataSource: getIt<TaskRemoteDataSource>(),
    ),
  );

  // Register Task Bloc
  getIt.registerFactory(() => TaskBloc(repository: getIt<TaskRepository>()));
}
