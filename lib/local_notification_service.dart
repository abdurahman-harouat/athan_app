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

  static onTap(NotificationResponse notificationResponse) {}
  static Future init() async {
    InitializationSettings settings = const InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/launcher_icon"));
    flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: onTap,
      onDidReceiveBackgroundNotificationResponse: onTap,
    );
  }

  //basic Notification
  // static void showBasicNotification() async {
  //   AndroidNotificationDetails android = const AndroidNotificationDetails(
  //     'id 1',
  //     'basic notification',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );

  //   NotificationDetails details = NotificationDetails(
  //     android: android,
  //   );
  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     'Baisc Notification',
  //     'body',
  //     details,
  //     payload: "Payload Data",
  //   );
  // }

  //showSchduledNotification
  static void showSchduledNotification(int year, int month, int day, int hour,
      int minute, String nextPrayerName) async {
    AndroidNotificationDetails android = const AndroidNotificationDetails(
        'schduled notification', 'id 3',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('notification'));
    NotificationDetails details = NotificationDetails(
      android: android,
    );
    tz.initializeTimeZones();
    // log(tz.local.name);
    // log("Before ${tz.TZDateTime.now(tz.local).hour}");
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    // log(currentTimeZone);
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
    // log(tz.local.name);
    // log("After ${tz.TZDateTime.now(tz.local).hour}");
    await flutterLocalNotificationsPlugin.zonedSchedule(
      2,
      'يرجى الإستعداد لصلاة $nextPrayerName',
      '',
      // tz.TZDateTime.now(tz.local).add(const Duration(seconds: 2)),
      tz.TZDateTime(
        tz.local,
        year,
        month,
        day,
        hour,
        minute,
      ),
      details,
      payload: 'zonedSchedule',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
