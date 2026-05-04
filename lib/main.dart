import 'package:flutter/material.dart';
import 'task_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "KrakFlow",
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MojEkranGlownyAplikacji(),
    );
  }
}

class MojEkranGlownyAplikacji extends StatefulWidget {
  const MojEkranGlownyAplikacji({super.key});

  @override
  State<MojEkranGlownyAplikacji> createState() => _MojEkranGlownyAplikacjiState();
}

class _MojEkranGlownyAplikacjiState extends State<MojEkranGlownyAplikacji> {
  String selectedFilter = "wszystkie";

  void _deleteAllTasks() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Potwierdzenie"),
        content: const Text("Czy na pewno chcesz usunąć wszystkie zadania?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Anuluj"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                TaskRepository.tasks.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Wszystkie zadania usunięte")),
              );
            },
            child: const Text("Usuń", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Task> filteredTasks = TaskRepository.tasks;
    if (selectedFilter == "wykonane") {
      filteredTasks = TaskRepository.tasks.where((t) => t.done).toList();
    } else if (selectedFilter == "do zrobienia") {
      filteredTasks = TaskRepository.tasks.where((t) => !t.done).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("KrakFlow"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: TaskRepository.tasks.isEmpty ? null : _deleteAllTasks, // Opcjonalne rozszerzenie
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Masz dziś ${TaskRepository.tasks.length} zadań",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _filterButton("wszystkie", "Wszystkie"),
                _filterButton("do zrobienia", "Do zrobienia"),
                _filterButton("wykonane", "Wykonane"),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return Dismissible(
                    key: ObjectKey(task),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        TaskRepository.tasks.remove(task);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Usunięto: ${task.title}")),
                      );
                    },
                    child: TaskCard(
                      title: task.title,
                      subtitle: "termin: ${task.deadline} | ważność ${task.priority}",
                      done: task.done,
                      onChanged: (bool? value) {
                        setState(() {
                          task.done = value ?? false;
                        });
                      },
                      onTap: () async {
                        final updatedTask = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTaskScreen(task: task),
                          ),
                        );
                        if (updatedTask != null) {
                          setState(() {
                            final idx = TaskRepository.tasks.indexOf(task);
                            TaskRepository.tasks[idx] = updatedTask;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
          if (newTask != null) {
            setState(() {
              TaskRepository.tasks.add(newTask);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _filterButton(String filter, String label) {
    bool isActive = selectedFilter == filter;
    return TextButton(
      onPressed: () => setState(() => selectedFilter = filter),
      style: TextButton.styleFrom(foregroundColor: isActive ? Colors.blue : Colors.grey),
      child: Text(label),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.onChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(value: done, onChanged: onChanged),
        title: Text(
          title,
          style: TextStyle(
            decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
            color: done ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class EditTaskScreen extends StatefulWidget {
  final Task task;
  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController deadlineController;
  late TextEditingController priorityController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    deadlineController = TextEditingController(text: widget.task.deadline);
    priorityController = TextEditingController(text: widget.task.priority);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edytuj zadanie")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Tytuł:")),
            const SizedBox(height: 16),
            TextField(controller: deadlineController, decoration: const InputDecoration(labelText: "Termin:")),
            const SizedBox(height: 16),
            TextField(controller: priorityController, decoration: const InputDecoration(labelText: "Priorytet:")),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final updated = Task(
                  title: titleController.text,
                  deadline: deadlineController.text,
                  priority: priorityController.text,
                  done: widget.task.done,
                );
                Navigator.pop(context, updated);
              },
              child: const Text("Zaktualizuj"),
            ),
          ],
        ),
      ),
    );
  }
}

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final titleController = TextEditingController();
  final deadlineController = TextEditingController();
  final priorityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nowe zadanie")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Tytuł zadania:")),
            const SizedBox(height: 16),
            TextField(controller: deadlineController, decoration: const InputDecoration(labelText: "Termin:")),
            const SizedBox(height: 16),
            TextField(controller: priorityController, decoration: const InputDecoration(labelText: "Priorytet:")),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, Task(
                  title: titleController.text,
                  deadline: deadlineController.text,
                  priority: priorityController.text,
                  done: false,
                ));
              },
              child: const Text("Zapisz"),
            ),
          ],
        ),
      ),
    );
  }
}


