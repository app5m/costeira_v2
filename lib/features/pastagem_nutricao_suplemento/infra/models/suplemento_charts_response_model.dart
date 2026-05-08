import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/suplemento_model.dart';

class SuplementoChartsResponseModel extends SuplementoChartsEntity {
  const SuplementoChartsResponseModel({
    required super.comparativoPotreiroLote,
    required super.mesAMes,
  });

  factory SuplementoChartsResponseModel.fromJson(Map<String, dynamic> json) {
    final comparativo =
        (json['comparativo_potreiro_lote'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map(
              (item) => SuplementoComparativoPotreiroLoteModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false);

    final mesAMes = (json['mes_a_mes'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) =>
              SuplementoMesAMesModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);

    return SuplementoChartsResponseModel(
      comparativoPotreiroLote: comparativo,
      mesAMes: mesAMes,
    );
  }
}

class SuplementoComparativoPotreiroLoteModel
    extends SuplementoComparativoPotreiroLoteEntity {
  const SuplementoComparativoPotreiroLoteModel({
    required super.suplementacaoId,
    required super.potreiroNome,
    required super.loteNome,
    required super.quantidadeAnimais,
    required super.consumoTotal,
    super.consumoReal,
  });

  factory SuplementoComparativoPotreiroLoteModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SuplementoComparativoPotreiroLoteModel(
      suplementacaoId: _asInt(json['suplementacao_id']),
      potreiroNome: json['potreiro_nome']?.toString() ?? '',
      loteNome: json['lote_nome']?.toString() ?? '',
      quantidadeAnimais: _asInt(json['quantidade_animais']),
      consumoTotal: _asDouble(json['consumo_total']) ?? 0,
      consumoReal: json['consumo_real'] is Map
          ? SuplementoConsumoRealModel.fromJson(
              Map<String, dynamic>.from(json['consumo_real'] as Map),
            )
          : null,
    );
  }
}

class SuplementoMesAMesModel extends SuplementoMesAMesEntity {
  const SuplementoMesAMesModel({required super.label, required super.value});

  factory SuplementoMesAMesModel.fromJson(Map<String, dynamic> json) {
    final label =
        json['mes_ano'] ??
        json['mes'] ??
        json['label'] ??
        json['data'] ??
        json['periodo'];
    final value =
        json['consumo_total'] ??
        json['consumo'] ??
        json['quantidade'] ??
        json['value'] ??
        json['valor'];

    return SuplementoMesAMesModel(
      label: label?.toString() ?? '',
      value: _asDouble(value) ?? 0,
    );
  }
}

int _asInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

double? _asDouble(dynamic value) {
  if (value == null) return null;
  return double.tryParse(value.toString().replaceAll(',', '.'));
}
