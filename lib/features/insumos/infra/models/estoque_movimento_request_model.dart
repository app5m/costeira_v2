import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';

class EstoqueMovimentoRequestModel {
  const EstoqueMovimentoRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory EstoqueMovimentoRequestModel.fromEntity(
    EstoqueMovimentoEntity movimento,
  ) {
    final qtd = movimento.qtdTotal % 1 == 0
        ? movimento.qtdTotal.toInt()
        : movimento.qtdTotal;
    final payload = <String, dynamic>{
      'token': WSConstantes.token,
      'app_users_id': movimento.appUsersId,
      'app_fazendas_id': movimento.appFazendasId,
      'qtd_total': qtd,
      'obs': movimento.obs,
    };

    if (movimento.saida) {
      payload['id_insumo'] = movimento.insumoId;
      payload['id_motivo'] = movimento.motivoId;
    } else {
      payload.addAll({
        'nome': movimento.nome,
        'app_estoque_insumos_categorias_id': movimento.categoriaId,
        'app_estoque_insumos_subcategorias_id': movimento.subcategoriaId,
        'app_estoques_insumos_unidades_id': movimento.unidadeId,
        'id_insumo': movimento.insumoId,
        'id_fornecedor': movimento.fornecedorId,
        'valor_unitario': movimento.valorUnitario,
        'data_validade': movimento.dataValidade,
      });
    }

    payload.removeWhere((key, value) => value == null);
    return EstoqueMovimentoRequestModel._(withSubUser(payload));
  }
}
