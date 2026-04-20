import 'package:costeira/core/common/get_list/domain/entities/get_list_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_params_entity.dart';
import 'package:costeira/core/common/get_list/domain/repository/get_list_datasource.dart';

class GetListUsecase {
  const GetListUsecase(this._datasource);

  final GetListDatasource _datasource;

  Future<GetListEntity> call(GetListParamsEntity params) {
    return _datasource.getList(params);
  }
}
