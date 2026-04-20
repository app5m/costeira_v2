import 'package:costeira/core/common/get_list/domain/entities/get_list_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_params_entity.dart';

abstract class GetListDatasource {
  Future<GetListEntity> getList(GetListParamsEntity params);
}
