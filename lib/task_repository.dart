import 'main.dart';

class TaskRepository {
  static List<Task> tasks = [
    Task(title: "Projekt z matematyki", deadline: "za tydzień", done: false, priority: "Wysoki"),
    Task(title: "Nauczyć się do kolokwium", deadline: "dzisiaj", done: true, priority: "Wysoki"),
    Task(title: "Rozwiązać krzyżówkę", deadline: "w tym tygodniu", done: false, priority: "Niski"),
    Task(title: "Rozwiązać zadanie", deadline: "pojutrze", done: false, priority: "Średni"),
    Task(title: "Wysłać CV do pracy", deadline: "za dwa tygodnie", done: false, priority: "Wysoki"),
  ];
}

class Task {
  final String title;
  final String deadline;
  final bool done;
  final String priority;

  Task({
    required this.title,
    required this.deadline,
    required this.priority,
    this.done = false,
  });
}