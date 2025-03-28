import 'package:hive/hive.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:taskmanager/core/services/database_initializer.dart';
import '../../models/task_model.dart';

/// Abstract Interface for Local Data Sources
abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<void> cacheTasks(List<TaskModel> tasks);
}

/// Hive Implementation
class HiveTaskLocalDataSource implements TaskLocalDataSource {
  final Box<TaskModel> taskBox;

  HiveTaskLocalDataSource({required this.taskBox});

  @override
  Future<List<TaskModel>> getTasks() async {
    return taskBox.values.toList();
  }

  @override
  Future<void> addTask(TaskModel task) async {
    await taskBox.put(task.id, task);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await taskBox.put(task.id, task); // Hive overwrites existing record
  }

  @override
  Future<void> deleteTask(String id) async {
    await taskBox.delete(id);
  }

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    await taskBox.clear();
    for (var task in tasks) {
      await taskBox.put(task.id, task);
    }
  }
}

/// SQLite Implementation (Using DatabaseInitializer)
class SQLiteTaskLocalDataSource implements TaskLocalDataSource {
  late Database _database;

  SQLiteTaskLocalDataSource() {
    _database = DatabaseInitializer.sqliteDatabase; // Access centralized DB
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    final tasks = await _database.query('tasks');
    return tasks.map((task) => TaskModel.fromJson(task)).toList();
  }

  @override
  Future<void> addTask(TaskModel task) async {
    await _database.insert('tasks', task.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await _database.update('tasks', task.toJson(), where: 'id = ?', whereArgs: [task.id]);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _database.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    await _database.delete('tasks');
    for (var task in tasks) {
      await addTask(task);
    }
  }
}
