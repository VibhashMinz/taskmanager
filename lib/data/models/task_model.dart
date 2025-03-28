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

  @override
  @HiveField(4)
  final DateTime createdAt;

  @override
  @HiveField(5)
  final String description;

  @override
  @HiveField(6)
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.userId,
    this.description = '',
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? createdAt ?? DateTime.now(),
        super(
          id: id,
          title: title,
          userId: userId,
          description: description,
          isCompleted: isCompleted,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// ✅ Convert JSON to TaskModel (for SQLite & Firebase)
  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        userId: json['userId'],
        isCompleted: json['isCompleted'] == 1 ? true : false,
        createdAt: json['createdAt'] != null ? (json['createdAt'] is DateTime ? json['createdAt'] : DateTime.fromMillisecondsSinceEpoch(json['createdAt'].millisecondsSinceEpoch)) : DateTime.now(),
        updatedAt: json['updatedAt'] != null ? (json['updatedAt'] is DateTime ? json['updatedAt'] : DateTime.fromMillisecondsSinceEpoch(json['updatedAt'].millisecondsSinceEpoch)) : DateTime.now(),
      );

  /// ✅ Convert TaskModel to JSON (for SQLite & Firebase)
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'userId': userId,
        'isCompleted': isCompleted ? 1 : 0,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  /// ✅ Convert Task Entity → TaskModel
  factory TaskModel.fromEntity(Task task) => TaskModel(
        id: task.id,
        title: task.title,
        description: task.description,
        userId: task.userId,
        isCompleted: task.isCompleted,
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
      );

  /// ✅ Convert TaskModel → Task Entity
  Task toEntity() => Task(
        id: id,
        title: title,
        description: description,
        userId: userId,
        isCompleted: isCompleted,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
