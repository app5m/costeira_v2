import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/movimentacoes/compras/domain/entities/compra_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/compras/domain/entities/compra_upsert_entity.dart';

class CompraUpsertRequestModel {
  const CompraUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory CompraUpsertRequestModel.create(CompraUpsertEntity compra) {
    return CompraUpsertRequestModel._(_createPayload(compra));
  }

  /// Postman Atualizar: identidade + campos editáveis. Sem animais/categoria/sexo.
  factory CompraUpsertRequestModel.update(CompraUpsertEntity compra) {
    return CompraUpsertRequestModel._({
      'token': WSConstantes.token,
      'id': compra.id,
      'app_users_id': compra.appUsersId,
      'app_fazendas_id': compra.appFazendasId,
      'app_potreiros_id': compra.appPotreirosId,
      'app_animais_lotes_id': compra.appAnimaisLotesId,
      'data': compra.data,
      'id_fornecedor': compra.idFornecedor,
      'obs': compra.obs,
      'valor_unitario': compra.valorUnitario,
      'valor_frete': compra.valorFrete,
      'valor_comissao': compra.valorComissao,
    }..removeWhere((key, value) => value == null));
  }

  static Map<String, dynamic> _createPayload(CompraUpsertEntity compra) {
    final data = <String, dynamic>{
      'token': WSConstantes.token,
      'app_users_id': compra.appUsersId,
      'app_fazendas_id': compra.appFazendasId,
      'app_potreiros_id': compra.appPotreirosId,
      'app_animais_lotes_id': compra.appAnimaisLotesId,
      'data': compra.data,
      'sexo': compra.sexo,
      'app_animais_categorias_id': compra.appAnimaisCategoriasId,
      'app_animais_subcategorias_id': compra.appAnimaisSubcategoriasId,
      'ut_bases_raciais_id': compra.utBasesRaciaisId,
      'tipo_compra': compra.tipoCompra,
      'tipo_cadastro': compra.tipoCadastro,
      'valor_unitario': compra.valorUnitario,
      'valor_frete': compra.valorFrete,
      'valor_comissao': compra.valorComissao,
      'id_fornecedor': compra.idFornecedor,
      'obs': compra.obs,
    };

    if (compra.isIndividual) {
      data['animais'] = compra.animais
          .map(_animalToJson)
          .toList(growable: false);
    } else {
      data['qtd_animais'] = compra.qtdAnimais;
      data['peso_total'] = compra.pesoTotal;
      data['peso_medio'] = compra.pesoMedio;
    }

    data.removeWhere((key, value) => value == null);
    return data;
  }

  static Map<String, dynamic> _animalToJson(CompraUpsertAnimalEntity animal) {
    return {'brinco': animal.brinco, 'peso_total': animal.pesoTotal}
      ..removeWhere((key, value) => value == null);
  }
}
