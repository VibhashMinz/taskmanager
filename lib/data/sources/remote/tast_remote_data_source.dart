import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskmanager/data/models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
}

class FirebaseTaskRemoteDataSource implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;

  FirebaseTaskRemoteDataSource({required this.firestore});

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      var snapshot = await firestore.collection('tasks').get();

      if (snapshot.docs.isEmpty) {
        print("No tasks found in Firestore.");
        return [];
      }

      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            if (data == null || data.isEmpty) {
              print("Invalid document data: ${doc.id}");
              return null;
            }
            return TaskModel.fromJson(data);
          })
          .whereType<TaskModel>()
          .toList();
    } catch (e) {
      print("Error fetching tasks: $e");
      throw Exception("Failed to fetch tasks");
    }
  }

  @override
  Future<void> addTask(TaskModel task) async {
    try {
      if (task.id == null || task.id!.isEmpty) {
        print("Task ID is missing!");
        throw Exception("Task ID is required");
      }

      await firestore.collection('tasks').doc(task.id).set(task.toJson());
      print("Task added successfully: ${task.id}");
    } catch (e) {
      print("Error adding task: $e");
      throw Exception("Failed to add task");
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      if (task.id == null || task.id!.isEmpty) {
        print("Cannot update task without an ID!");
        throw Exception("Task ID is required");
      }

      await firestore.collection('tasks').doc(task.id).update(task.toJson());
      print("Task updated successfully: ${task.id}");
    } catch (e) {
      print("Error updating task: $e");
      throw Exception("Failed to update task");
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      if (id.isEmpty) {
        print("Task ID is missing for deletion!");
        throw Exception("Task ID is required");
      }

      await firestore.collection('tasks').doc(id).delete();
      print("Task deleted successfully: $id");
    } catch (e) {
      print("Error deleting task: $e");
      throw Exception("Failed to delete task");
    }
  }
}
