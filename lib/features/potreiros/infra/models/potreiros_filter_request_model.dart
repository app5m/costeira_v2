import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiros_filter_entity.dart';

class PotreirosFilterRequestModel {
  const PotreirosFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory PotreirosFilterRequestModel.fromEntity(PotreirosFilterEntity filter) {
    return PotreirosFilterRequestModel._(
      {
        'token': WSConstantes.token,
        'app_users_id': filter.appUsersId,
        'id': filter.id,
        'status_atual': filter.statusAtual,
      }..removeWhere((key, value) => value == null),
    );
  }
}
