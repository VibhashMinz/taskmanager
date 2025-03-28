import 'package:flutter/material.dart';
import 'package:taskmanager/presentation/pages/login_page.dart';
import 'package:taskmanager/presentation/pages/signup_page.dart';
import '../../presentation/pages/task_list_page.dart';
import '../../presentation/pages/create_task_page.dart';
import '../../presentation/pages/update_task_page.dart';
import '../../presentation/pages/task_detail_page.dart';
import '../../domain/entities/task.dart';

class AppRouter {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String taskList = '/';
  static const String createTask = '/createTask';
  static const String updateTask = '/updateTask';
  static const String taskDetail = '/taskDetail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case signup:
        return MaterialPageRoute(builder: (_) => const SignupPage());

      case taskList:
        return MaterialPageRoute(builder: (_) => const TaskListPage());

      case createTask:
        return MaterialPageRoute(builder: (_) => const CreateTaskPage());

      case updateTask:
        final task = settings.arguments as Task;
        return MaterialPageRoute(builder: (_) => UpdateTaskPage(task: task));

      case taskDetail:
        final task = settings.arguments as Task;
        return MaterialPageRoute(builder: (_) => TaskDetailPage(task: task));

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
