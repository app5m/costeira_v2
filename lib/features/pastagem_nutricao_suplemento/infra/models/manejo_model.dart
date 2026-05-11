import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo.dart';

class ManejoModel extends Manejo {
  const ManejoModel({
    required super.id,
    required super.appUsersId,
    required super.appPotreirosId,
    required super.tipoManejo,
    required super.appEstoquesInsumosUnidadesId,
    super.dataManejo,
    super.quantidade,
    super.dataCadastro,
    super.updateAt,
    super.potreiro,
    super.unidade,
  });

  factory ManejoModel.fromJson(Map<String, dynamic> json) {
    return ManejoModel(
      id: _asInt(json['id']),
      appUsersId: _asInt(json['app_users_id']),
      appPotreirosId: _asInt(json['app_potreiros_id']),
      tipoManejo: json['tipo_manejo']?.toString() ?? '',
      dataManejo: json['data_manejo']?.toString(),
      quantidade: _asDouble(json['quantidade']),
      appEstoquesInsumosUnidadesId: _asInt(
        json['app_estoques_insumos_unidades_id'],
      ),
      dataCadastro: json['data_cadastro']?.toString(),
      updateAt: json['update_at']?.toString(),
      potreiro: json['potreiro'] is Map
          ? ManejoReferenceModel.fromJson(
              Map<String, dynamic>.from(json['potreiro'] as Map),
            )
          : null,
      unidade: json['unidade'] is Map
          ? ManejoReferenceModel.fromJson(
              Map<String, dynamic>.from(json['unidade'] as Map),
            )
          : null,
    );
  }
}

class TipoManejoModel extends TipoManejo {
  const TipoManejoModel({
    required super.id,
    required super.nome,
    required super.unidade,
    super.tipoInsumo,
  });

  factory TipoManejoModel.fromJson(Map<String, dynamic> json) {
    return TipoManejoModel(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      tipoInsumo: json['tipo_insumo']?.toString() ?? '',
      unidade: _unidadeFromJson(json['unidade']),
    );
  }
}

class ManejoReferenceModel extends ManejoReference {
  const ManejoReferenceModel({required super.id, required super.nome});

  factory ManejoReferenceModel.fromJson(Map<String, dynamic> json) {
    return ManejoReferenceModel(
      id: _asInt(json['id']),
      nome: json['nome']?.toString() ?? '',
    );
  }
}

int _asInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

String _unidadeFromJson(dynamic value) {
  if (value is Map) {
    return value['nome']?.toString() ?? '';
  }
  return value?.toString() ?? '';
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  return double.tryParse(value.toString().replaceAll(',', '.'));
}
