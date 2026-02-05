import 'dart:convert';
import 'package:athan_app_v2/models/settings.dart';
import 'package:athan_app_v2/models/task.dart';
import 'package:athan_app_v2/services/prayer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tasksKey = 'tasks';
  static const String _settingsKey = 'app_settings';
  static final StorageService _instance = StorageService._internal();
  SharedPreferences? _prefs;

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Tasks Methods
  Future<List<Task>> getTasksForDate(DateTime date) async {
    await initialize();
    final allTasks = await getAllTasks();
    return allTasks.where((task) {
      return task.date.year == date.year &&
          task.date.month == date.month &&
          task.date.day == date.day;
    }).toList();
  }

  Future<List<Task>> getAllTasks() async {
    await initialize();
    final String? jsonData = _prefs?.getString(_tasksKey);
    if (jsonData == null || jsonData.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> data = json.decode(jsonData);
      return data.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTask(Task task) async {
    await initialize();
    final tasks = await getAllTasks();
    final existingIndex = tasks.indexWhere((t) => t.id == task.id);
    if (existingIndex >= 0) {
      tasks[existingIndex] = task;
    } else {
      tasks.add(task);
    }
    await _saveAllTasks(tasks);
  }

  Future<void> saveTasks(List<Task> newTasks) async {
    await initialize();
    final tasks = await getAllTasks();
    for (final task in newTasks) {
      final existingIndex = tasks.indexWhere((t) => t.id == task.id);
      if (existingIndex >= 0) {
        tasks[existingIndex] = task;
      } else {
        tasks.add(task);
      }
    }
    await _saveAllTasks(tasks);
  }

  Future<void> deleteTask(String taskId) async {
    await initialize();
    final tasks = await getAllTasks();
    tasks.removeWhere((t) => t.id == taskId);
    await _saveAllTasks(tasks);
  }

  Future<void> _saveAllTasks(List<Task> tasks) async {
    final String jsonData = json.encode(tasks.map((t) => t.toJson()).toList());
    await _prefs?.setString(_tasksKey, jsonData);
  }

  // Settings Methods
  Future<AppSettings> getSettings() async {
    await initialize();
    final String? jsonData = _prefs?.getString(_settingsKey);
    if (jsonData == null || jsonData.isEmpty) {
      return AppSettings();
    }
    try {
      final Map<String, dynamic> data = json.decode(jsonData);
      return AppSettings.fromJson(data);
    } catch (e) {
      return AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await initialize();
    final String jsonData = json.encode(settings.toJson());
    await _prefs?.setString(_settingsKey, jsonData);
  }

  // Analytics Methods
  Future<DailyTasksSummary> getDailySummary(
    DateTime date,
    PrayerService prayerService,
  ) async {
    await initialize();
    final tasks = await getTasksForDate(date);
    final settings = await getSettings();

    // Get prayer times for the date
    final year = date.year;
    final month = date.month;
    final key = 'prayer_times_${year}_$month';
    final prayerDays = await prayerService.loadPrayerTimes(key);

    Duration totalPrayerTime = Duration.zero;
    Duration totalTravelTime = Duration.zero;
    final Map<String, Duration> travelTimesByPrayer = {};

    if (prayerDays.isNotEmpty && date.day <= prayerDays.length) {
      final prayerDay = prayerDays[date.day - 1];
      final prayers = {
        'Fajr': prayerDay.timings.fajr,
        'Dhuhr': prayerDay.timings.dhuhr,
        'Asr': prayerDay.timings.asr,
        'Maghrib': prayerDay.timings.maghrib,
        'Isha': prayerDay.timings.isha,
      };

      // Fixed 10 minutes for each prayer
      const prayerDuration = Duration(minutes: 10);
      totalPrayerTime = prayerDuration * 5;

      prayers.forEach((prayerName, _) {
        final travelMinutes =
            settings.travelTimeSettings.getTravelTimeForPrayer(prayerName);
        final travelDuration = Duration(minutes: travelMinutes);
        travelTimesByPrayer[prayerName] = travelDuration;
        totalTravelTime += travelDuration * 2; // Going and returning
      });
    }

    return DailyTasksSummary(
      date: date,
      tasks: tasks,
      totalPrayerTime: totalPrayerTime,
      totalTravelTime: totalTravelTime,
      travelTimesByPrayer: travelTimesByPrayer,
    );
  }

  // Check for prayer conflicts
  Future<List<Map<String, dynamic>>> getPrayerTimeBlocks(
    DateTime date,
    PrayerService prayerService,
  ) async {
    await initialize();
    final settings = await getSettings();
    final year = date.year;
    final month = date.month;
    final key = 'prayer_times_${year}_$month';
    final prayerDays = await prayerService.loadPrayerTimes(key);

    if (prayerDays.isEmpty || date.day > prayerDays.length) {
      return [];
    }

    final prayerDay = prayerDays[date.day - 1];
    final blocks = <Map<String, dynamic>>[];

    final prayers = [
      {'name': 'Fajr', 'time': prayerDay.timings.fajr},
      {'name': 'Dhuhr', 'time': prayerDay.timings.dhuhr},
      {'name': 'Asr', 'time': prayerDay.timings.asr},
      {'name': 'Maghrib', 'time': prayerDay.timings.maghrib},
      {'name': 'Isha', 'time': prayerDay.timings.isha},
    ];

    for (final prayer in prayers) {
      final prayerName = prayer['name'] as String;
      final timeString = prayer['time'] as String;
      final parts = timeString.split(':');
      final prayerTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      final travelMinutes =
          settings.travelTimeSettings.getTravelTimeForPrayer(prayerName);
      final travelDuration = Duration(minutes: travelMinutes);

      // Block: departure time -> return time
      // departure = prayer time - travel time
      // return = prayer time + 10 min prayer + travel time
      final departureTime = prayerTime.subtract(travelDuration);
      final returnTime =
          prayerTime.add(const Duration(minutes: 10)).add(travelDuration);

      blocks.add({
        'prayerName': prayerName,
        'start': departureTime,
        'end': returnTime,
      });
    }

    return blocks;
  }

  Future<bool> hasConflictWithPrayer(
    DateTime date,
    DateTime startTime,
    Duration duration,
    PrayerService prayerService,
  ) async {
    final blocks = await getPrayerTimeBlocks(date, prayerService);
    final endTime = startTime.add(duration);

    for (final block in blocks) {
      final blockStart = block['start'] as DateTime;
      final blockEnd = block['end'] as DateTime;

      // Check for overlap
      if (startTime.isBefore(blockEnd) && endTime.isAfter(blockStart)) {
        return true;
      }
    }

    return false;
  }

  // Import/Export Methods
  Future<String> exportData() async {
    await initialize();
    final tasksJson = _prefs?.getString(_tasksKey);
    final settingsJson = _prefs?.getString(_settingsKey);
    
    final Map<String, dynamic> exportMap = {
      'version': 1,
      'timestamp': DateTime.now().toIso8601String(),
      'tasks': tasksJson != null ? json.decode(tasksJson) : [],
      'settings': settingsJson != null ? json.decode(settingsJson) : null,
    };
    
    return json.encode(exportMap);
  }

  Future<void> importData(String jsonString) async {
    await initialize();
    try {
      final Map<String, dynamic> data = json.decode(jsonString);
      
      // Import Tasks
      if (data.containsKey('tasks')) {
        final tasksList = data['tasks'];
        await _prefs?.setString(_tasksKey, json.encode(tasksList));
      }
      
      // Import Settings
      if (data.containsKey('settings') && data['settings'] != null) {
        final settingsMap = data['settings'];
        await _prefs?.setString(_settingsKey, json.encode(settingsMap));
      }
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }
}
