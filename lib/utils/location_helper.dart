import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;  // Return null if location services are off
    }

    // Check and request location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;  // Return null if permission is denied
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;  // Return null if permissions are permanently denied
    }

    // Get and return the current position
    return await Geolocator.getCurrentPosition();
  }
}
