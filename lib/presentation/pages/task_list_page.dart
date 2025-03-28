import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmanager/core/routes.dart/app_router.dart';
import 'package:taskmanager/presentation/blocs/events.dart';
import 'package:taskmanager/presentation/blocs/state.dart';
import 'package:taskmanager/presentation/blocs/task_bloc.dart';
import 'package:taskmanager/presentation/widget/task_card_widget.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Manager')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRouter.createTask),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoaded) {
            return ListView.builder(
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return TaskCard(
                  task: task,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.taskDetail,
                      arguments: task,
                    );
                  },
                  onEdit: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.updateTask,
                      arguments: task,
                    );
                  },
                  onToggleComplete: () {
                    final updatedTask = task.copyWith(
                      isCompleted: !task.isCompleted,
                    );
                    context.read<TaskBloc>().add(UpdateTask(updatedTask));
                  },
                );
              },
            );
          }
          return const Center(child: Text('No tasks found.'));
        },
      ),
    );
  }
}
