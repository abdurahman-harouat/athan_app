import 'package:athan_app_v2/screens/home_screen.dart';
import 'package:athan_app_v2/services/prayer_notitfication_service.dart';
import 'package:athan_app_v2/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrayerNotificationService.initialize();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'مواقيت الصلاة',
      theme: CupertinoThemeData(
        brightness: MediaQuery.platformBrightnessOf(context),
        primaryColor: CupertinoColors.systemBlue,
        barBackgroundColor: CupertinoColors.systemBackground,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontWeight: FontWeight.w400,
            fontSize: 18.0,
            height: 1.5,
            decoration: TextDecoration.none,
          ),
          actionTextStyle: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontWeight: FontWeight.w400,
            fontSize: 20.0,
            height: 1.4,
            color: CupertinoColors.systemBlue,
            decoration: TextDecoration.none,
          ),
          navTitleTextStyle: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontWeight: FontWeight.w400,
            fontSize: 22.0,
            height: 1.35,
            decoration: TextDecoration.none,
          ),
          navLargeTitleTextStyle: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontWeight: FontWeight.w300,
            fontSize: 36.0,
            height: 1.25,
            letterSpacing: -0.25,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      home: HomeScreen(),
      locale: Locale('ar', 'DZ'),
    );
  }
}
