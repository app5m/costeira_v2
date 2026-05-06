import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';

class InsumosTipoFilterRequestModel {
  const InsumosTipoFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory InsumosTipoFilterRequestModel.fromEntity(
    InsumosTipoFilterEntity filter,
  ) {
    return InsumosTipoFilterRequestModel._(
      {
        'token': WSConstantes.token,
        'app_users_id': filter.appUsersId,
        'tipo': filter.tipo,
        'nome': filter.nome,
      }..removeWhere((key, value) => value == null),
    );
  }
}
