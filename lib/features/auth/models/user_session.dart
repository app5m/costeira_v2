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
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
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
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['nome']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['celular']?.toString(),
      document: json['documento']?.toString(),
      nickname: json['apelido']?.toString(),
      tipo: tipo.toString(),
    );
  }
}
