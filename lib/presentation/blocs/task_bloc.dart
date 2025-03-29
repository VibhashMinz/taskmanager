import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmanager/domain/repositories/task_repository.dart';

import 'package:taskmanager/presentation/blocs/events.dart';
import 'package:taskmanager/presentation/blocs/state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;

  TaskBloc({required this.repository}) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await repository.getTasks();
      log('task: $tasks');
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError('Failed to load tasks'));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        emit(TaskError('User not logged in!'));
        return;
      }

      final newTask = event.task.copyWith(userId: userId);

      // Optimistically add the task to the current state
      if (state is TaskLoaded) {
        final currentState = state as TaskLoaded;
        final updatedTasks = [...currentState.tasks, newTask];
        emit(TaskLoaded(updatedTasks));
      }

      // Add task to repository
      await repository.addTask(newTask);
    } catch (e) {
      // If add fails, revert to original state
      if (state is TaskLoaded) {
        final currentState = state as TaskLoaded;
        emit(TaskLoaded(currentState.tasks));
      }
      emit(TaskError('Failed to add task'));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      final updatedTasks = currentState.tasks.map((task) {
        return task.id == event.task.id ? event.task : task;
      }).toList();

      // Immediately emit new state with updated task
      emit(TaskLoaded(updatedTasks));

      try {
        // Update in repository
        await repository.updateTask(event.task);
      } catch (e) {
        // If update fails, revert to original state
        emit(TaskLoaded(currentState.tasks));
        emit(TaskError('Failed to update task'));
      }
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      final updatedTasks = currentState.tasks.where((task) => task.id != event.id).toList();

      // Immediately emit new state without the deleted task
      emit(TaskLoaded(updatedTasks));

      try {
        await repository.deleteTask(event.id);
      } catch (e) {
        // If delete fails, revert to original state
        emit(TaskLoaded(currentState.tasks));
        emit(TaskError('Failed to delete task'));
      }
    }
  }
}
