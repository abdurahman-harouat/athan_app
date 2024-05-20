import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'package:athan_app/models/hijri_date_model.dart';
import 'package:athan_app/models/timings_model.dart';
import 'package:athan_app/utils/current_time.dart';
import 'package:athan_app/utils/format_date.dart';
import 'package:athan_app/utils/location.dart';
import 'package:athan_app/local_notification_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class DataModel extends ChangeNotifier {
  final athanBox = Hive.box('athan_box');

  // Declare variables
  late DateTime nextPrayerTime;
  late String _nextPrayerName;
  late DateTime _prayerReminderTime;
  late DateTime _jumuaaPrayerReminder;
  bool _isFriday = false;
  final DateTime _currentDate = DateTime.now();
  final String _formattedCurrentDate = formatDateReverse(DateTime.now());
  final String _formattedTommorowDate =
      formatDateReverse(DateTime.now().add(const Duration(days: 1)));
  late Duration _difference;
  final List<TimingsModel> _prayerTimingsOfTheMonth = [];
  final List<HijriDateModel> _hijriDateOfTheMonth = [];
  int _currentIndex = DateTime.now().day - 1;
  late double _latitude;
  late double _longitude;
  late String? _locationName;

  // getters
  Duration get difference => _difference;
  get currentIndex => _currentIndex;
  get locationName => _locationName;
  get nextPrayerName => _nextPrayerName;
  List get prayerTimingsOfTheMonth => _prayerTimingsOfTheMonth;
  get hijriDateOfTheMonth => _hijriDateOfTheMonth;

  void decreaseIndex() {
    _currentIndex--;
    notifyListeners();
  }

  void increaseIndex() {
    _currentIndex++;
    notifyListeners();
  }

  void calculateNextPrayerTime() {
    DateTime oldNextPrayerTime = nextPrayerTime;
    _calculateNextPrayerTime();

    // Only notify listeners if the next prayer time has changed
    if (nextPrayerTime != oldNextPrayerTime) {
      notifyListeners();
    }
  }

  // Initialize data
  Future<void> initializeData() async {
    var storage = athanBox.get('athan_data');
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
    _latitude = position.latitude;
    _longitude = position.longitude;
  }

  // Store location data
  Future<void> _storeLocationData() async {
    setLocaleIdentifier("ar_DZ");
    List<Placemark> placemarks =
        await placemarkFromCoordinates(_latitude, _longitude);
    _locationName = placemarks[0].locality;
    athanBox.put('athan_data', [_latitude, _longitude, _locationName]);
  }

  // Load stored location data
  void _loadStoredLocationData(List storage) {
    _latitude = storage[0];
    _longitude = storage[1];
    _locationName = storage[2];
  }

  // Fetch prayer times from API
  Future<void> _fetchPrayerTimes() async {
    var response = await http.get(Uri.https(
      'api.aladhan.com',
      '/v1/calendar/${_currentDate.year}/${_currentDate.month}',
      {'latitude': '$_latitude', 'longitude': '$_longitude'},
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
      _prayerTimingsOfTheMonth.add(TimingsModel.fromJson(timings));

      var hijri = item['date']['hijri'];
      _hijriDateOfTheMonth.add(HijriDateModel.fromJson(hijri));
    }
  }

  // Calculate next prayer time and related data
  void _calculateNextPrayerTime() {
    // TEST DATA
    // DateTime fajrTime = DateTime(2024, 5, 17, 23, 56);
    // DateTime dhuhrTime = DateTime(2024, 5, 17, 23, 56, 30);
    // DateTime asrTime = DateTime(2024, 5, 17, 23, 56, 40);
    // DateTime maghribTime = DateTime(2024, 5, 17, 23, 57);
    // DateTime ishaTime = DateTime(2024, 5, 17, 22, 23, 57, 30);
    // DateTime tomorrowFajrTime = DateTime(2024, 5, 17, 23, 57, 40);

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

    _isFriday = _hijriDateOfTheMonth[_currentIndex].arabicWeekDay == "الجمعة";

    if (currentTime.isBefore(fajrTime)) {
      _setNextPrayerData(
          'الفجر', fajrTime, fajrTime.subtract(const Duration(minutes: 10)));
    } else if ((currentTime.isAfter(fajrTime)) &&
        currentTime.isBefore(dhuhrTime)) {
      _setNextPrayerData(
          'الظهر', dhuhrTime, dhuhrTime.subtract(const Duration(minutes: 5)));
      if (_isFriday) {
        _jumuaaPrayerReminder = dhuhrTime.subtract(const Duration(minutes: 30));
      }
    } else if ((currentTime.isAfter(dhuhrTime)) &&
        currentTime.isBefore(asrTime)) {
      _setNextPrayerData(
          'العصر', asrTime, asrTime.subtract(const Duration(minutes: 5)));
    } else if ((currentTime.isAfter(asrTime)) &&
        currentTime.isBefore(maghribTime)) {
      _setNextPrayerData('المغرب', maghribTime,
          maghribTime.subtract(const Duration(minutes: 10)));
    } else if ((currentTime.isAfter(maghribTime)) &&
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
    _nextPrayerName = name;
    nextPrayerTime = time;
    _prayerReminderTime = reminder;
    _difference = time.difference(currentTime);
  }

  // Get prayer time from string
  DateTime _getPrayerTime(String timeStr, String name,
      [bool isTomorrow = false]) {
    return DateTime.parse(
      "${isTomorrow ? _formattedTommorowDate : _formattedCurrentDate} ${timeStr.substring(0, 5)}:00",
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
        (_isFriday && _nextPrayerName == "الظهر")
            ? _jumuaaPrayerReminder.hour
            : _prayerReminderTime.hour,
        (_isFriday && _nextPrayerName == "الظهر")
            ? _jumuaaPrayerReminder.minute
            : _prayerReminderTime.minute,
        _nextPrayerName,
      );
    }
  }

  void updateCurrentTime() {
    currentTime = DateTime.now();
    notifyListeners();
  }

  // Handle refresh
  Future<void> handleRefresh() async {
    _currentIndex = DateTime.now().day - 1;
    notifyListeners();
  }
}
