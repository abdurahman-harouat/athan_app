import 'dart:async';
import 'dart:convert';

import 'package:athan_app_v2/models/hijri_date_model.dart';
import 'package:athan_app_v2/models/timings_model.dart';
import 'package:athan_app_v2/utils/current_time.dart';
import 'package:athan_app_v2/utils/formatCurrentDate.dart';
import 'package:athan_app_v2/utils/location.dart';
import 'package:athan_app_v2/local_notification_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class DataModel extends ChangeNotifier {
  final athan_box = Hive.box('athan_box');

  // Declare variables
  late DateTime nextPrayerTime;
  late String nextPrayerName;
  late DateTime prayerReminderTime;
  late DateTime jumuaaPrayerReminder;
  bool isFriday = false;
  final DateTime _currentDate = DateTime.now();
  String formattedCurrentDate = formatDateReverse(DateTime.now());
  String formattedTommorowDate =
      formatDateReverse(DateTime.now().add(const Duration(days: 1)));
  late Duration difference;
  List<TimingsModel> prayerTimingsOfTheMonth = [];
  List<HijriDateModel> hijriDateOfTheMonth = [];
  int currentIndex = DateTime.now().day - 1;
  late double latitude;
  late double longitude;
  late String? locationName;

  // Initialize data
  Future<void> initializeData() async {
    var storage = athan_box.get('athan_data');
    if (storage == null || storage.isEmpty) {
      await _getLocation();
      await _storeLocationData();
    } else {
      _loadStoredLocationData(storage);
    }
    await _fetchPrayerTimes();
    _calculateNextPrayerTime();
    scheduledNotification();
  }

  // Get user's location
  Future<void> _getLocation() async {
    Position position = await UsersLocation.determineLocation();
    latitude = position.latitude;
    longitude = position.longitude;
  }

  // Store location data
  Future<void> _storeLocationData() async {
    setLocaleIdentifier("ar_DZ");
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    locationName = placemarks[0].locality;
    athan_box.put('athan_data', [latitude, longitude, locationName]);
  }

  // Load stored location data
  void _loadStoredLocationData(List storage) {
    latitude = storage[0];
    longitude = storage[1];
    locationName = storage[2];
  }

  // Fetch prayer times from API
  Future<void> _fetchPrayerTimes() async {
    var response = await http.get(Uri.https(
      'api.aladhan.com',
      '/v1/calendar/${_currentDate.year}/${_currentDate.month}',
      {'latitude': '$latitude', 'longitude': '$longitude'},
    ));

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      _populatePrayerTimings(jsonData['data']);
    } else {
      throw Error();
    }
  }

  // Populate prayer timings and hijri dates
  void _populatePrayerTimings(List<dynamic> data) {
    for (var item in data) {
      var timings = item['timings'];
      prayerTimingsOfTheMonth.add(TimingsModel.fromJson(timings));

      var hijri = item['date']['hijri'];
      hijriDateOfTheMonth.add(HijriDateModel.fromJson(hijri));
    }
  }

  // Calculate next prayer time and related data
  void _calculateNextPrayerTime() {
    DateTime fajrTime =
        _getPrayerTime(prayerTimingsOfTheMonth[currentIndex].fajr, 'fajr');
    DateTime dhuhrTime =
        _getPrayerTime(prayerTimingsOfTheMonth[currentIndex].dhuhr, 'dhuhr');
    DateTime asrTime =
        _getPrayerTime(prayerTimingsOfTheMonth[currentIndex].asr, 'asr');
    DateTime maghribTime = _getPrayerTime(
        prayerTimingsOfTheMonth[currentIndex].maghrib, 'maghrib');
    DateTime ishaTime =
        _getPrayerTime(prayerTimingsOfTheMonth[currentIndex].isha, 'isha');
    DateTime tomorrowFajrTime = _getPrayerTime(
        prayerTimingsOfTheMonth[currentIndex + 1].fajr, 'fajr', true);

    isFriday = hijriDateOfTheMonth[currentIndex].arabicWeekDay == "الجمعة";

    if (currentTime.isBefore(fajrTime)) {
      _setNextPrayerData(
          'الفجر', fajrTime, fajrTime.subtract(const Duration(minutes: 10)));
    } else if (currentTime.isAfter(fajrTime) &&
        currentTime.isBefore(dhuhrTime)) {
      _setNextPrayerData(
          'الظهر', dhuhrTime, dhuhrTime.subtract(const Duration(minutes: 5)));
      if (isFriday) {
        jumuaaPrayerReminder = dhuhrTime.subtract(const Duration(minutes: 30));
      }
    } else if (currentTime.isAfter(dhuhrTime) &&
        currentTime.isBefore(asrTime)) {
      _setNextPrayerData(
          'العصر', asrTime, asrTime.subtract(const Duration(minutes: 5)));
    } else if (currentTime.isAfter(asrTime) &&
        currentTime.isBefore(maghribTime)) {
      _setNextPrayerData('المغرب', maghribTime,
          maghribTime.subtract(const Duration(minutes: 10)));
    } else if (currentTime.isAfter(maghribTime) &&
        currentTime.isBefore(ishaTime)) {
      _setNextPrayerData(
          'العشاء', ishaTime, ishaTime.subtract(const Duration(minutes: 5)));
    } else if (currentTime.isAfter(ishaTime)) {
      _setNextPrayerData('الفجر', tomorrowFajrTime,
          tomorrowFajrTime.subtract(const Duration(minutes: 10)));
    }
  }

  // Set next prayer data
  void _setNextPrayerData(String name, DateTime time, DateTime reminder) {
    nextPrayerName = name;
    nextPrayerTime = time;
    prayerReminderTime = reminder;
    difference = time.difference(currentTime);
  }

  // Get prayer time from string
  DateTime _getPrayerTime(String timeStr, String name,
      [bool isTomorrow = false]) {
    return DateTime.parse(
      "${isTomorrow ? formattedTommorowDate : formattedCurrentDate} ${timeStr.substring(0, 5)}:00",
    );
  }

  // Schedule notification
  Future<void> scheduledNotification() async {
    final bool? grantedNotificationPermission = await LocalNotificationService
        .androidImplementation
        ?.requestNotificationsPermission();

    if (grantedNotificationPermission != null) {
      LocalNotificationService.showSchduledNotification(
        _currentDate.year,
        _currentDate.month,
        _currentDate.day,
        (isFriday && nextPrayerName == "الظهر")
            ? jumuaaPrayerReminder.hour
            : prayerReminderTime.hour,
        (isFriday && nextPrayerName == "الظهر")
            ? jumuaaPrayerReminder.minute
            : prayerReminderTime.minute,
        nextPrayerName,
      );
    }
  }

  // Handle refresh
  Future<void> handleRefresh() async {
    currentIndex = DateTime.now().day - 1;
    notifyListeners();
  }
}
