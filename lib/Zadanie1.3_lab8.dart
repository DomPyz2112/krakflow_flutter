import 'dart:convert';

void main() {
  String jsonText = '''
  {
    "product": {
      "name": "Laptop",
      "price": 3500
    }
  }
  ''';

  final data = jsonDecode(jsonText);

  print("Produkt: ${data["product"]["name"]}");
  print("Cena: ${data["product"]["price"]}");
}