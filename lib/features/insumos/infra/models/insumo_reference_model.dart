import 'package:costeira/features/insumos/domain/entities/insumos.dart';

class InsumoReferenceModel extends InsumoReferenceEntity {
  const InsumoReferenceModel({required super.id, required super.nome});

  factory InsumoReferenceModel.fromJson(Map<String, dynamic> json) {
    return InsumoReferenceModel(
      id: json['id'],
      nome: json['nome']?.toString() ?? '',
    );
  }
}
