class Task {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.userId,
    this.description = '',
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  /// ✅ Copy with method to create modified instances
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? userId,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Task(id: $id, title: $title, description: $description, userId: $userId, isCompleted: $isCompleted, createdAt: $createdAt, updatedAt: $updatedAt)';
}
