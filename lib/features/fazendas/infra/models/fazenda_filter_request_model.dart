import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_filter_entity.dart';

class FazendaFilterRequestModel {
  const FazendaFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory FazendaFilterRequestModel.fromEntity(FazendaFilterEntity filter) {
    return FazendaFilterRequestModel._(
      {
        'token': WSConstantes.token,
        'app_users_id': filter.appUsersId,
        'id_user': filter.appUsersId,
        'id': filter.id,
        'nome': filter.nome,
      }..removeWhere((key, value) => value == null),
    );
  }
}
