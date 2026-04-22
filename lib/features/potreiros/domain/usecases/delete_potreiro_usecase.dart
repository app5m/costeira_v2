import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/potreiros/domain/entities/delete_potreiro_entity.dart';
import 'package:costeira/features/potreiros/domain/repository/potreiros_datasource.dart';

class DeletePotreiroUsecase {
  const DeletePotreiroUsecase(this._datasource);

  final PotreirosDatasource _datasource;

  Future<ApiMessage> call(DeletePotreiroEntity potreiro) {
    return _datasource.deletePotreiro(potreiro);
  }
}
