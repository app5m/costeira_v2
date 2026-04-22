import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';

class PotreiroModel extends PotreiroEntity {
  const PotreiroModel({
    required super.id,
    required super.appUsersId,
    required super.nome,
    super.areaTotal,
    super.areaUtil,
    super.statusAtual,
    super.tipoForragem,
    super.acessoAgua,
    super.acessoSombra,
    super.lotacaoMedia,
    super.createAt,
    super.updateAt,
    super.obs,
    super.animalsCount,
  });

  factory PotreiroModel.fromJson(Map<String, dynamic> json) {
    final animals = json['animais'] as List<dynamic>? ?? const [];

    return PotreiroModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      appUsersId: int.tryParse(json['app_users_id']?.toString() ?? '') ?? 0,
      nome: json['nome']?.toString() ?? '',
      areaTotal: _toDouble(json['area_total']),
      areaUtil: _toDouble(json['area_util']),
      statusAtual: json['status_atual']?.toString(),
      tipoForragem: json['tipo_forragem']?.toString(),
      acessoAgua: json['acesso_agua']?.toString(),
      acessoSombra: json['acesso_sombra']?.toString(),
      lotacaoMedia: _toDouble(json['lotacao_media']),
      createAt: json['create_at']?.toString(),
      updateAt: json['update_at']?.toString(),
      obs: json['obs']?.toString(),
      animalsCount: animals.length,
    );
  }

  static double? _toDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '');
  }
}
