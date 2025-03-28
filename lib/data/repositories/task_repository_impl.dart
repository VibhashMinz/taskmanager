import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';
import '../sources/local/task_local_data_source.dart';
import '../sources/remote/task_remote_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  /// ✅ Fetch user ID from SharedPreferences
  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  @override
  Future<List<Task>> getTasks() async {
    try {
      final userId = await _getUserId();
      if (userId == null) return []; // If no user is logged in, return empty list.

      final remoteTasks = await remoteDataSource.getTasks(userId);
      await localDataSource.cacheTasks(remoteTasks);
      return remoteTasks;
    } catch (e) {
      return localDataSource.getTasks();
    }
  }

  @override
  Future<void> addTask(Task task) async {
    final userId = await _getUserId();
    if (userId == null) return; // Prevent adding task if user is not logged in.

    final taskWithUserId = task.copyWith(userId: userId);
    final taskModel = TaskModel.fromEntity(taskWithUserId);

    await localDataSource.addTask(taskModel);
    await remoteDataSource.addTask(taskModel);
  }

  @override
  Future<void> updateTask(Task task) async {
    final userId = await _getUserId();
    if (userId == null) return;

    final taskWithUserId = task.copyWith(userId: userId);
    final taskModel = TaskModel.fromEntity(taskWithUserId);

    await localDataSource.updateTask(taskModel);
    await remoteDataSource.updateTask(taskModel);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final userId = await _getUserId();
    if (userId == null) return;

    await localDataSource.deleteTask(taskId);
    await remoteDataSource.deleteTask(userId, taskId); // ✅ Pass both userId & taskId
  }
}
