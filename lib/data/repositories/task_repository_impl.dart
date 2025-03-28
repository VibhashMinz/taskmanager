import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';
import '../sources/local/task_local_data_source.dart';
import '../sources/remote/tast_remote_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({required this.localDataSource, required this.remoteDataSource});

  @override
  Future<List<Task>> getTasks() async {
    try {
      final remoteTasks = await remoteDataSource.getTasks();
      await localDataSource.cacheTasks(remoteTasks);
      return remoteTasks;
    } catch (e) {
      return localDataSource.getTasks();
    }
  }

  @override
  Future<void> addTask(Task task) async {
    final taskModel = TaskModel.fromEntity(task);
    await localDataSource.addTask(taskModel);
    await remoteDataSource.addTask(taskModel);
  }

  @override
  Future<void> updateTask(Task task) async {
    final taskModel = TaskModel.fromEntity(task);
    await localDataSource.updateTask(taskModel);
    await remoteDataSource.updateTask(taskModel);
  }

  @override
  Future<void> deleteTask(String id) async {
    await localDataSource.deleteTask(id);
    await remoteDataSource.deleteTask(id);
  }
}
