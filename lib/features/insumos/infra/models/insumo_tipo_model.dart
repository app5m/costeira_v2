import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/infra/models/insumo_reference_model.dart';

class InsumoTipoModel extends InsumoTipoEntity {
  const InsumoTipoModel({
    required super.id,
    required super.nome,
    required super.tipoInsumo,
    super.qtdTotal,
    super.unidade,
    super.suplemento,
  });

  factory InsumoTipoModel.fromJson(Map<String, dynamic> json) {
    return InsumoTipoModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nome: json['nome']?.toString() ?? '',
      tipoInsumo: json['tipo_insumo']?.toString() ?? '',
      qtdTotal: double.tryParse(json['qtd_total']?.toString() ?? ''),
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
