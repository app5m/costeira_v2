import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';

class InsumoRegistroUpsertRequestModel {
  const InsumoRegistroUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory InsumoRegistroUpsertRequestModel.fromEntity(
    InsumoRegistroUpsertEntity registro,
  ) {
    return InsumoRegistroUpsertRequestModel._(
      {
        'token': WSConstantes.token,
        'id': registro.id,
        'app_users_id': registro.appUsersId,
        'app_estoques_insumos_id': registro.appEstoquesInsumosId,
        'tipo': registro.tipo,
        'app_estoques_insumos_unidades_id':
            registro.appEstoquesInsumosUnidadesId,
        'qtd': registro.qtd,
        'obs': registro.obs,
      }..removeWhere((key, value) => value == null),
    );
  }
}
