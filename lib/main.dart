import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  String name = "Jan";

  final List<Task> tasks = [
    Task(title: "Projekt z matematyki", deadline: "za tydzień", done: false, priority: "Wysoki"),
    Task(title: "Nauczyc sie do kolokwium", deadline: "dzisiaj", done: true, priority: "Wysoki"),
    Task(title: "Rozwiazac krzyzówke", deadline: "w tym tygodniu", done: false, priority: "Niski"),
    Task(title: "rozwiazac zadanie", deadline: "pojutrze", done: false, priority: "Średni"),
    Task(title: "Wysłać CV do pracy", deadline: "za dwa tygodnie", done: false, priority: "Wysoki"),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text("KrakFlow"),
          ),
          body: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Masz dziś ${tasks.length} zadania",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 22),
                      Text(
                        "Dzisiejsze zadania",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Expanded(child:
                        ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return TaskCard(
                                title: task.title,
                                subtitle: "termin: ${task.deadline} | ważność ${task.priority}",
                                icon: task.done ? Icons.check_circle : Icons.radio_button_unchecked,
                              );
                            }
                        )
                      )
                    ],
              )
          ),
      ),
    );
  }
}

class Task {
  final String title;
  final String deadline;
  final bool done;
  final String priority;
  Task({
    required this.title,
    required this.deadline,
    this.done = false,
    required this.priority
  });
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

