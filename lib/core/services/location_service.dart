import 'package:costeira/core/models/user_coordinates.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<UserCoordinates?> getCurrentCoordinates() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return SessionStorage.getLastCoordinates();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return SessionStorage.getLastCoordinates();
    }

    final position = await Geolocator.getCurrentPosition();
    final coordinates = UserCoordinates(
      latitude: position.latitude.toString(),
      longitude: position.longitude.toString(),
    );
    await SessionStorage.saveLastCoordinates(coordinates);
    return coordinates;
  }

  Future<bool> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}
