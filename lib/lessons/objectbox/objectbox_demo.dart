import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

import '../../core/lesson_scaffold.dart';
import 'todo_entity.dart';
import '../../objectbox.g.dart'; // Will be generated

class ObjectBoxLessonPage extends StatelessWidget {
  const ObjectBoxLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonScaffold(
      title: 'High-Performance NoSQL: ObjectBox',
      overview:
          'ObjectBox is a super-fast NoSQL database optimized for Flutter. It uses C++ bindings to offer performance up to 10x faster than SQLite/Hive for complex operations.',
      steps: const [
        StepContent(
          title: '1. Why ObjectBox?',
          description:
              'ObjectBox is an "Object Database". You store Dart objects directly. It supports ACID transactions, zero-copy reads, and is cross-platform.',
        ),
        StepContent(
          title: '2. Entities (@Entity)',
          description:
              'Define your models with `@Entity()`. The generator creates a "Box" for each entity. IDs are usually `int` and auto-incrementing.',
          codeSnippet: '''
@Entity()
class User {
  @Id()
  int id = 0;
  String name;
}''',
        ),
        StepContent(
          title: '3. Queries & Streams',
          description:
              'ObjectBox queries are extremely fast and can be "watched" to create reactive streams that update your UI automatically when data changes.',
          codeSnippet: '''
Stream<List<User>> stream = 
    box.query(User_.name.equals('Bob')).watch(triggerImmediately: true)
       .map((query) => query.find());
''',
        ),
        StepContent(
          title: '4. Setup (Store)',
          description:
              'You need to open a `Store` once (usually in `main.dart` or a singleton). This holds the connection to the DB file.',
        ),
      ],
      demo: const ObjectBoxDemo(),
    );
  }
}

class ObjectBoxDemo extends StatefulWidget {
  const ObjectBoxDemo({super.key});

  @override
  State<ObjectBoxDemo> createState() => _ObjectBoxDemoState();
}

class _ObjectBoxDemoState extends State<ObjectBoxDemo> {
  Store? _store;
  Box<TodoEntity>? _box;
  Stream<List<TodoEntity>>? _stream;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initObjectBox();
  }

  Future<void> _initObjectBox() async {
    final docsDir = await getApplicationDocumentsDirectory();
    // Unique directory for this specific demo to avoid conflicts
    final storeDir = Directory('${docsDir.path}/objectbox_demo');

    // Create/Open the Store
    // Note: In a real app, do this ONCE in main() and pass the store down
    try {
      if (Store.isOpen('${docsDir.path}/objectbox_demo')) {
        _store = Store.attach(
          getObjectBoxModel(),
          '${docsDir.path}/objectbox_demo',
        );
      } else {
        _store = await openStore(directory: storeDir.path);
      }
    } catch (e) {
      // Fallback if store is already open elsewhere or model changed (just for demo safety)
      // In production you handle this more gracefully
      debugPrint("Store init error (might be open): $e");
      // Try to recover or just show error
      return;
    }

    _box = _store!.box<TodoEntity>();

    setState(() {
      _stream = _box!
          .query()
          .order(TodoEntity_.dateCreated, flags: Order.descending)
          .watch(triggerImmediately: true)
          .map((query) => query.find());
    });
  }

  @override
  void dispose() {
    // Only close store if we are sure we are done.
    // In this specific demo page lifecycle, we close it to be clean.
    _store?.close();
    _controller.dispose();
    super.dispose();
  }

  void _addTodo() {
    if (_controller.text.isEmpty || _box == null) return;
    final todo = TodoEntity(task: _controller.text);
    _box!.put(todo);
    _controller.clear();
  }

  void _toggle(TodoEntity todo) {
    todo.isCompleted = !todo.isCompleted;
    _box!.put(todo);
  }

  void _delete(int id) {
    _box!.remove(id);
  }

  @override
  Widget build(BuildContext context) {
    if (_store == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'New Task',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addTodo(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _addTodo,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<TodoEntity>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: Text("Waiting for data..."));
                }
                final todos = snapshot.data!;
                if (todos.isEmpty) {
                  return const Center(child: Text("No tasks yet. Add one!"));
                }
                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: todo.isCompleted,
                          onChanged: (_) => _toggle(todo),
                        ),
                        title: Text(
                          todo.task,
                          style: TextStyle(
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: todo.isCompleted ? Colors.grey : null,
                          ),
                        ),
                        subtitle: Text(
                          todo.dateCreated.toString().split('.')[0],
                          style: const TextStyle(fontSize: 10),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _delete(todo.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
