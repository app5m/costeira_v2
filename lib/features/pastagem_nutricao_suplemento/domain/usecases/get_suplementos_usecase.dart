import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento_filter.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplementos_list.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/repository/suplemento_datasource.dart';

class GetSuplementosUsecase {
  const GetSuplementosUsecase(this._datasource);

  final SuplementoDatasource _datasource;

  Future<SuplementosListEntity> call(SuplementoFilterEntity filter) {
    return _datasource.getSuplementos(filter);
  }
}
