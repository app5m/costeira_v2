import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_filter_entity.dart';

class ParceiroFilterRequestModel {
  const ParceiroFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory ParceiroFilterRequestModel.fromEntity(ParceiroFilterEntity filter) {
    return ParceiroFilterRequestModel._(
      {
        'token': WSConstantes.token,
        'app_users_id': filter.appUsersId,
        'app_fazendas_id': filter.appFazendasId,
        'id': filter.id,
        'nome': filter.nome,
      }..removeWhere(
        (key, value) =>
            value == null || (value is String && value.trim().isEmpty),
      ),
    );
  }
}
