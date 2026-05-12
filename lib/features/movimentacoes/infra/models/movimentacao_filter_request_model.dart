import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';

class MovimentacaoFilterRequestModel {
  const MovimentacaoFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory MovimentacaoFilterRequestModel.fromEntity(
    MovimentacaoFilterEntity filter,
  ) {
    return MovimentacaoFilterRequestModel._(
      {
        'token': WSConstantes.token,
        'app_users_id': filter.appUsersId,
        'id': filter.id,
        'data_in': filter.dataIn,
        'data_out': filter.dataOut,
      }..removeWhere((key, value) => value == null),
    );
  }
}
