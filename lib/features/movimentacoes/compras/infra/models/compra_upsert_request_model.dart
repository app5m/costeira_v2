import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/movimentacoes/compras/domain/entities/compra_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/compras/domain/entities/compra_upsert_entity.dart';

class CompraUpsertRequestModel {
  const CompraUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory CompraUpsertRequestModel.create(CompraUpsertEntity compra) {
    return CompraUpsertRequestModel._(
      _baseData(compra)..addAll({
        'animais': compra.animais.map(_animalToJson).toList(growable: false),
      }),
    );
  }

  factory CompraUpsertRequestModel.update(CompraUpsertEntity compra) {
    return CompraUpsertRequestModel._(
      _baseData(compra)..addAll({'id': compra.id}),
    );
  }

  static Map<String, dynamic> _baseData(CompraUpsertEntity compra) {
    return {
      'token': WSConstantes.token,
      'app_users_id': compra.appUsersId,
      'app_potreiros_id': compra.appPotreirosId,
      'app_animais_lotes_id': compra.appAnimaisLotesId,
      'data': compra.data,
      'tipo_compra': compra.tipoCompra,
      'valor_unitario': compra.valorUnitario,
      'fornecedor': compra.fornecedor,
      'municipio': compra.municipio,
      'obs': compra.obs,
    }..removeWhere((key, value) => value == null);
  }

  static Map<String, dynamic> _animalToJson(CompraUpsertAnimalEntity animal) {
    return {
      'app_animais_categorias_id': animal.appAnimaisCategoriasId,
      'app_animais_subcategorias_id': animal.appAnimaisSubcategoriasId,
      'ut_bases_raciais_id': animal.utBasesRaciaisId,
      'sexo': animal.sexo,
      'brinco': animal.brinco,
      'peso_total': animal.pesoTotal,
    }..removeWhere((key, value) => value == null);
  }
}
