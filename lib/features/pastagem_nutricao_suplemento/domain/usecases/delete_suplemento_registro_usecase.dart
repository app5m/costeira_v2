import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/repository/suplemento_datasource.dart';

class DeleteSuplementoRegistroUsecase {
  const DeleteSuplementoRegistroUsecase(this._datasource);

  final SuplementoDatasource _datasource;

  Future<ApiMessage> call(DeleteSuplementoRegistroEntity registro) {
    return _datasource.deleteRegistro(registro);
  }
}
