import 'package:athan_app_v2/local_notification_service.dart';
import 'package:athan_app_v2/models/data_model.dart';
import 'package:athan_app_v2/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  var box = await Hive.openBox('athan_box');
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await LocalNotificationService.init();
  runApp(ChangeNotifierProvider(
    create: (context) => DataModel(),
    child: const MainApp(),
  ));
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
