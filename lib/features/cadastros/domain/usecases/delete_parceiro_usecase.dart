import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/cadastros/domain/entities/delete_parceiro_entity.dart';
import 'package:costeira/features/cadastros/domain/repository/parceiros_datasource.dart';

class DeleteParceiroUsecase {
  const DeleteParceiroUsecase(this._datasource);

  final ParceirosDatasource _datasource;

  Future<ApiMessage> call(DeleteParceiroEntity parceiro) {
    return _datasource.deleteParceiro(parceiro);
  }
}
