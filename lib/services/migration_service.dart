import 'dart:convert';
import 'package:athan_app_v2/models/task.dart';
import 'package:athan_app_v2/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MigrationResult {
  final bool success;
  final int importedCount;
  final List<String> errors;

  MigrationResult({
    required this.success,
    this.importedCount = 0,
    this.errors = const [],
  });
}

class MigrationService {
  final StorageService _storageService = StorageService();
  static const String _backupPrefix = 'tasks_backup_';

  Future<MigrationResult> importFromJson(String jsonString) async {
    final List<String> errors = [];
    try {
      // 1. Backup existing data
      await createBackup();

      final dynamic decodedData = json.decode(jsonString);
      if (decodedData is! List) {
         return MigrationResult(success: false, errors: ['Invalid JSON format: Expected a list of events']);
      }
      
      final List<dynamic> data = decodedData;

      if (data.isEmpty) {
        return MigrationResult(success: true, importedCount: 0);
      }

      // 2. Transformation & Validation
      final List<Task> tasks = [];
      for (var i = 0; i < data.length; i++) {
        try {
          final item = data[i];
          // Basic validation
          if (item['title'] == null) {
            errors.add('Item at index $i missing title');
            continue;
          }
          if (item['start'] == null) {
            errors.add('Item at index $i missing start date');
            continue;
          }
           if (item['end'] == null) {
            errors.add('Item at index $i missing end date');
            continue;
          }

          final startDate = DateTime.parse(item['start']);
          final endDate = DateTime.parse(item['end']);
          final duration = endDate.difference(startDate);

          if (duration.isNegative) {
            errors.add('Item at index $i: End date is before start date');
            continue;
          }

          // Map to Task model
          final task = Task(
            id: item['id'], // Preserve ID if possible, otherwise Task constructor generates one
            title: item['title'],
            description: item['description'],
            date: startDate,
            startTime: startDate,
            duration: duration,
            category: _mapCategory(item['color']),
            priority: TaskPriority.medium,
            isRecurring: false,
            isCompleted: false,
          );
          tasks.add(task);
        } catch (e) {
          errors.add('Error processing item at index $i: $e');
        }
      }

      // 3. Import
      if (tasks.isNotEmpty) {
        await _storageService.saveTasks(tasks);
      }

      return MigrationResult(
        success: errors.isEmpty,
        importedCount: tasks.length,
        errors: errors,
      );

    } catch (e) {
      return MigrationResult(success: false, errors: ['Global error: $e']);
    }
  }

  TaskCategory _mapCategory(String? color) {
    // Simple mapping logic based on color, can be expanded
    if (color == null) return TaskCategory.other;
    
    // Example mapping
    switch (color.toLowerCase()) {
      case '#d0f3e9': return TaskCategory.work;
      case '#ff0000': return TaskCategory.health;
      case '#00ff00': return TaskCategory.religious;
      default: return TaskCategory.other;
    }
  }

  Future<String?> createBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupKey = '$_backupPrefix$timestamp';
      await prefs.setString(backupKey, tasksJson);
      return backupKey;
    }
    return null;
  }

  Future<List<String>> getBackups() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys().where((key) => key.startsWith(_backupPrefix)).toList();
  }

  Future<bool> restoreBackup(String backupKey) async {
    final prefs = await SharedPreferences.getInstance();
    final backupData = prefs.getString(backupKey);
    if (backupData != null) {
      await prefs.setString('tasks', backupData);
      return true;
    }
    return false;
  }
}
