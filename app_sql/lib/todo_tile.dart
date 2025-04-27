import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;

  const TodoTile({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);

    return Dismissible(
      key: ValueKey(todo.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        todoProvider.deleteTodo(todo);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 4,
        child: ListTile(
          leading: Checkbox(
            value: todo.completed,
            onChanged: (value) {
              todoProvider.toggleTodoStatus(todo);
            },
          ),
          title: Text(
            todo.todo,
            style: TextStyle(
              decoration: todo.completed ? TextDecoration.lineThrough : null,
            ),
          ),
          trailing: todo.completed
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
        ),
      ),
    );
  }
}
