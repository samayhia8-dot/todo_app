
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/todo_model.dart';
import '../data/todo_repository.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodos extends TodoEvent {}

class AddTodoRequested extends TodoEvent {
  final String title;
  final String description;

  const AddTodoRequested({
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [title, description];
}

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodosLoaded extends TodoState {
  final List<TodoModel> todos;

  const TodosLoaded(this.todos);

  @override
  List<Object?> get props => [todos];
}

class TodoSaveSuccess extends TodoState {}

class TodoFailure extends TodoState {
  final String message;

  const TodoFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository _repository;

  TodoBloc(this._repository) : super(TodoInitial()) {
    on<LoadTodos>((event, emit) async {
      emit(TodoLoading());

      try {
        final todos = await _repository.fetchTodos();
        emit(TodosLoaded(todos));
      } catch (error) {
        emit(
          TodoFailure(
            'Failed to load tasks. Please try again.',
          ),
        );
      }
    });

    on<AddTodoRequested>((event, emit) async {
      emit(TodoLoading());

      try {
        await _repository.addTodo(
          title: event.title,
          description: event.description,
        );

        emit(TodoSaveSuccess());
      } catch (error) {
        emit(
          TodoFailure(
            'Failed to save task. Please try again.',
          ),
        );
      }
    });
  }
}
