import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';

class SuplementoModel extends Suplemento {
  const SuplementoModel({
    required super.id,
    required super.appUsersId,
    required super.appPotreirosId,
    required super.appAnimaisLotesId,
    required super.appEstoquesInsumosId,
    super.dataPostagem,
    super.pesoMedio,
    super.quantidadeAtual,
    super.quantidadeAnimais,
    super.consumoReal,
    super.dataCadastro,
    super.updateAt,
    super.produto,
    super.potreiro,
    super.lote,
    super.registros,
    super.idLocal,
    super.syncStatus,
    super.pendingAction,
    super.isLocalOnly = false,
  });

  factory SuplementoModel.fromJson(Map<String, dynamic> json) {
    final suplemento = SuplementoModel(
      id: _asInt(json['id']),
      appUsersId: _asInt(json['app_users_id']),
      appPotreirosId: _asInt(json['app_potreiros_id']),
      appAnimaisLotesId: _asInt(json['app_animais_lotes_id']),
      appEstoquesInsumosId: _asInt(json['app_estoques_insumos_id']),
      dataPostagem: json['data_postagem']?.toString(),
      pesoMedio: _asDouble(json['peso_medio']),
      quantidadeAtual: _asDouble(json['quantidade_atual']),
      quantidadeAnimais: _asNullableInt(json['quantidade_animais']),
      consumoReal: json['consumo_real'] is Map
          ? SuplementoConsumoRealModel.fromJson(
              Map<String, dynamic>.from(json['consumo_real'] as Map),
            )
          : null,
      dataCadastro: json['data_cadastro']?.toString(),
      updateAt: json['update_at']?.toString(),
      produto: json['produto'] is Map
          ? SuplementoReferenceModel.fromJson(
              Map<String, dynamic>.from(json['produto'] as Map),
            )
          : null,
      potreiro: json['potreiro'] is Map
          ? SuplementoReferenceModel.fromJson(
              Map<String, dynamic>.from(json['potreiro'] as Map),
            )
          : null,
      lote: json['lote'] is Map
          ? SuplementoReferenceModel.fromJson(
              Map<String, dynamic>.from(json['lote'] as Map),
            )
          : null,
      idLocal: json['idLocal']?.toString(),
      syncStatus: json['syncStatus']?.toString(),
      pendingAction: json['pendingAction']?.toString(),
      isLocalOnly: json['isLocalOnly'] == true,
    );

    final registros = (json['registros'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) => SuplementoRegistroModel.fromJson(
            Map<String, dynamic>.from(item),
            suplemento: suplemento,
          ),
        )
        .toList(growable: false);

    return SuplementoModel(
      id: suplemento.id,
      appUsersId: suplemento.appUsersId,
      appPotreirosId: suplemento.appPotreirosId,
      appAnimaisLotesId: suplemento.appAnimaisLotesId,
      appEstoquesInsumosId: suplemento.appEstoquesInsumosId,
      dataPostagem: suplemento.dataPostagem,
      pesoMedio: suplemento.pesoMedio,
      quantidadeAtual: suplemento.quantidadeAtual,
      quantidadeAnimais: suplemento.quantidadeAnimais,
      consumoReal: suplemento.consumoReal,
      dataCadastro: suplemento.dataCadastro,
      updateAt: suplemento.updateAt,
      produto: suplemento.produto,
      potreiro: suplemento.potreiro,
      lote: suplemento.lote,
      registros: registros,
      idLocal: suplemento.idLocal,
      syncStatus: suplemento.syncStatus,
      pendingAction: suplemento.pendingAction,
      isLocalOnly: suplemento.isLocalOnly,
    );
  }
}

class SuplementoConsumoRealModel extends SuplementoConsumoReal {
  const SuplementoConsumoRealModel({
    super.intervaloDias,
    super.quantidadeConsumidaPeriodo,
    super.consumoRealDiaLote,
    super.consumoRealAnimalDia,
  });

  factory SuplementoConsumoRealModel.fromJson(Map<String, dynamic> json) {
    return SuplementoConsumoRealModel(
      intervaloDias: _asNullableInt(json['intervalo_dias']),
      quantidadeConsumidaPeriodo: _asDouble(
        json['quantidade_consumida_periodo'],
      ),
      consumoRealDiaLote: json['consumo_real_dia_lote']?.toString(),
      consumoRealAnimalDia: json['consumo_real_animal_dia']?.toString(),
    );
  }
}

class SuplementoReferenceModel extends SuplementoReference {
  const SuplementoReferenceModel({
    required super.id,
    required super.nome,
    super.tipoInsumo,
  });

  factory SuplementoReferenceModel.fromJson(Map<String, dynamic> json) {
    return SuplementoReferenceModel(
      id: _asInt(json['id']),
      nome: json['nome']?.toString() ?? '',
      tipoInsumo: json['tipo_insumo']?.toString(),
    );
  }
}

class SuplementoRegistroModel extends SuplementoRegistro {
  const SuplementoRegistroModel({
    required super.id,
    required super.appSuplementacaoId,
    required super.tipo,
    super.dataRestabastecimento,
    super.quantidade,
    super.dataCadastro,
    super.updateAt,
    super.suplemento,
    super.idLocal,
    super.syncStatus,
    super.pendingAction,
    super.isLocalOnly = false,
  });

  factory SuplementoRegistroModel.fromJson(
    Map<String, dynamic> json, {
    Suplemento? suplemento,
  }) {
    return SuplementoRegistroModel(
      id: _asInt(json['id']),
      appSuplementacaoId: _asInt(json['app_suplementacao_id']),
      tipo: json['tipo'] is Map
          ? SuplementoReferenceModel.fromJson(
              Map<String, dynamic>.from(json['tipo'] as Map),
            )
          : const SuplementoReference(id: 0, nome: ''),
      dataRestabastecimento: json['data_restabastecimento']?.toString(),
      quantidade: _asDouble(json['quantidade']),
      dataCadastro: json['data_cadastro']?.toString(),
      updateAt: json['update_at']?.toString(),
      suplemento: suplemento,
      idLocal: json['idLocal']?.toString(),
      syncStatus: json['syncStatus']?.toString(),
      pendingAction: json['pendingAction']?.toString(),
      isLocalOnly: json['isLocalOnly'] == true,
    );
  }
}

int _asInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  return int.tryParse(value.toString());
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  return double.tryParse(value.toString().replaceAll(',', '.'));
}
