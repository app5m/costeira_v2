import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_upsert_entity.dart';
import 'package:costeira/features/potreiros/domain/repository/potreiros_datasource.dart';

class CreatePotreiroUsecase {
  const CreatePotreiroUsecase(this._datasource);

  final PotreirosDatasource _datasource;

  Future<ApiMessage> call(PotreiroUpsertEntity potreiro) {
    return _datasource.createPotreiro(potreiro);
  }
}
