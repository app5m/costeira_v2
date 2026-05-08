import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/repository/manejo_datasource.dart';

class UpdateManejoUsecase {
  const UpdateManejoUsecase(this._datasource);

  final ManejoDataSource _datasource;

  Future<ApiMessage> call(ManejoUpsertEntity manejo) {
    return _datasource.updateManejo(manejo);
  }
}
