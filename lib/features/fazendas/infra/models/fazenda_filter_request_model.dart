import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_filter_entity.dart';

class FazendaFilterRequestModel {
  const FazendaFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory FazendaFilterRequestModel.fromEntity(FazendaFilterEntity filter) {
    final data = {
      'token': WSConstantes.token,
      'app_users_id': filter.appUsersId,
      'id_user': filter.appUsersId,
      'id': filter.id,
      'nome': filter.nome,
      if (filter.mesmoTitular) 'mesmo_titular': true,
    }..removeWhere((key, value) => value == null);

    return FazendaFilterRequestModel._(
      filter.mesmoTitular ? withSubUser(data) : data,
    );
  }
}
