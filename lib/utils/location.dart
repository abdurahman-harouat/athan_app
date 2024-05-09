import 'package:geolocator/geolocator.dart';

class UsersLocation {
  static Future<Position> determineLocation() async {
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

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return position;
  }
}
