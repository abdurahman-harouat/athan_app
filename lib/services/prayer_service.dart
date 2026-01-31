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

    // Use a timeout for location to avoid hanging indefinitely
    // Medium accuracy is usually enough and faster on mobile data
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 10),
    );
  }

  Future<List<PrayerDay>> fetchPrayerTimes(int year, int month) async {
    try {
      final position = await getCurrentLocation();
      final url =
          '$baseUrl/$year/$month?latitude=${position.latitude}&longitude=${position.longitude}';
      
      // Retry logic: try 3 times with exponential backoff
      int attempts = 0;
      const maxAttempts = 3;
      
      while (attempts < maxAttempts) {
        try {
          final response = await http
              .get(Uri.parse(url))
              .timeout(const Duration(seconds: 15)); // Add timeout

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final List<dynamic> days = data['data'];
            return days.map((day) => PrayerDay.fromJson(day)).toList();
          } else {
            throw Exception('Failed to load prayer times: ${response.statusCode}');
          }
        } catch (e) {
          attempts++;
          if (attempts == maxAttempts) rethrow;
          // Wait before retrying: 1s, 2s, etc.
          await Future.delayed(Duration(seconds: attempts));
        }
      }
      throw Exception('Failed to connect after $maxAttempts attempts');
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

  Future<void> clearPrayerTimes(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
