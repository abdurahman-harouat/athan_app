import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _locationNameKey = 'cached_location_name';

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale 
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  /// Get the placemark (address) from coordinates.
  Future<String?> getPlaceName(double latitude, double longitude) async {
    try {
      try {
        await setLocaleIdentifier('ar');
      } catch (e) {
        print('Error setting locale identifier: $e');
      }

      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Construct a meaningful location name, e.g., "City, Country"
        // or just "City" or "Sublocality, Locality"
        String? locality = place.locality; // City
        String? subLocality = place.subLocality; // District/Area
        String? administrativeArea = place.administrativeArea; // State/Province
        String? country = place.country;

        // Fallback logic to get the most relevant name
        if (locality != null && locality.isNotEmpty) {
           return locality;
        } else if (administrativeArea != null && administrativeArea.isNotEmpty) {
           return administrativeArea;
        } else if (country != null && country.isNotEmpty) {
           return country;
        }
        return place.name;
      }
    } catch (e) {
      print('Error getting placemark: $e');
    }
    return null;
  }

  /// Cache the location name.
  Future<void> cacheLocationName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationNameKey, name);
  }

  /// Get the cached location name.
  Future<String?> getCachedLocationName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_locationNameKey);
  }
}
