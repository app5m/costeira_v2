class UserSession {
  const UserSession({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.document,
    this.nickname,
    this.tipo = '1',
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? document;
  final String? nickname;
  final String tipo;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'document': document,
      'nickname': nickname,
      'tipo': tipo,
    };
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
    );
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
    );
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
