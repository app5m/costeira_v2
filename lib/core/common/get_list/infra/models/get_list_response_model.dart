import 'package:costeira/core/common/get_list/domain/entities/get_list_entity.dart';
import 'package:costeira/core/common/get_list/infra/models/list_category_model.dart';
import 'package:costeira/core/common/get_list/infra/models/list_item_model.dart';

class GetListResponseModel extends GetListEntity {
  const GetListResponseModel({
    required super.animaisCategorias,
    required super.animaisBasesRaciais,
    required super.animaisSistemasProducoes,
  });

  factory GetListResponseModel.fromJson(Map<String, dynamic> json) {
    final categorias = (json['animais_categorias'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => ListCategoryModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);

    final basesRaciais =
        (json['animais_bases_raciais'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((item) => ListItemModel.fromJson(Map<String, dynamic>.from(item)))
            .toList(growable: false);

    final sistemasProducoes =
        (json['animais_sistemas_producoes'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((item) => ListItemModel.fromJson(Map<String, dynamic>.from(item)))
            .toList(growable: false);

    return GetListResponseModel(
      animaisCategorias: categorias,
      animaisBasesRaciais: basesRaciais,
      animaisSistemasProducoes: sistemasProducoes,
    );
  }
}
