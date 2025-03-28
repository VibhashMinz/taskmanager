import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmanager/core/routes.dart/app_router.dart';
import 'package:taskmanager/core/services/database_initializer.dart';
import 'package:taskmanager/presentation/blocs/auth_cubit.dart';
import 'package:taskmanager/presentation/blocs/task_bloc.dart';
import 'package:taskmanager/core/theme/app_theme.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Toggle between SQLite (true) or Hive (false)
  const bool useSQLite = false;

  // Initialize database and dependencies
  await DatabaseInitializer.initialize(useSQLite: useSQLite);
  init(useSQLite: useSQLite);

  // Retrieve stored user ID to determine if user is logged in
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('user_id');

  runApp(MyApp(initialRoute: userId == null ? AppRouter.login : AppRouter.taskList));

  //runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => getIt<AuthCubit>(), // Provide AuthCubit for authentication
        ),
        BlocProvider<TaskBloc>(
          create: (context) => getIt<TaskBloc>(), // Provide TaskBloc for managing tasks
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Task Manager',
        theme: AppTheme.lightTheme,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: initialRoute, // Determines if login or task list should show first
      ),
    );
  }
}
