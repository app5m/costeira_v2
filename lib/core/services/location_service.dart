import 'dart:async';

import 'package:costeira/core/models/user_coordinates.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static const _positionTimeout = Duration(seconds: 8);
  static const _simulatorTimeout = Duration(seconds: 3);

  /// Usada só quando o simulador iOS não entrega coordenada, mesmo com permissão.
  static const _simulatorFallback = UserCoordinates(
    latitude: '-30.0346',
    longitude: '-51.2177',
  );

  bool get _isIosSimulator {
    return !kIsWeb &&
        kDebugMode &&
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<UserCoordinates?> getCurrentCoordinates() async {
    final simulator = _isIosSimulator;
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && !simulator) {
      return SessionStorage.getLastCoordinates();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return simulator ? null : SessionStorage.getLastCoordinates();
    }

    final fresh = await _readPosition(
      () => Geolocator.getCurrentPosition(locationSettings: _positionSettings()),
      simulator ? _simulatorTimeout : _positionTimeout,
    );
    if (fresh != null) {
      await SessionStorage.saveLastCoordinates(fresh);
      return fresh;
    }

    final lastKnown = await _readPosition(
      Geolocator.getLastKnownPosition,
      _simulatorTimeout,
    );
    if (lastKnown != null) {
      await SessionStorage.saveLastCoordinates(lastKnown);
      return lastKnown;
    }

    final stored = await SessionStorage.getLastCoordinates();
    if (stored != null) {
      return stored;
    }

    if (simulator) {
      return _simulatorFallback;
    }
    return null;
  }

  Future<UserCoordinates?> _readPosition(
    Future<Position?> Function() read,
    Duration timeout,
  ) async {
    try {
      final position = await read().timeout(timeout);
      if (position == null) {
        return null;
      }
      return UserCoordinates(
        latitude: position.latitude.toString(),
        longitude: position.longitude.toString(),
      );
    } catch (_) {
      return null;
    }
  }

  LocationSettings _positionSettings() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.medium,
        activityType: ActivityType.other,
        timeLimit: _positionTimeout,
      );
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: _positionTimeout,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.medium,
      timeLimit: _positionTimeout,
    );
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

  Future<LocationRequestResult> requestLocationAccess() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationRequestResult.unavailable;
      }
      final granted = await requestPermission();
      if (!granted) {
        return LocationRequestResult.denied;
      }
      return LocationRequestResult.granted;
    } catch (_) {
      return LocationRequestResult.failed;
    }
  }
}

enum LocationRequestResult { granted, denied, unavailable, failed }
