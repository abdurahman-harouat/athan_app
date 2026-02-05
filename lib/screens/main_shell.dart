import 'dart:ui' as ui;
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:athan_app_v2/screens/calendar_screen.dart';
import 'package:athan_app_v2/screens/home_screen.dart';
import 'package:athan_app_v2/screens/settings_screen.dart';
import 'package:athan_app_v2/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Scaffold;

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // GlobalKey to access CalendarScreen state for refreshing data
  final GlobalKey<CalendarScreenState> _calendarKey =
      GlobalKey<CalendarScreenState>();

  late final List<Widget> _screens = [
    const HomeScreen(),
    CalendarScreen(key: _calendarKey),
    const SettingsScreen(),
  ];

  final List<IconData> _iconList = [
    CupertinoIcons.house_fill,
    CupertinoIcons.calendar,
    CupertinoIcons.settings,
  ];

  final List<String> _labelList = [
    'الرئيسية',
    'التقويم',
    'الإعدادات',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: AnimatedBottomNavigationBar.builder(
          itemCount: _iconList.length,
          tabBuilder: (index, isActive) {
            final color = isActive ? colors.primary : colors.textSecondary;
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _iconList[index],
                  size: 24,
                  color: color,
                ),
                const SizedBox(height: 4),
                Text(
                  _labelList[index],
                  style: AppTextStyles.labelSmall(context).copyWith(
                    color: color,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          },
          backgroundColor: colors.surface,
          activeIndex: _currentIndex,
          splashColor: colors.primary.withOpacity(0.1),
          splashSpeedInMilliseconds: 300,
          notchSmoothness: NotchSmoothness.softEdge,
          gapLocation: GapLocation.none,
          leftCornerRadius: 24,
          rightCornerRadius: 24,
          elevation: 8,
          shadow: BoxShadow(
            offset: const Offset(0, -4),
            blurRadius: 20,
            color: colors.blackWithOpacity(0.08),
          ),
          onTap: (index) {
            setState(() => _currentIndex = index);
            // Refresh calendar data when switching to calendar tab
            if (index == 1) {
              _calendarKey.currentState?.refreshData();
            }
          },
        ),
      ),
    );
  }
}
