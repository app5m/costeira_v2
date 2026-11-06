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
    this.idGrupo,
  });

  final int id;
  final int tipoPessoa;
  final int? idGrupo;
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
      idGrupo: int.tryParse(json['id_grupo']?.toString() ?? ''),
      farm: ProfileFarm.fromProfileJson(json),
    );
  }

  bool get hasFarmCadastro {
    return farm != null ||
        nomeFantasia.trim().isNotEmpty ||
        razaoSocial.trim().isNotEmpty ||
        cnpj.trim().isNotEmpty ||
        ie.trim().isNotEmpty;
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

  /// Master: perfil manda empresa no root, sem `fazenda` aninhada.
  /// Sub: às vezes `fazendas` (lista id/nome) sem detalhe.
  static ProfileFarm? fromProfileJson(Map<String, dynamic> json) {
    final nested = json['fazenda'];
    if (nested is Map) {
      return ProfileFarm.fromJson(Map<String, dynamic>.from(nested));
    }

    final fazendas = json['fazendas'];
    if (fazendas is List && fazendas.isNotEmpty) {
      final first = fazendas.first;
      if (first is Map) {
        final map = Map<String, dynamic>.from(first);
        final nome = map['nome']?.toString().trim() ?? '';
        if (nome.isNotEmpty || map['id'] != null) {
          return ProfileFarm(
            id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
            name: nome.isNotEmpty
                ? nome
                : (json['nome_fantasia']?.toString() ?? ''),
            address: map['endereco']?.toString() ?? '',
            totalArea: map['area_total']?.toString() ?? '',
            usefulArea: map['area_util']?.toString() ?? '',
            summerLivestockArea:
                map['area_pecuaria_verao']?.toString() ?? '',
            winterLivestockArea:
                map['area_pecuaria_inverno']?.toString() ?? '',
            activities: _parseItems(map['atividades']),
            productionSystems: _parseItems(map['producoes']),
          );
        }
      }
    }

    final nomeFantasia = json['nome_fantasia']?.toString().trim() ?? '';
    final razao = json['razao_social']?.toString().trim() ?? '';
    final cnpj = json['cnpj']?.toString().trim() ?? '';
    if (nomeFantasia.isEmpty && razao.isEmpty && cnpj.isEmpty) {
      return null;
    }

    return ProfileFarm(
      id: 0,
      name: nomeFantasia.isNotEmpty ? nomeFantasia : razao,
      address: '',
      totalArea: '',
      usefulArea: '',
      summerLivestockArea: '',
      winterLivestockArea: '',
      activities: const [],
      productionSystems: const [],
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
  const ProfileNamedItem({required this.id, required this.name});

  final int id;
  final String name;
}
