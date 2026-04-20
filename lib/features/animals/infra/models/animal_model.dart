import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/animals/infra/models/animal_category_model.dart';
import 'package:costeira/features/animals/infra/models/animal_reference_model.dart';

class AnimalModel extends AnimalEntity {
  const AnimalModel({
    required super.id,
    required super.appUsersId,
    required super.appAnimaisCategoriasId,
    super.appAnimaisSubcategoriasId,
    super.utBasesRaciaisId,
    super.appAnimaisLotesId,
    super.appPotreirosId,
    required super.sexo,
    super.brinco,
    super.peso,
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

  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
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
      peso: double.tryParse(json['peso']?.toString() ?? ''),
      createAt: json['create_at']?.toString(),
      updateAt: json['update_at']?.toString(),
      obs: json['obs']?.toString(),
      status: json['status']?.toString(),
      categoria: json['categoria'] is Map<String, dynamic>
          ? AnimalCategoryModel.fromJson(
              json['categoria'] as Map<String, dynamic>,
            )
          : json['categoria'] is Map
          ? AnimalCategoryModel.fromJson(
              Map<String, dynamic>.from(json['categoria'] as Map),
            )
          : null,
      subcategoria: json['subcategoria'] is Map<String, dynamic>
          ? AnimalReferenceModel.fromJson(
              json['subcategoria'] as Map<String, dynamic>,
            )
          : json['subcategoria'] is Map
          ? AnimalReferenceModel.fromJson(
              Map<String, dynamic>.from(json['subcategoria'] as Map),
            )
          : null,
      baseRacial: json['base_racial'] is Map<String, dynamic>
          ? AnimalReferenceModel.fromJson(
              json['base_racial'] as Map<String, dynamic>,
            )
          : json['base_racial'] is Map
          ? AnimalReferenceModel.fromJson(
              Map<String, dynamic>.from(json['base_racial'] as Map),
            )
          : null,
      lote: json['lote'] is Map<String, dynamic>
          ? AnimalReferenceModel.fromJson(json['lote'] as Map<String, dynamic>)
          : json['lote'] is Map
          ? AnimalReferenceModel.fromJson(
              Map<String, dynamic>.from(json['lote'] as Map),
            )
          : null,
      potreiro: json['potreiro'] is Map<String, dynamic>
          ? AnimalReferenceModel.fromJson(
              json['potreiro'] as Map<String, dynamic>,
            )
          : json['potreiro'] is Map
          ? AnimalReferenceModel.fromJson(
              Map<String, dynamic>.from(json['potreiro'] as Map),
            )
          : null,
    );
  }
}
