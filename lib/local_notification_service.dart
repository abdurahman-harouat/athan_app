import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  // Unique ID for each prayer to ensure multiple notifications
  static const Map<String, int> prayerNotificationIds = {
    'Fajr': 1,
    'Dhuhr': 2,
    'Asr': 3,
    'Maghrib': 4,
    'Isha': 5
  };

  static onTap(NotificationResponse notificationResponse) {
    // Optional: Add any specific action when notification is tapped
  }

  static Future init() async {
    InitializationSettings settings = InitializationSettings(
        android: const AndroidInitializationSettings("@mipmap/launcher_icon"),
        iOS: DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
            onDidReceiveLocalNotification: (int id, String? title, String? body,
                String? payload) async {}));

    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: onTap,
      onDidReceiveBackgroundNotificationResponse: onTap,
    );

    // Request notification permissions on Android 13+
    if (androidImplementation != null) {
      await androidImplementation!.requestNotificationsPermission();
    }
  }

  // Enhanced scheduled notification method
  static void showSchduledNotification(
      {required int year,
      required int month,
      required int day,
      required int hour,
      required int minute,
      required String nextPrayerName}) async {
    // Create unique notification ID based on prayer name
    int notificationId = prayerNotificationIds[nextPrayerName] ?? 0;

    // Configure Android-specific notification details
    AndroidNotificationDetails android = const AndroidNotificationDetails(
      'prayer_notifications',
      'Prayer Time Alerts',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('notification'),
      // Allow multiple notifications to be shown
      ongoing: false,
      autoCancel: true,
    );

    // Create notification details
    NotificationDetails details = NotificationDetails(
        android: android, iOS: const DarwinNotificationDetails());

    // Initialize time zones
    tz.initializeTimeZones();

    // Get current device time zone
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // Schedule the notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'يرجى الإستعداد لصلاة $nextPrayerName',
      '',
      tz.TZDateTime(
        tz.local,
        year,
        month,
        day,
        hour,
        minute,
      ),
      details,
      payload: 'prayer_notification',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents
          .time, // This is key for daily recurring notifications
    );
  }

  // Method to cancel a specific prayer notification if needed
  static Future<void> cancelPrayerNotification(String prayerName) async {
    int notificationId = prayerNotificationIds[prayerName] ?? 0;
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  // Method to cancel all prayer notifications
  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
