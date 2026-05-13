import 'package:costeira/features/movimentacoes/infra/models/movimentacao_reference_model.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_animal_entity.dart';

class VendaAnimalModel extends VendaAnimalEntity {
  const VendaAnimalModel({
    super.movimentacaoAnimalId,
    super.tipo,
    super.dataVinculo,
    required super.id,
    super.appUsersId,
    super.appAnimaisCategoriasId,
    super.appAnimaisSubcategoriasId,
    super.utBasesRaciaisId,
    super.appAnimaisLotesId,
    super.appPotreirosId,
    super.sexo,
    super.brinco,
    super.pesoTotal,
    super.createAt,
    super.updateAt,
    super.obs,
    super.status,
    super.categoria,
    super.subcategoria,
    super.baseRacial,
    super.lote,
    super.potreiro,
  });

  factory VendaAnimalModel.fromJson(Map<String, dynamic> json) {
    return VendaAnimalModel(
      movimentacaoAnimalId: int.tryParse(
        json['movimentacao_animal_id']?.toString() ?? '',
      ),
      tipo: json['tipo']?.toString(),
      dataVinculo: json['data_vinculo']?.toString(),
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      appUsersId: int.tryParse(json['app_users_id']?.toString() ?? ''),
      appAnimaisCategoriasId: int.tryParse(
        json['app_animais_categorias_id']?.toString() ?? '',
      ),
      appAnimaisSubcategoriasId: int.tryParse(
        json['app_animais_subcategorias_id']?.toString() ?? '',
      ),
      utBasesRaciaisId: int.tryParse(
        json['ut_bases_raciais_id']?.toString() ?? '',
      ),
      appAnimaisLotesId: int.tryParse(
        json['app_animais_lotes_id']?.toString() ?? '',
      ),
      appPotreirosId: int.tryParse(json['app_potreiros_id']?.toString() ?? ''),
      sexo: int.tryParse(json['sexo']?.toString() ?? ''),
      brinco: json['brinco']?.toString(),
      pesoTotal: _toDouble(json['peso_total']),
      createAt: json['create_at']?.toString(),
      updateAt: json['update_at']?.toString(),
      obs: json['obs']?.toString(),
      status: json['status']?.toString(),
      categoria: MovimentacaoReferenceModel.maybeFromJson(json['categoria']),
      subcategoria: MovimentacaoReferenceModel.maybeFromJson(
        json['subcategoria'],
      ),
      baseRacial: MovimentacaoReferenceModel.maybeFromJson(json['base_racial']),
      lote: MovimentacaoReferenceModel.maybeFromJson(json['lote']),
      potreiro: MovimentacaoReferenceModel.maybeFromJson(json['potreiro']),
    );
  }

  static double? _toDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '');
  }
}
