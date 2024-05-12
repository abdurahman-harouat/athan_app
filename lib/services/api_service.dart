import 'package:athan_app_v2/utils/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class ApiService {
  DateTime currentDate = DateTime.now();

  void getPrayersTime() async {
    Position position = await UsersLocation.determineLocation();
    final double latitude = position.latitude;
    final double longitude = position.longitude;

    final response = await http.get(Uri.https(
      'api.aladhan.com',
      '/v1/calendar/${currentDate.year}/${currentDate.month}',
      {'latitude': '$latitude', 'longitude': '$longitude'},
    ));

    if (response.statusCode == 200) {}
    throw Error();
  }
}
