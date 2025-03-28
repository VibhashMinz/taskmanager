import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskmanager/data/models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks(String userId);
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String userId, String taskId);
}

class FirebaseTaskRemoteDataSource implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;

  FirebaseTaskRemoteDataSource({required this.firestore});

  @override
  Future<List<TaskModel>> getTasks(String userId) async {
    try {
      var snapshot = await firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId) // ✅ Fetch only user's tasks
          .orderBy('createdAt', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        log("No tasks found for user: $userId");
        return [];
      }

      return snapshot.docs.map((doc) => TaskModel.fromJson(doc.data())).toList();
    } catch (e) {
      log("Error fetching tasks: $e");
      throw Exception("Failed to fetch tasks");
    }
  }

  @override
  Future<void> addTask(TaskModel task) async {
    try {
      if (task.id.isEmpty || task.userId == null) {
        log("Task ID or userId is missing!");
        throw Exception("Task ID and userId are required");
      }

      await firestore.collection('tasks').doc(task.id).set(task.toJson());

      log("Task added successfully: ${task.id}");
    } catch (e) {
      log("Error adding task: $e");
      throw Exception("Failed to add task");
    }
  }

  /// ✅ Update task in the user's document
  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      if (task.id.isEmpty || task.userId == null) {
        log("Cannot update task without an ID and userId!");
        throw Exception("Task ID and userId are required");
      }

      await firestore.collection('tasks').doc(task.id).update(task.toJson());

      log("Task updated successfully: ${task.id}");
    } catch (e) {
      log("Error updating task: $e");
      throw Exception("Failed to update task");
    }
  }

  @override
  Future<void> deleteTask(String userId, String taskId) async {
    try {
      if (taskId.isEmpty) {
        log("Task ID is missing for deletion!");
        throw Exception("Task ID is required");
      }

      await firestore.collection('tasks').doc(taskId).delete();

      log("Task deleted successfully: $taskId");
    } catch (e) {
      log("Error deleting task: $e");
      throw Exception("Failed to delete task");
    }
  }
}
