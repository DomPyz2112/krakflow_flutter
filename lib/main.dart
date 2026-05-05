import 'package:flutter/material.dart';
import 'services/task_api_service.dart';
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
  State<MojEkranGlownyAplikacji> createState() =>
      _MojEkranGlownyAplikacjiState();
}

class _MojEkranGlownyAplikacjiState
    extends State<MojEkranGlownyAplikacji> {
  String selectedFilter = "wszystkie";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KrakFlow"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Lista zadań z API",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                future: TaskApiService.fetchTasks(),
                builder: (context, snapshot) {

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Błąd: ${snapshot.error}"),
                    );
                  }

                  final tasks = snapshot.data!;

                  List<Task> filteredTasks = tasks;
                  if (selectedFilter == "wykonane") {
                    filteredTasks =
                        tasks.where((t) => t.done).toList();
                  } else if (selectedFilter == "do zrobienia") {
                    filteredTasks =
                        tasks.where((t) => !t.done).toList();
                  }

                  return ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];

                      return TaskCard(
                        title: task.title,
                        subtitle:
                        "termin: ${task.deadline} | ważność ${task.priority}",
                        done: task.done,
                        onChanged: (value) {
                          setState(() {
                            task.done = value ?? false;
                          });
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
            decoration:
            done ? TextDecoration.lineThrough : TextDecoration.none,
            color: done ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}