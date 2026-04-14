import 'dart:convert';

import 'package:costeira/core/models/user_coordinates.dart';
import 'package:costeira/features/auth/models/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  SessionStorage._();

  static const _userSessionKey = 'user_session';
  static const _onboardingSeenKey = 'onboarding_seen';
  static const _lastCoordinatesKey = 'last_coordinates';
  static const _pendingPushTokenKey = 'pending_push_token';

  static Future<void> saveUserSession(UserSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userSessionKey, jsonEncode(session.toJson()));
  }

  static Future<UserSession?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userSessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return UserSession.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userSessionKey);
  }

  static Future<bool> isLoggedIn() async {
    return (await getUserSession()) != null;
  }

  static Future<void> setOnboardingSeen(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingSeenKey, value);
  }

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingSeenKey) ?? false;
  }

  static Future<void> saveLastCoordinates(UserCoordinates coordinates) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCoordinatesKey, jsonEncode(coordinates.toJson()));
  }

  static Future<UserCoordinates?> getLastCoordinates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastCoordinatesKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return UserCoordinates.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  static Future<void> savePendingPushToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingPushTokenKey, token);
  }

  static Future<String?> getPendingPushToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pendingPushTokenKey);
  }

  static Future<void> clearPendingPushToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingPushTokenKey);
  }
}
