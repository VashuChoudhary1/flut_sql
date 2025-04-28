import 'package:app_sql/todo_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';

class TodoListScreen extends StatefulWidget {
  static const routeName = '/todos';

  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final todoProvider = Provider.of<TodoProvider>(context, listen: false);
      todoProvider
          .fetchTodos(authProvider.userId ?? 5); // Default fallback user id
    });
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: todoProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : todoProvider.todos.isEmpty
              ? const Center(child: Text('No todos found!'))
              : ListView.builder(
                  itemCount: todoProvider.todos.length,
                  itemBuilder: (ctx, i) =>
                      TodoTile(todo: todoProvider.todos[i]),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          todoProvider.addTodoDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
