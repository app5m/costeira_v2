import 'package:costeira/core/storage/session_storage.dart';

Map<String, dynamic> withSubUser(Map<String, dynamic> data) {
  final subId = SessionStorage.cachedSubUserId;
  if (subId == null) {
    return data;
  }

  data['app_sub_users_id'] = subId;
  final ownerId = SessionStorage.cachedOwnerUserId;
  if (ownerId != null) {
    data['app_users_id'] = ownerId;
  }
  return data;
}

/// Lista da fazenda do master, sem marcar o sub. Usado em potreiro, lote e dashboard.
Map<String, dynamic> withOwnerUser(Map<String, dynamic> data) {
  final subId = SessionStorage.cachedSubUserId;
  if (subId == null) {
    return data;
  }

  data.remove('app_sub_users_id');
  final ownerId = SessionStorage.cachedOwnerUserId;
  if (ownerId != null) {
    data['app_users_id'] = ownerId;
  }
  return data;
}

int sessionAccountUserId(int sessionUserId) {
  if (SessionStorage.cachedSubUserId == null) {
    return sessionUserId;
  }
  return SessionStorage.cachedOwnerUserId ?? sessionUserId;
}
