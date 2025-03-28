class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final String userId;

  Task({
    required this.id,
    required this.title,
    required this.userId,
    this.isCompleted = false,
  });

  /// ✅ Copy with method to create modified instances
  Task copyWith({
    String? id,
    String? title,
    String? userId,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  String toString() => 'Task(id: $id, title: $title,userId: $userId, isCompleted: $isCompleted)';
}
