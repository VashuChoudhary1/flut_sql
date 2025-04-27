// lib/providers/todo_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/todo.dart';

class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];
  bool _isLoading = false;

  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;

  // Fetch all todos for a user
  Future<void> fetchTodos(int userId) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse('https://dummyjson.com/todos/user/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> todoList = data['todos'];

        _todos = todoList.map((item) => Todo.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load todos');
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new todo (show dialog + post to API)
  Future<void> addTodoDialog(BuildContext context) async {
    final TextEditingController _controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Todo'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Todo title'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter a title';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop();
                final url = Uri.parse('https://dummyjson.com/todos/add');

                try {
                  final response = await http.post(
                    url,
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({
                      'todo': _controller.text,
                      'completed': false,
                      'userId': 5, // static userId
                    }),
                  );

                  if (response.statusCode == 200 ||
                      response.statusCode == 201) {
                    final data = json.decode(response.body);
                    final newTodo = Todo.fromJson(data);
                    _todos.add(newTodo);
                    notifyListeners();
                  } else {
                    throw Exception('Failed to add todo');
                  }
                } catch (e) {
                  debugPrint(e.toString());
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Delete todo (API + remove locally)
  Future<void> deleteTodo(Todo todo) async {
    final url = Uri.parse('https://dummyjson.com/todos/${todo.id}');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        _todos.removeWhere((item) => item.id == todo.id);
        notifyListeners();
      } else {
        throw Exception('Failed to delete todo');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Toggle complete/incomplete locally
  void toggleTodoStatus(Todo todo) {
    todo.completed = !todo.completed;
    notifyListeners();
  }
}
