class AccountProfile {
  const AccountProfile({
    required this.id,
    required this.tipoPessoa,
    required this.name,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.cpf,
    required this.cnpj,
    required this.razaoSocial,
    required this.nomeFantasia,
    required this.ie,
    required this.avatar,
    required this.farm,
  });

  final int id;
  final int tipoPessoa;
  final String name;
  final String email;
  final String phone;
  final String birthDate;
  final String cpf;
  final String cnpj;
  final String razaoSocial;
  final String nomeFantasia;
  final String ie;
  final String avatar;
  final ProfileFarm? farm;

  factory AccountProfile.fromJson(Map<String, dynamic> json) {
    return AccountProfile(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      tipoPessoa: int.tryParse(json['tipo_pessoa']?.toString() ?? '') ?? 1,
      name: json['nome']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['celular']?.toString() ?? '',
      birthDate: json['data_nascimento']?.toString() ?? '',
      cpf: json['cpf']?.toString() ?? '',
      cnpj: json['cnpj']?.toString() ?? '',
      razaoSocial: json['razao_social']?.toString() ?? '',
      nomeFantasia: json['nome_fantasia']?.toString() ?? '',
      ie: json['ie']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      farm: json['fazenda'] is Map<String, dynamic>
          ? ProfileFarm.fromJson(json['fazenda'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ProfileFarm {
  const ProfileFarm({
    required this.id,
    required this.name,
    required this.address,
    required this.totalArea,
    required this.usefulArea,
    required this.summerLivestockArea,
    required this.winterLivestockArea,
    required this.activities,
    required this.productionSystems,
  });

  final int id;
  final String name;
  final String address;
  final String totalArea;
  final String usefulArea;
  final String summerLivestockArea;
  final String winterLivestockArea;
  final List<ProfileNamedItem> activities;
  final List<ProfileNamedItem> productionSystems;

  factory ProfileFarm.fromJson(Map<String, dynamic> json) {
    return ProfileFarm(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['nome']?.toString() ?? '',
      address: json['endereco']?.toString() ?? '',
      totalArea: json['area_total']?.toString() ?? '',
      usefulArea: json['area_util']?.toString() ?? '',
      summerLivestockArea: json['area_pecuaria_verao']?.toString() ?? '',
      winterLivestockArea: json['area_pecuaria_inverno']?.toString() ?? '',
      activities: _parseItems(json['atividades']),
      productionSystems: _parseItems(json['producoes']),
    );
  }

  static List<ProfileNamedItem> _parseItems(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => ProfileNamedItem(
            id: int.tryParse(item['id']?.toString() ?? '') ?? 0,
            name: item['nome']?.toString() ?? '',
          ),
        )
        .toList();
  }
}

class ProfileNamedItem {
  const ProfileNamedItem({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;
}
