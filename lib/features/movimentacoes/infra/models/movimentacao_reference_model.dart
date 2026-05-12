import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_reference_entity.dart';

class MovimentacaoReferenceModel extends MovimentacaoReferenceEntity {
  const MovimentacaoReferenceModel({required super.id, required super.nome});

  factory MovimentacaoReferenceModel.fromJson(Map<String, dynamic> json) {
    return MovimentacaoReferenceModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nome: json['nome']?.toString() ?? '',
    );
  }

  static MovimentacaoReferenceModel? maybeFromJson(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return MovimentacaoReferenceModel.fromJson(raw);
    }
    if (raw is Map) {
      return MovimentacaoReferenceModel.fromJson(
        Map<String, dynamic>.from(raw),
      );
    }
    return null;
  }
}
