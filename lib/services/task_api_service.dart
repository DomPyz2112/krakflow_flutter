import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class TaskApiService {
  static const String baseUrl = "https://dummyjson.com";

  static final Random random = Random();

  static const List<String> priorities = [
    "niski",
    "średni",
    "wysoki"
  ];

  static const List<String> deadlines = [
    "dzisiaj",
    "jutro",
    "za 2 dni",
    "w tym tygodniu",
    "za tydzień"
  ];

  static Future<List<Task>> fetchTasks() async {
    final response = await http.get(
      Uri.parse("$baseUrl/todos"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List todos = data["todos"];

      return todos.map((todo) {
        final priority = priorities[random.nextInt(priorities.length)];
        final deadline = deadlines[random.nextInt(deadlines.length)];

        return Task(
          id: todo["id"] as int,
          title: todo["todo"],
          deadline: deadline,
          priority: priority,
          done: todo["completed"],
        );
      }).toList();

    } else {
      throw Exception("Błąd pobierania danych z API");
    }
  }
}