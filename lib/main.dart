import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'models/task.dart';
import 'services/task_local_database.dart';
import 'services/task_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("tasks");
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
  late Future<List<Task>> tasksFuture;

  int allTasksCount = 0;
  int doneTasksCount = 0;
  int todoTasksCount = 0;

  @override
  void initState() {
    super.initState();
    tasksFuture = loadTasks();
  }

  Future<List<Task>> loadTasks() async {
    await TaskSyncService.loadInitialDataIfNeeded();
    final tasks = TaskLocalDatabase.getTasks();
    updateCounters(tasks);
    return tasks;
  }

  void updateCounters(List<Task> tasks) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        allTasksCount = tasks.length;
        doneTasksCount = tasks.where((task) => task.done).length;
        todoTasksCount = tasks.where((task) => !task.done).length;
      });
    });
  }

  void refreshData() {
    setState(() {
      final currentTasks = TaskLocalDatabase.getTasks();
      tasksFuture = Future.value(currentTasks);
      updateCounters(currentTasks);
    });
  }

  void clearAll() async {
    await TaskLocalDatabase.deleteAllTasks();
    refreshData();
  }

  void _pokazOknoDodawaniaZadania(BuildContext context) {
    final tytulController = TextEditingController();
    final terminController = TextEditingController();
    String wybranyPriorytet = "średni";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Dodaj nowe zadanie"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tytulController,
                      decoration: const InputDecoration(
                        labelText: "Nazwa zadania",
                        hintText: "np. Nauczyć się na kolokwium",
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: terminController,
                      decoration: const InputDecoration(
                        labelText: "Termin",
                        hintText: "np. jutro, 25 maja",
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Ważność:", style: TextStyle(fontSize: 16)),
                        DropdownButton<String>(
                          value: wybranyPriorytet,
                          items: const [
                            DropdownMenuItem(value: "niski", child: Text("Niski")),
                            DropdownMenuItem(value: "średni", child: Text("Średni")),
                            DropdownMenuItem(value: "wysoki", child: Text("Wysoki")),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                wybranyPriorytet = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Anuluj"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (tytulController.text.trim().isEmpty) return;

                    final currentTasks = TaskLocalDatabase.getTasks();
                    final safeId = currentTasks.length + 1000 + DateTime.now().second;

                    final noweZadanie = Task(
                      id: safeId,
                      title: tytulController.text.trim(),
                      deadline: terminController.text.trim().isEmpty
                          ? "brak terminu"
                          : terminController.text.trim(),
                      priority: wybranyPriorytet,
                      done: false,
                    );

                    await TaskLocalDatabase.addTask(noweZadanie);
                    Navigator.pop(context);
                    refreshData();
                  },
                  child: const Text("Dodaj"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KrakFlow"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: "Usuń wszystkie zadania",
            onPressed: clearAll,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _counterBadge("Wszystkie", allTasksCount),
                _counterBadge("Do zrobienia", todoTasksCount),
                _counterBadge("Wykonane", doneTasksCount),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Lista zadań (Lokalna baza Hive)",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              child: FutureBuilder<List<Task>>(
                future: tasksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Błąd: ${snapshot.error}"));
                  }

                  final tasks = snapshot.data ?? [];

                  if (tasks.isEmpty) {
                    return const Center(child: Text("Brak zadań w bazie."));
                  }

                  List<Task> filteredTasks = tasks;
                  if (selectedFilter == "wykonane") {
                    filteredTasks = tasks.where((t) => t.done).toList();
                  } else if (selectedFilter == "do zrobienia") {
                    filteredTasks = tasks.where((t) => !t.done).toList();
                  }

                  return ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];

                      return TaskCard(
                        title: task.title,
                        subtitle: "termin: ${task.deadline} | ważność: ${task.priority}",
                        done: task.done,
                        onChanged: (value) async {
                          final updatedTask = Task(
                            id: task.id,
                            title: task.title,
                            deadline: task.deadline,
                            priority: task.priority,
                            done: value ?? false,
                          );
                          await TaskLocalDatabase.updateTask(updatedTask);
                          refreshData();
                        },
                        onDelete: () async {
                          await TaskLocalDatabase.deleteTask(task.id);
                          refreshData();
                        },
                        onTap: () {},
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pokazOknoDodawaniaZadania(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _filterButton(String filter, String label) {
    bool isActive = selectedFilter == filter;
    return TextButton(
      onPressed: () => setState(() => selectedFilter = filter),
      style: TextButton.styleFrom(
        foregroundColor: isActive ? Colors.blue : Colors.grey,
      ),
      child: Text(label),
    );
  }

  Widget _counterBadge(String label, int count) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "$count",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.onChanged,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
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
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ),
    );
  }
}