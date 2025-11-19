import 'dart:convert';

import 'package:athan_app_v2/models/prayer_times.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerService {
  static const String baseUrl = 'https://api.aladhan.com/v1/calendar';

  Future<Position> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      throw Exception('Location permissions are denied');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<List<PrayerDay>> fetchPrayerTimes(int year, int month) async {
    try {
      final position = await getCurrentLocation();
      final url =
          '$baseUrl/$year/$month?latitude=${position.latitude}&longitude=${position.longitude}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> days = data['data'];
        return days.map((day) => PrayerDay.fromJson(day)).toList();
      } else {
        throw Exception('Failed to load prayer times');
      }
    } catch (e) {
      throw Exception('Error fetching prayer times: $e');
    }
  }

  Future<void> savePrayerTimes(List<PrayerDay> prayerDays, String key) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonData =
        json.encode(prayerDays.map((day) => day.toJson()).toList());
    await prefs.setString(key, jsonData);
  }

  Future<List<PrayerDay>> loadPrayerTimes(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonData = prefs.getString(key);
    if (jsonData != null) {
      final List<dynamic> data = json.decode(jsonData);
      return data.map((json) => PrayerDay.fromJson(json)).toList();
    }
    return [];
  }
}
