import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo_filter.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejos_list.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/repository/manejo_datasource.dart';

class GetManejosUsecase {
  const GetManejosUsecase(this._datasource);

  final ManejoDataSource _datasource;

  Future<ManejosListEntity> call(ManejoFilterEntity filter) {
    return _datasource.getManejos(filter);
  }
}
