import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/infra/models/insumo_reference_model.dart';

class InsumoModel extends InsumoEntity {
  const InsumoModel({
    required super.id,
    required super.appUsersId,
    required super.tipoInsumo,
    super.appEstoquesInsumosSuplementosId,
    required super.nome,
    required super.appEstoquesInsumosUnidadesId,
    super.valorUnidade,
    super.valorTotal,
    super.valorUnidadeRaw,
    super.valorTotalRaw,
    super.qtdTotal,
    super.obs,
    super.dataValidade,
    super.dataCadastro,
    super.updateAt,
    super.unidade,
    super.suplemento,
  });

  factory InsumoModel.fromJson(Map<String, dynamic> json) {
    return InsumoModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      appUsersId: int.tryParse(json['app_users_id']?.toString() ?? '') ?? 0,
      tipoInsumo: json['tipo_insumo']?.toString() ?? '',
      appEstoquesInsumosSuplementosId: int.tryParse(
        json['app_estoques_insumos_suplementos_id']?.toString() ?? '',
      ),
      nome: json['nome']?.toString() ?? '',
      appEstoquesInsumosUnidadesId:
          int.tryParse(
            json['app_estoques_insumos_unidades_id']?.toString() ?? '',
          ) ??
          0,
      valorUnidade: json['valor_unidade']?.toString(),
      valorTotal: json['valor_total']?.toString(),
      valorUnidadeRaw: double.tryParse(
        json['valor_unidade_raw']?.toString() ?? '',
      ),
      valorTotalRaw: double.tryParse(json['valor_total_raw']?.toString() ?? ''),
      qtdTotal: double.tryParse(json['qtd_total']?.toString() ?? ''),
      obs: json['obs']?.toString(),
      dataValidade: json['data_validade']?.toString(),
      dataCadastro: json['data_cadastro']?.toString(),
      updateAt: json['update_at']?.toString(),
      unidade: _referenceFromJson(json['unidade']),
      suplemento: _referenceFromJson(json['suplemento']),
    );
  }

  static InsumoReferenceEntity? _referenceFromJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      return InsumoReferenceModel.fromJson(value);
    }
    if (value is Map) {
      return InsumoReferenceModel.fromJson(Map<String, dynamic>.from(value));
    }
    return null;
  }
}
