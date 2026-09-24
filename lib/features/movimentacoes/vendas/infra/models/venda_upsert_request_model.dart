import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_upsert_entity.dart';

class VendaUpsertRequestModel {
  const VendaUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory VendaUpsertRequestModel.create(VendaUpsertEntity venda) {
    return VendaUpsertRequestModel._(
      _createPayload(venda)
        ..addAll({
          'animais': venda.animais
              .map(_animalToJson)
              .toList(growable: false),
        }),
    );
  }

  /// Postman Atualizar: identidade + campos editáveis. Sem animais/tipo_*.
  factory VendaUpsertRequestModel.update(VendaUpsertEntity venda) {
    return VendaUpsertRequestModel._({
      'token': WSConstantes.token,
      'id': venda.id,
      'app_users_id': venda.appUsersId,
      'app_fazendas_id': venda.appFazendasId,
      'data': venda.data,
      'id_comprador': venda.idComprador,
      'valor_unitario': venda.valorUnitario,
      'valor_frete': venda.valorFrete,
      'valor_comissao': venda.valorComissao,
      'obs': venda.obs,
    }..removeWhere((key, value) => value == null));
  }

  static Map<String, dynamic> _createPayload(VendaUpsertEntity venda) {
    return {
      'token': WSConstantes.token,
      'app_users_id': venda.appUsersId,
      'app_fazendas_id': venda.appFazendasId,
      'data': venda.data,
      'tipo_compra': venda.tipoCompra,
      'tipo_cadastro': venda.tipoCadastro,
      'valor_unitario': venda.valorUnitario,
      'valor_frete': venda.valorFrete,
      'valor_comissao': venda.valorComissao,
      'id_comprador': venda.idComprador,
      'obs': venda.obs,
    }..removeWhere((key, value) => value == null);
  }

  static Map<String, dynamic> _animalToJson(VendaUpsertAnimalEntity animal) {
    return {'id': animal.id, 'peso_total': animal.pesoTotal}
      ..removeWhere((key, value) => value == null);
  }
}
