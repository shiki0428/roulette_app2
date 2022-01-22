import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roulette/roulette.dart';
import 'Arrow.dart';
import 'todo.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// Some keys used for testing
final addTodoKey = UniqueKey();
final activeFilterKey = UniqueKey();
final completedFilterKey = UniqueKey();
final allFilterKey = UniqueKey();

/// Creates a [TodoList] and initialise it with pre-defined values.
///
/// We are using [StateNotifierProvider] here as a `List<Todo>` is a complex
/// object, with advanced business logic like how to edit a todo.
final todoListProvider = StateNotifierProvider<TodoList, List<Todo>>((ref) {
  return TodoList([
    Todo(id: 'todo-0', description: 'hi'),
    Todo(id: 'todo-1', description: 'hello'),
    Todo(id: 'todo-2', description: 'bonjour'),
  ]);
});

final unitListProvider = StateNotifierProvider<UnitList, List<Unit>>((ref) {
  return UnitList([
    Unit(color: Colors.red, text: "aaa", weight: 30),
    Unit(color: Colors.red, text: "bbb", weight: 40),
    Unit(color: Colors.red, text: "ccc", weight: 50)
  ]);
});

/// The different ways to filter the list of todos
enum TodoListFilter {
  all,
  active,
  completed,
}

/// The currently active filter.
///
/// We use [StateProvider] here as there is no fancy logic behind manipulating
/// the value since it's just enum.
final todoListFilter = StateProvider((_) => TodoListFilter.all);

/// The number of uncompleted todos
///
/// By using [Provider], this value is cached, making it performant.\
/// Even multiple widgets try to read the number of uncompleted todos,
/// the value will be computed only once (until the todo-list changes).
///
/// This will also optimise unneeded rebuilds if the todo-list changes, but the
/// number of uncompleted todos doesn't (such as when editing a todo).
final uncompletedTodosCount = Provider<int>((ref) {
  return ref.watch(todoListProvider).where((todo) => !todo.completed).length;
});

/// The list of todos after applying of [todoListFilter].
///
/// This too uses [Provider], to avoid recomputing the filtered list unless either
/// the filter of or the todo-list updates.
final filteredTodos = Provider<List<Todo>>((ref) {
  final filter = ref.watch(todoListFilter);
  final todos = ref.watch(todoListProvider);

  switch (filter) {
    case TodoListFilter.completed:
      return todos.where((todo) => todo.completed).toList();
    case TodoListFilter.active:
      return todos.where((todo) => !todo.completed).toList();
    case TodoListFilter.all:
      return todos;
  }
});

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends HookConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(unitListProvider);
    print(unit[0].weight);
    RouletteUnit a = Unit(color: Colors.blue, weight: 100, text: "aaa");
    var group = RouletteGroup([
      const RouletteUnit(color: Colors.red, weight: 100, text: "aaa"),
      const RouletteUnit(color: Colors.blue, weight: 100, text: "aaa"),
      ...unit,
    ]);
    var _controller = RouletteController(group: group);

    final todos = ref.watch(filteredTodos);
    final newTodoController = useTextEditingController();

    //追加
    final newUnitController = useTextEditingController();
    newUnitController.text = "item";
    final newWeightController = useTextEditingController();
    newWeightController.text = "1";
    Roulette;
    RouletteController;
    RouletteGroup;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          children: [
            const Title(),

            //追加部分
            Card(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.circle),
                    color: Colors.blue.shade400, //ここが変数化できる
                  ),
                  Flexible(
                      child: TextFormField(
                    controller: newUnitController,
                    //initialValue: "item",
                    decoration: const InputDecoration(labelText: "ItemName"),
                  )),
                  Flexible(
                      child: TextFormField(
                    controller: newWeightController,
                    //initialValue: "0",
                    decoration: const InputDecoration(labelText: "weight"),
                  )),
                  IconButton(
                    onPressed: () {
                      print(newUnitController.text);
                      print(newWeightController.text);

                      ref.watch(unitListProvider.notifier).add(
                          newUnitController.text,
                          double.parse(newWeightController.text));

                      newUnitController.text = "item";
                      newWeightController.text = "0";
                    },
                    icon: const Icon(Icons.wallet_giftcard),
                    color: Colors.red, //ここが変数化できる
                  ),
                ],
              ),
            ),

            for (var i = 0; i < unit.length; i++) ...[
              if (i > 0) const Divider(height: 0),
              Dismissible(
                key: ValueKey(unit[i]),
                onDismissed: (_) {
                  //ref.read(unitListProvider.notifier).remove(todos[i]);
                },
                child: ProviderScope(
                  overrides: [
                    _currentUnit.overrideWithValue(unit[i]),
                  ],
                  child: const UnitItem(),
                ),
              )
            ],
            Stack(
              alignment: Alignment.topCenter,
              children: [
                SizedBox(
                  width: 260,
                  height: 260,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Roulette(
                      // Provide controller to update its state
                      controller: _controller,
                      // Configure roulette's appearance
                      style: const RouletteStyle(
                        dividerThickness: 4,
                        textLayoutBias: .8,
                        centerStickerColor: Color(0xFF45A3FA),
                      ),
                    ),
                  ),
                ),
                const Arrow(),
              ],
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          // Run the animation with rollTo method
          onPressed: () => _controller.rollTo(
            0,
            clockwise: true,
            offset: Random().nextDouble(),
          ),
          child: const Icon(Icons.refresh_rounded),
        ),
      ),
    );
  }
}

