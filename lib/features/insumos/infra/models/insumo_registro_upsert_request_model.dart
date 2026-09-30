import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';

class InsumoRegistroUpsertRequestModel {
  const InsumoRegistroUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory InsumoRegistroUpsertRequestModel.fromEntity(
    InsumoRegistroUpsertEntity registro,
  ) {
    return InsumoRegistroUpsertRequestModel._(
      withSubUser({
        'token': WSConstantes.token,
        'id': registro.id,
        'app_users_id': registro.appUsersId,
        'app_fazendas_id': registro.appFazendasId,
        'app_estoques_insumos_id': registro.appEstoquesInsumosId,
        'tipo': registro.tipo,
        'app_estoques_insumos_unidades_id':
            registro.appEstoquesInsumosUnidadesId,
        'qtd': registro.qtd,
        'obs': registro.obs,
        'data': registro.data,
        'data_validade': registro.dataValidade,
        'valor_unidade': registro.valorUnidade,
        'id_fornecedor': registro.fornecedorId,
        'app_estoques_insumos_motivos_id': registro.appEstoquesInsumosMotivosId,
      }..removeWhere((key, value) => value == null)),
    );
  }
}
