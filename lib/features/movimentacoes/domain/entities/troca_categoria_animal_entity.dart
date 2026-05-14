import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_reference_entity.dart';

class TrocaCategoriaAnimalEntity {
  const TrocaCategoriaAnimalEntity({
    required this.movimentacaoAnimalId,
    required this.tipo,
    this.dataVinculo,
    required this.id,
    required this.appUsersId,
    required this.appAnimaisCategoriasId,
    this.appAnimaisSubcategoriasId,
    this.utBasesRaciaisId,
    this.appAnimaisLotesId,
    this.appPotreirosId,
    required this.sexo,
    this.brinco,
    this.pesoTotal,
    this.createAt,
    this.updateAt,
    this.obs,
    this.status,
    this.categoria,
    this.subcategoria,
    this.baseRacial,
    this.lote,
    this.catgOrigem,
    this.catgDestino,
    this.potreiro,
  });

  final int movimentacaoAnimalId;
  final String tipo;
  final String? dataVinculo;
  final int id;
  final int appUsersId;
  final int appAnimaisCategoriasId;
  final int? appAnimaisSubcategoriasId;
  final int? utBasesRaciaisId;
  final int? appAnimaisLotesId;
  final int? appPotreirosId;
  final int sexo;
  final String? brinco;
  final double? pesoTotal;
  final String? createAt;
  final String? updateAt;
  final String? obs;
  final String? status;
  final MovimentacaoReferenceEntity? categoria;
  final MovimentacaoReferenceEntity? subcategoria;
  final MovimentacaoReferenceEntity? baseRacial;
  final MovimentacaoReferenceEntity? lote;
  final MovimentacaoReferenceEntity? catgOrigem;
  final MovimentacaoReferenceEntity? catgDestino;
  final MovimentacaoReferenceEntity? potreiro;
}
