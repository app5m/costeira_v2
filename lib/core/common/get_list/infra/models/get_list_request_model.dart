import 'package:costeira/core/common/get_list/domain/entities/get_list_params_entity.dart';
import 'package:costeira/core/config/ws_constantes.dart';

class GetListRequestModel {
  const GetListRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory GetListRequestModel.fromEntity(GetListParamsEntity params) {
    return GetListRequestModel._(
      {
        'sexo': params.sexo,
        'token': WSConstantes.token,
        if (params.userId != null) 'id_user': params.userId,
      }..removeWhere((key, value) => value == null),
    );
  }
}
