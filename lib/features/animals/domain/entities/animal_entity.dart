import 'package:costeira/features/animals/domain/entities/animal_category_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_reference_entity.dart';

class AnimalEntity {
  const AnimalEntity({
    required this.id,
    required this.appUsersId,
    required this.appAnimaisCategoriasId,
    this.appAnimaisSubcategoriasId,
    this.utBasesRaciaisId,
    this.appAnimaisLotesId,
    this.appPotreirosId,
    required this.sexo,
    this.brinco,
    this.peso,
    this.createAt,
    this.updateAt,
    this.obs,
    this.status,
    this.categoria,
    this.subcategoria,
    this.baseRacial,
    this.lote,
    this.potreiro,
  });

  final int id;
  final int appUsersId;
  final int appAnimaisCategoriasId;
  final int? appAnimaisSubcategoriasId;
  final int? utBasesRaciaisId;
  final int? appAnimaisLotesId;
  final int? appPotreirosId;
  final int sexo;
  final String? brinco;
  final double? peso;
  final String? createAt;
  final String? updateAt;
  final String? obs;
  final String? status;
  final AnimalCategoryEntity? categoria;
  final AnimalReferenceEntity? subcategoria;
  final AnimalReferenceEntity? baseRacial;
  final AnimalReferenceEntity? lote;
  final AnimalReferenceEntity? potreiro;
}
