import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmanager/presentation/blocs/events.dart';
import 'package:taskmanager/presentation/blocs/task_bloc.dart';
import '../../domain/entities/task.dart';

import 'package:uuid/uuid.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _createTask() {
    if (_titleController.text.isNotEmpty) {
      final newTask = Task(
        id: const Uuid().v4(),
        title: _titleController.text,
        userId: '',
      );
      context.read<TaskBloc>().add(AddTask(newTask));
      Navigator.pop(context); // Navigate back after adding
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Task Title'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createTask,
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}
