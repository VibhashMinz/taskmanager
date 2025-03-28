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
      await repository.addTask(newTask);
      add(LoadTasks());
    } catch (e) {
      emit(TaskError('Failed to add task'));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      final updatedTasks = currentState.tasks.map((task) {
        return task.id == event.task.id ? event.task : task;
      }).toList();

      emit(TaskLoaded(updatedTasks));

      try {
        await repository.updateTask(event.task);
      } catch (e) {
        emit(TaskLoaded(currentState.tasks));
        emit(TaskError('Failed to update task'));
      }
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      final updatedTasks = currentState.tasks.where((task) => task.id != event.id).toList();

      emit(TaskLoaded(updatedTasks));

      try {
        await repository.deleteTask(event.id);
      } catch (e) {
        emit(TaskLoaded(currentState.tasks));
        emit(TaskError('Failed to delete task'));
      }
    }
  }
}
