class ProfileSubUser {
  const ProfileSubUser({this.appSubUsersId, this.ownerUserId});

  final int? appSubUsersId;
  final int? ownerUserId;

  factory ProfileSubUser.fromProfile(Map<String, dynamic> json) {
    final tipo = int.tryParse(json['tipo']?.toString() ?? '');
    if (tipo != 2) {
      return const ProfileSubUser();
    }

    final profileId = _positive(json['id']);
    if (profileId == null) {
      return const ProfileSubUser();
    }

    return ProfileSubUser(
      appSubUsersId: profileId,
      ownerUserId: _ownerId(json),
    );
  }

  static int? _ownerId(Map<String, dynamic> json) {
    final vinculo = json['vinculo'];
    if (vinculo is Map) {
      final id = _positive(vinculo['id']);
      if (id != null) {
        return id;
      }
    }
    return _positive(json['id_vinculo'] ?? json['id_vinculo_usuario']);
  }

  static int? _positive(dynamic value) {
    final id = int.tryParse(value?.toString() ?? '');
    if (id == null || id <= 0) {
      return null;
    }
    return id;
  }
}
