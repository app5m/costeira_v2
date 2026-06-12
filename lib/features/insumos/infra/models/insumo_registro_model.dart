import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/infra/models/insumo_reference_model.dart';

class InsumoRegistroModel extends InsumoRegistroEntity {
  const InsumoRegistroModel({
    required super.id,
    required super.appEstoquesInsumosId,
    required super.estoqueNome,
    required super.tipoInsumo,
    required super.tipo,
    required super.appEstoquesInsumosUnidadesId,
    super.unidade,
    super.qtd,
    super.obs,
    super.dataCadastro,
    super.updateAt,
    super.idLocal,
    super.syncStatus,
    super.pendingAction,
    super.isLocalOnly = false,
  });

  factory InsumoRegistroModel.fromJson(Map<String, dynamic> json) {
    return InsumoRegistroModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      appEstoquesInsumosId:
          int.tryParse(json['app_estoques_insumos_id']?.toString() ?? '') ?? 0,
      estoqueNome: json['estoque_nome']?.toString() ?? '',
      tipoInsumo: json['tipo_insumo']?.toString() ?? '',
      tipo:
          _referenceFromJson(json['tipo']) ??
          const InsumoReferenceEntity(id: 0, nome: 'Registro'),
      appEstoquesInsumosUnidadesId:
          int.tryParse(
            json['app_estoques_insumos_unidades_id']?.toString() ?? '',
          ) ??
          0,
      unidade: _referenceFromJson(json['unidade']),
      qtd: double.tryParse(json['qtd']?.toString() ?? ''),
      obs: json['obs']?.toString(),
      dataCadastro: json['data_cadastro']?.toString(),
      updateAt: json['update_at']?.toString(),
      idLocal: json['idLocal']?.toString(),
      syncStatus: json['syncStatus']?.toString(),
      pendingAction: json['pendingAction']?.toString(),
      isLocalOnly: json['isLocalOnly'] == true,
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
