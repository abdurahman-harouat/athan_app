import 'package:uuid/uuid.dart';

enum TaskCategory {
  work,
  personal,
  religious,
  health,
  social,
  other,
}

enum TaskPriority {
  low,
  medium,
  high,
}

extension TaskCategoryExtension on TaskCategory {
  String get displayName {
    switch (this) {
      case TaskCategory.work:
        return 'عمل';
      case TaskCategory.personal:
        return 'شخصي';
      case TaskCategory.religious:
        return 'ديني';
      case TaskCategory.health:
        return 'صحة';
      case TaskCategory.social:
        return 'اجتماعي';
      case TaskCategory.other:
        return 'أخرى';
    }
  }

  String get iconName {
    switch (this) {
      case TaskCategory.work:
        return 'briefcase';
      case TaskCategory.personal:
        return 'person';
      case TaskCategory.religious:
        return 'moon';
      case TaskCategory.health:
        return 'heart';
      case TaskCategory.social:
        return 'person_2';
      case TaskCategory.other:
        return 'tag';
    }
  }
}

extension TaskPriorityExtension on TaskPriority {
  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'منخفض';
      case TaskPriority.medium:
        return 'متوسط';
      case TaskPriority.high:
        return 'عالي';
    }
  }

  int get value {
    switch (this) {
      case TaskPriority.low:
        return 1;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.high:
        return 3;
    }
  }
}

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final DateTime startTime;
  final Duration duration;
  final TaskCategory category;
  final TaskPriority priority;
  final bool isRecurring;
  final bool isCompleted;

  Task({
    String? id,
    required this.title,
    this.description,
    required this.date,
    required this.startTime,
    required this.duration,
    this.category = TaskCategory.other,
    this.priority = TaskPriority.medium,
    this.isRecurring = false,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  DateTime get endTime => startTime.add(duration);

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    DateTime? startTime,
    Duration? duration,
    TaskCategory? category,
    TaskPriority? priority,
    bool? isRecurring,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isRecurring: isRecurring ?? this.isRecurring,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'durationMinutes': duration.inMinutes,
      'category': category.name,
      'priority': priority.name,
      'isRecurring': isRecurring,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      startTime: DateTime.parse(json['startTime']),
      duration: Duration(minutes: json['durationMinutes']),
      category: TaskCategory.values.byName(json['category']),
      priority: TaskPriority.values.byName(json['priority']),
      isRecurring: json['isRecurring'],
      isCompleted: json['isCompleted'],
    );
  }
}

class DailyTasksSummary {
  final DateTime date;
  final List<Task> tasks;
  final Duration totalPrayerTime;
  final Duration totalTravelTime;
  final Map<String, Duration> travelTimesByPrayer;

  DailyTasksSummary({
    required this.date,
    required this.tasks,
    required this.totalPrayerTime,
    required this.totalTravelTime,
    required this.travelTimesByPrayer,
  });

  Duration get totalTasksDuration {
    return tasks.fold(
      Duration.zero,
      (sum, task) => sum + task.duration,
    );
  }

  Duration get totalCommittedTime {
    return totalPrayerTime + totalTravelTime + totalTasksDuration;
  }

  Duration get remainingDiscretionaryTime {
    const dayDuration = Duration(hours: 24);
    final remaining = dayDuration - totalCommittedTime;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  double get committedTimePercentage {
    const dayMinutes = 24 * 60;
    final committedMinutes = totalCommittedTime.inMinutes;
    return (committedMinutes / dayMinutes * 100).clamp(0, 100);
  }
}
