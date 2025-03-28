import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmanager/core/routes.dart/app_router.dart';
import 'package:taskmanager/presentation/blocs/auth_cubit.dart';
import 'package:taskmanager/presentation/blocs/events.dart';
import 'package:taskmanager/presentation/blocs/state.dart';
import 'package:taskmanager/presentation/blocs/task_bloc.dart';
import 'package:taskmanager/presentation/widgets/task_card_widget.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  @override
  void initState() {
    super.initState();
    // Load tasks when the page is initialized
    context.read<TaskBloc>().add(LoadTasks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthCubit>().logout();
              Navigator.pushReplacementNamed(context, AppRouter.login);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRouter.createTask),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoaded) {
            if (state.tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tasks yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to add a new task',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TaskCard(
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
                    onDelete: () {
                      context.read<TaskBloc>().add(DeleteTask(task.id));
                    },
                    onToggleComplete: () {
                      final updatedTask = task.copyWith(
                        isCompleted: !task.isCompleted,
                        updatedAt: DateTime.now(),
                      );
                      context.read<TaskBloc>().add(UpdateTask(updatedTask));
                    },
                  ),
                );
              },
            );
          } else if (state is TaskError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.red[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TaskBloc>().add(LoadTasks());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No tasks found.'));
        },
      ),
    );
  }
}
