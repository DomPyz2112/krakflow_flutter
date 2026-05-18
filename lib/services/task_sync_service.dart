import 'task_api_service.dart';
import 'task_local_database.dart';

class TaskSyncService {
  static Future<void> loadInitialDataIfNeeded() async {
    // Jeżeli lokalna baza ma już dane, nie odpytujemy API
    if (!TaskLocalDatabase.isEmpty()) {
      return;
    }
    try {
      // Pobieramy z API i zapisujemy do bazy lokalnej
      final tasks = await TaskApiService.fetchTasks();
      await TaskLocalDatabase.saveTasks(tasks);
    } catch (e) {
      // Logowanie błędu, interfejs obsłuży brak danych
      print("Błąd pobierania danych z API: $e");
    }
  }
}