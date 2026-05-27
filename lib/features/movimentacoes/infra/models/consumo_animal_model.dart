import 'package:costeira/features/movimentacoes/domain/entities/consumo_animal_entity.dart';
import 'package:costeira/features/movimentacoes/infra/models/movimentacao_reference_model.dart';

class ConsumoAnimalModel extends ConsumoAnimalEntity {
  const ConsumoAnimalModel({
    required super.movimentacaoAnimalId,
    required super.tipo,
    super.dataVinculo,
    required super.id,
    required super.appUsersId,
    required super.appAnimaisCategoriasId,
    super.appAnimaisSubcategoriasId,
    super.utBasesRaciaisId,
    super.appAnimaisLotesId,
    super.appPotreirosId,
    required super.sexo,
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

  factory ConsumoAnimalModel.fromJson(Map<String, dynamic> json) {
    return ConsumoAnimalModel(
      movimentacaoAnimalId:
          int.tryParse(json['movimentacao_animal_id']?.toString() ?? '') ?? 0,
      tipo: json['tipo']?.toString() ?? '',
      dataVinculo: json['data_vinculo']?.toString(),
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      appUsersId: int.tryParse(json['app_users_id']?.toString() ?? '') ?? 0,
      appAnimaisCategoriasId:
          int.tryParse(json['app_animais_categorias_id']?.toString() ?? '') ??
          0,
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
      sexo: int.tryParse(json['sexo']?.toString() ?? '') ?? 0,
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
