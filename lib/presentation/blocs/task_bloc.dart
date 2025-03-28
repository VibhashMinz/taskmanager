import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
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
      await repository.addTask(event.task);
      add(LoadTasks());
    } catch (e) {
      emit(TaskError('Failed to add task'));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await repository.updateTask(event.task);
      add(LoadTasks());
    } catch (e) {
      emit(TaskError('Failed to update task'));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await repository.deleteTask(event.id);
      add(LoadTasks());
    } catch (e) {
      emit(TaskError('Failed to delete task'));
    }
  }
}
