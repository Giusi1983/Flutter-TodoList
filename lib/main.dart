import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo List',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final List<Map<String, dynamic>> _todos = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  // Carica i ToDo salvati
  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? todos = prefs.getStringList('todos');
    if (todos != null) {
      setState(() {
        _todos.addAll(
          todos.map((todo) => {"text": todo, "completed": false}).toList(),
        );
      });
    }
  }

  // Salva i ToDo
  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> todos = _todos.map((todo) => todo['text'] as String).toList();
    prefs.setStringList('todos', todos);
  }

  // Aggiungi un nuovo ToDo
  void _addTodo() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _todos.add({"text": _controller.text, "completed": false});
      });
      _controller.clear();
      _saveTodos();
    }
  }

  // Rimuovi un ToDo
  void _removeTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
    _saveTodos();
  }

  // Marca un ToDo come completato o non completato
  void _toggleCompletion(int index) {
    setState(() {
      _todos[index]['completed'] = !_todos[index]['completed'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ToDo List'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Add a new task',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addTodo,
                ),
              ),
            ),
          ),
          Expanded(
            child: _todos.isEmpty
                ? Center(child: Text('No tasks yet!'))
                : ListView.builder(
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: UniqueKey(),
                        onDismissed: (direction) {
                          _removeTodo(index);
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20.0),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ListTile(
                          title: Text(
                            _todos[index]['text'],
                            style: TextStyle(
                              decoration: _todos[index]['completed']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          leading: Checkbox(
                            value: _todos[index]['completed'],
                            onChanged: (bool? value) {
                              _toggleCompletion(index);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
