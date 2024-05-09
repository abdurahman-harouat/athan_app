import 'package:athan_app_v2/local_notification_service.dart';
import 'package:athan_app_v2/screens/checking_permission_page.dart';
import 'package:athan_app_v2/theme.dart';
import 'package:flutter/material.dart';

import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: const MaterialTheme(TextTheme()).light(),
      darkTheme: const MaterialTheme(TextTheme()).dark(),
      home: const HomePage(),
    );
  }
}
