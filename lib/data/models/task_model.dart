import 'package:hive/hive.dart';
import '../../domain/entities/task.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends Task {
  @override
  @HiveField(0)
  final String id;

  @override
  @HiveField(1)
  final String title;

  @override
  @HiveField(2)
  final bool isCompleted;

  @override
  @HiveField(3) // ✅ Add userId to Hive storage
  final String userId;

  TaskModel({
    required this.id,
    required this.title,
    required this.userId,
    this.isCompleted = false,
  }) : super(id: id, title: title, userId: userId, isCompleted: isCompleted);

  /// ✅ Convert JSON to TaskModel (for SQLite & Firebase)
  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'],
        title: json['title'],
        userId: json['userId'],
        isCompleted: json['isCompleted'] == 1 ? true : false,
      );

  /// ✅ Convert TaskModel to JSON (for SQLite & Firebase)
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'userId': userId,
        'isCompleted': isCompleted ? 1 : 0,
      };

  /// ✅ Convert Task Entity → TaskModel
  factory TaskModel.fromEntity(Task task) => TaskModel(
        id: task.id,
        title: task.title,
        userId: task.userId,
        isCompleted: task.isCompleted,
      );

  /// ✅ Convert TaskModel → Task Entity
  Task toEntity() => Task(
        id: id,
        title: title,
        userId: userId,
        isCompleted: isCompleted,
      );
}
