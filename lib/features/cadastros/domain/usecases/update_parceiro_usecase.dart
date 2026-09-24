import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_upsert_entity.dart';
import 'package:costeira/features/cadastros/domain/repository/parceiros_datasource.dart';

class UpdateParceiroUsecase {
  const UpdateParceiroUsecase(this._datasource);

  final ParceirosDatasource _datasource;

  Future<ApiMessage> call(ParceiroUpsertEntity parceiro) {
    return _datasource.updateParceiro(parceiro);
  }
}
