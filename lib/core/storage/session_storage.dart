import 'dart:convert';

import 'package:costeira/core/models/user_coordinates.dart';
import 'package:costeira/features/auth/models/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  SessionStorage._();

  static UserSession? _cached;

  static int? get cachedSubUserId {
    final id = _cached?.appSubUsersId;
    if (id == null || id <= 0) {
      return null;
    }
    return id;
  }

  static int? get cachedOwnerUserId {
    final id = _cached?.ownerUserId;
    if (id == null || id <= 0) {
      return null;
    }
    return id;
  }

  static int? get cachedManagedClientId {
    final id = _cached?.managedClientId;
    if (id == null || id <= 0) {
      return null;
    }
    return id;
  }

  static int? get cachedIdGrupo => _cached?.idGrupo;

  static const _userSessionKey = 'user_session';
  static const _pendingUserKey = 'pending_user_session';
  static const _webPendingApprovalKey = 'web_pending_approval_session';
  static const _onboardingSeenKey = 'onboarding_seen';
  static const _lastCoordinatesKey = 'last_coordinates';
  static const _pendingPushTokenKey = 'pending_push_token';
  static const _selectedFarmIdKey = 'selected_farm_id';

  static Future<void> saveUserSession(UserSession session) async {
    _cached = session;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userSessionKey, jsonEncode(session.toJson()));
  }

  static Future<UserSession?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userSessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final session = UserSession.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
    if (session.id <= 0) {
      _cached = null;
      return null;
    }
    _cached = session;
    return session;
  }

  static Future<void> clearUserSession() async {
    await clearAuthData();
  }

  static Future<void> savePendingUser(UserSession session) async {
    if (session.id <= 0) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingUserKey, jsonEncode(session.toJson()));
  }

  static Future<UserSession?> getPendingUser({String? email}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingUserKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final session = UserSession.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
    if (session.id <= 0) {
      return null;
    }
    if (email != null && email.trim().isNotEmpty) {
      final pendingEmail = session.email.trim().toLowerCase();
      if (pendingEmail.isNotEmpty &&
          pendingEmail != email.trim().toLowerCase()) {
        return null;
      }
    }
    return session;
  }

  static Future<void> clearPendingUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingUserKey);
  }

  static Future<void> saveWebPendingApproval({
    required String message,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _webPendingApprovalKey,
      jsonEncode({'message': message, 'email': email}),
    );
  }

  static Future<Map<String, String>?> getWebPendingApproval() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_webPendingApprovalKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final value = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      return {
        'message': value['message']?.toString() ?? '',
        'email': value['email']?.toString() ?? '',
      };
    } catch (_) {
      await prefs.remove(_webPendingApprovalKey);
      return null;
    }
  }

  static Future<void> clearWebPendingApproval() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_webPendingApprovalKey);
  }

  static Future<void> clearAuthData() async {
    _cached = null;
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_userSessionKey),
      prefs.remove(_lastCoordinatesKey),
      prefs.remove(_pendingPushTokenKey),
      prefs.remove(_selectedFarmIdKey),
      prefs.remove(_webPendingApprovalKey),
    ]);
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
    await prefs.setString(
      _lastCoordinatesKey,
      jsonEncode(coordinates.toJson()),
    );
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

  static Future<void> saveSelectedFarmId(int id) async {
    if (id <= 0) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_selectedFarmIdKey, id);
  }

  static Future<int?> getSelectedFarmId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_selectedFarmIdKey);
    if (id == null || id <= 0) {
      return null;
    }
    return id;
  }

  static Future<void> clearSelectedFarmId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedFarmIdKey);
  }
}