class Toolbar extends HookConsumerWidget {
  const Toolbar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(todoListFilter);

    Color? textColorFor(TodoListFilter value) {
      return filter == value ? Colors.blue : Colors.black;
    }

    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${ref.watch(uncompletedTodosCount).toString()} items left',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Tooltip(
            key: allFilterKey,
            message: 'All todos',
            child: TextButton(
              onPressed: () =>
                  ref.read(todoListFilter.notifier).state = TodoListFilter.all,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                foregroundColor:
                    MaterialStateProperty.all(textColorFor(TodoListFilter.all)),
              ),
              child: const Text('All'),
            ),
          ),
          Tooltip(
            key: activeFilterKey,
            message: 'Only uncompleted todos',
            child: TextButton(
              onPressed: () => ref.read(todoListFilter.notifier).state =
                  TodoListFilter.active,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                foregroundColor: MaterialStateProperty.all(
                  textColorFor(TodoListFilter.active),
                ),
              ),
              child: const Text('Active'),
            ),
          ),
          Tooltip(
            key: completedFilterKey,
            message: 'Only completed todos',
            child: TextButton(
              onPressed: () => ref.read(todoListFilter.notifier).state =
                  TodoListFilter.completed,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                foregroundColor: MaterialStateProperty.all(
                  textColorFor(TodoListFilter.completed),
                ),
              ),
              child: const Text('Completed'),
            ),
          ),
        ],
      ),
    );
  }
}

class Title extends StatelessWidget {
  const Title({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'todos',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color.fromARGB(38, 47, 47, 247),
        fontSize: 100,
        fontWeight: FontWeight.w100,
        fontFamily: 'Helvetica Neue',
      ),
    );
  }
}

/// A provider which exposes the [Todo] displayed by a [TodoItem].
///
/// By retreiving the [Todo] through a provider instead of through its
/// constructor, this allows [TodoItem] to be instantiated using the `const` keyword.
///
/// This ensures that when we add/remove/edit todos, only what the
/// impacted widgets rebuilds, instead of the entire list of items.
final _currentTodo = Provider<Todo>((ref) => throw UnimplementedError());
final _currentUnit = Provider<Unit>((ref) => throw UnimplementedError());

class UnitItem extends HookConsumerWidget {
  const UnitItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(_currentUnit);
    final itemFocusNode = useFocusNode();
    // listen to focus chances
    useListenable(itemFocusNode);
    final isFocused = itemFocusNode.hasFocus;

    final textEditingController = useTextEditingController();
    final textFieldFocusNode = useFocusNode();

    return Material(
      color: Colors.white,
      elevation: 6,
      child: Container(
        child: ListTile(
          onTap: () {
            itemFocusNode.requestFocus();
            textFieldFocusNode.requestFocus();
          },
          leading: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.circle),
            color: unit.color, //ここが変数化できる
          ),
          title: isFocused
              ? TextField(
                  autofocus: true,
                  focusNode: textFieldFocusNode,
                  controller: textEditingController,
                )
              : Text(unit.text!),
          trailing: isFocused
              ? TextField(
                  autofocus: false,
                  focusNode: textFieldFocusNode,
                  controller: textEditingController,
                )
              : Text(unit.weight.toString()),
        ),
      ),
    );
  }
}

class TodoItem extends HookConsumerWidget {
  const TodoItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = ref.watch(_currentTodo);
    final itemFocusNode = useFocusNode();
    // listen to focus chances
    useListenable(itemFocusNode);
    final isFocused = itemFocusNode.hasFocus;

    final textEditingController = useTextEditingController();
    final textFieldFocusNode = useFocusNode();

    return Material(
      color: Colors.white,
      elevation: 6,
      child: Focus(
        focusNode: itemFocusNode,
        onFocusChange: (focused) {
          if (focused) {
            textEditingController.text = todo.description;
          } else {
            // Commit changes only when the textfield is unfocused, for performance
            ref
                .read(todoListProvider.notifier)
                .edit(id: todo.id, description: textEditingController.text);
          }
        },
        child: ListTile(
          onTap: () {
            itemFocusNode.requestFocus();
            textFieldFocusNode.requestFocus();
          },
          leading: Checkbox(
            value: todo.completed,
            onChanged: (value) =>
                ref.read(todoListProvider.notifier).toggle(todo.id),
          ),
          title: isFocused
              ? TextField(
                  autofocus: true,
                  focusNode: textFieldFocusNode,
                  controller: textEditingController,
                )
              : Text(todo.description),
        ),
      ),
    );
  }
}
