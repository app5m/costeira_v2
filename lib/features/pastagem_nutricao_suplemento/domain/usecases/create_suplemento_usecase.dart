import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/repository/suplemento_datasource.dart';

class CreateSuplementoUsecase {
  const CreateSuplementoUsecase(this._datasource);

  final SuplementoDatasource _datasource;

  Future<ApiMessage> call(SuplementoUpsertEntity suplemento) {
    return _datasource.createSuplemento(suplemento);
  }
}
