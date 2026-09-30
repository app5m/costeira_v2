import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';

class InsumoUpsertRequestModel {
  const InsumoUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory InsumoUpsertRequestModel.fromEntity(InsumoUpsertEntity insumo) {
    return InsumoUpsertRequestModel._(
      withSubUser({
        'token': WSConstantes.token,
        'id': insumo.id,
        'app_users_id': insumo.appUsersId,
        'app_fazendas_id': insumo.appFazendasId,
        'tipo_insumo': insumo.tipoInsumo,
        'app_estoques_insumos_suplementos_id':
            insumo.appEstoquesInsumosSuplementosId,
        'nome': insumo.nome,
        'app_estoques_insumos_unidades_id': insumo.appEstoquesInsumosUnidadesId,
        'valor_unidade': insumo.valorUnidade,
        'qtd_total': insumo.qtdTotal,
        'obs': insumo.obs,
        'data_validade': insumo.dataValidade,
        'app_estoques_insumos_categorias_id':
            insumo.appEstoquesInsumosCategoriasId,
        'app_estoques_insumos_subcategorias_id':
            insumo.appEstoquesInsumosSubcategoriasId,
      }..removeWhere((key, value) => value == null)),
    );
  }
}
