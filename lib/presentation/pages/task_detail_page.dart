import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';

class TaskDetailPage extends StatelessWidget {
  final Task task;

  const TaskDetailPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${task.title}', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),
            Text('Completed: ${task.isCompleted ? "Yes" : "No"}'),
          ],
        ),
      ),
    );
  }
}
