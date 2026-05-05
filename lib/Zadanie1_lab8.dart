import 'dart:convert';

void main() {
  String jsonText = '''
  [1, 5, 8, 3, 2]
  ''';

  final data = jsonDecode(jsonText);

  int suma = 0;

  for (int liczba in data) {
    print(liczba);
    suma += liczba;
  }

  print("Suma: $suma");
}