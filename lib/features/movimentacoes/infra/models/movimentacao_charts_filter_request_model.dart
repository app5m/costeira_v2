import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_charts_filter_entity.dart';

class MovimentacaoChartsFilterRequestModel {
  const MovimentacaoChartsFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory MovimentacaoChartsFilterRequestModel.fromEntity(
    MovimentacaoChartsFilterEntity filter,
  ) {
    return MovimentacaoChartsFilterRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': filter.appUsersId,
      'mes_ano': filter.mesAno,
    });
  }
}
