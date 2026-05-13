import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_destino_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_upsert_entity.dart';

class VendaUpsertRequestModel {
  const VendaUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory VendaUpsertRequestModel.create(VendaUpsertEntity venda) {
    return VendaUpsertRequestModel._(
      _baseData(venda)..addAll({
        'animais': venda.animais.map(_animalToJson).toList(growable: false),
      }),
    );
  }

  factory VendaUpsertRequestModel.update(VendaUpsertEntity venda) {
    return VendaUpsertRequestModel._(
      _baseData(venda)..addAll({'id': venda.id}),
    );
  }

  static Map<String, dynamic> _baseData(VendaUpsertEntity venda) {
    return {
      'token': WSConstantes.token,
      'app_users_id': venda.appUsersId,
      'data': venda.data,
      'valor_unitario': venda.valorUnitario,
      'comprador': venda.comprador,
      'municipio': venda.municipio,
      'obs': venda.obs,
      'destinos': venda.destinos.map(_destinoToJson).toList(growable: false),
    }..removeWhere((key, value) => value == null);
  }

  static Map<String, dynamic> _animalToJson(VendaUpsertAnimalEntity animal) {
    return {'id': animal.id};
  }

  static Map<String, dynamic> _destinoToJson(VendaDestinoEntity destino) {
    return {'destino': destino.destino, 'tipo': destino.tipo};
  }
}
