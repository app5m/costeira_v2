import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/cadastros/domain/entities/delete_parceiro_entity.dart';

class DeleteParceiroRequestModel {
  const DeleteParceiroRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory DeleteParceiroRequestModel.fromEntity(DeleteParceiroEntity parceiro) {
    return DeleteParceiroRequestModel._({
      'token': WSConstantes.token,
      'id': parceiro.id,
    });
  }
}
