import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/repository/manejo_datasource.dart';

class CreateManejoUsecase {
  const CreateManejoUsecase(this._datasource);

  final ManejoDataSource _datasource;

  Future<ApiMessage> call(ManejoUpsertEntity manejo) {
    return _datasource.createManejo(manejo);
  }
}
