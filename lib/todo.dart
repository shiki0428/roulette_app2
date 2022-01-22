import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:roulette/roulette.dart';

const _uuid = Uuid();

class Unit extends RouletteUnit {
  Unit({
    required this.color,
    required this.text,
    required this.weight,
  }) : super.noText();
  //colorpickerというものが良さそう
  //text と　weight は　form から行ける

  final Color color;
  final String? text;
  final double weight;
}

class UnitList extends StateNotifier<List<Unit>> {
  UnitList([List<Unit>? initialTodos]) : super(initialTodos ?? []);

  // 機能面での追加を後で...
  //最低限add delete update

  void add(text, weight) {
    state = [...state, Unit(color: Colors.red, text: text, weight: weight)];
  }
}

/// A read-only description of a todo-item
class Todo {
  Todo({
    required this.description,
    required this.id,
    this.completed = false,
  });

  final String id;
  final String description;
  final bool completed;

  @override
  String toString() {
    return 'Todo(description: $description, completed: $completed)';
  }
}

/// An object that controls a list of [Todo].
class TodoList extends StateNotifier<List<Todo>> {
  TodoList([List<Todo>? initialTodos]) : super(initialTodos ?? []);

  void add(String description) {
    state = [
      ...state,
      Todo(
        id: _uuid.v4(),
        description: description,
      ),
    ];
  }

  void toggle(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            id: todo.id,
            completed: !todo.completed,
            description: todo.description,
          )
        else
          todo,
    ];
  }

  void edit({required String id, required String description}) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            id: todo.id,
            completed: todo.completed,
            description: description,
          )
        else
          todo,
    ];
  }

  void remove(Todo target) {
    state = state.where((todo) => todo.id != target.id).toList();
  }
}
