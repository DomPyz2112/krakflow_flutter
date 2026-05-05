import 'dart:convert';

void main() {
  String jsonText = '''
  {
    "group": "Dart",
    "students": ["Ola", "Adam", "Kasia"]
  }
  ''';

  final data = jsonDecode(jsonText);

  print("Grupa: ${data["group"]}");

  for (var student in data["students"]) {
    print(student);
  }
}