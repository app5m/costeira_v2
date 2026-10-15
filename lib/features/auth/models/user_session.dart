class UserSession {
  const UserSession({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.document,
    this.nickname,
    this.tipo = '1',
    this.appSubUsersId,
    this.ownerUserId,
    this.idGrupo,
    this.managedClientId,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? document;
  final String? nickname;
  final String tipo;
  final int? appSubUsersId;
  final int? ownerUserId;
  final int? idGrupo;
  final int? managedClientId;

  bool get isAdmin => idGrupo == 1;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'document': document,
      'nickname': nickname,
      'tipo': tipo,
      'app_sub_users_id': appSubUsersId,
      'owner_user_id': ownerUserId,
      'id_grupo': idGrupo,
      'managed_client_id': managedClientId,
    };
  }

  UserSession withSubUser({
    int? appSubUsersId,
    int? ownerUserId,
    int? idGrupo,
  }) {
    return UserSession(
      id: id,
      name: name,
      email: email,
      phone: phone,
      document: document,
      nickname: nickname,
      tipo: tipo,
      appSubUsersId: appSubUsersId,
      ownerUserId: ownerUserId,
      idGrupo: idGrupo ?? this.idGrupo,
      managedClientId: managedClientId,
    );
  }

  UserSession withManagedClient(int? clientId) {
    return UserSession(
      id: id,
      name: name,
      email: email,
      phone: phone,
      document: document,
      nickname: nickname,
      tipo: tipo,
      appSubUsersId: appSubUsersId,
      ownerUserId: ownerUserId,
      idGrupo: idGrupo,
      managedClientId: clientId,
    );
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      id: parseId(json),
      name: json['name']?.toString() ?? json['nome']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['celular']?.toString(),
      document: json['document']?.toString() ?? json['documento']?.toString(),
      nickname: json['nickname']?.toString() ?? json['apelido']?.toString(),
      tipo: json['tipo']?.toString() ?? '1',
      appSubUsersId: _positiveId(json['app_sub_users_id']),
      ownerUserId: _positiveId(json['owner_user_id']),
      idGrupo: _positiveId(json['id_grupo']),
      managedClientId: _positiveId(json['managed_client_id']),
    );
  }

  static int? _positiveId(dynamic value) {
    final id = int.tryParse(value?.toString() ?? '');
    if (id == null || id <= 0) {
      return null;
    }
    return id;
  }

  factory UserSession.fromLoginResponse(Map<String, dynamic> json, int tipo) {
    return UserSession(
      id: parseId(json),
      name: json['nome']?.toString() ?? json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['celular']?.toString() ?? json['phone']?.toString(),
      document: json['documento']?.toString() ?? json['document']?.toString(),
      nickname: json['apelido']?.toString() ?? json['nickname']?.toString(),
      tipo: tipo.toString(),
      idGrupo: grupoDe(json),
    );
  }

  static int? grupoDe(Map<String, dynamic> json) {
    final direto = _positiveId(json['id_grupo']);
    if (direto != null) {
      return direto;
    }
    final data = json['data'] ?? json['msg2'] ?? json['user'];
    if (data is Map) {
      return grupoDe(Map<String, dynamic>.from(data));
    }
    if (data is List && data.isNotEmpty && data.first is Map) {
      return grupoDe(Map<String, dynamic>.from(data.first as Map));
    }
    return null;
  }

  static int parseId(Map<String, dynamic> json) {
    const keys = [
      'id',
      'app_users_id',
      'app_user_id',
      'user_id',
      'id_user',
      'usuarios_id',
    ];
    for (final key in keys) {
      final value = int.tryParse(json[key]?.toString() ?? '');
      if (value != null && value > 0) {
        return value;
      }
    }

    final data = json['data'] ?? json['msg2'] ?? json['user'];
    if (data is Map) {
      return parseId(Map<String, dynamic>.from(data));
    }
    if (data is List && data.isNotEmpty && data.first is Map) {
      return parseId(Map<String, dynamic>.from(data.first as Map));
    }
    return 0;
  }
}
