import 'package:costeira/core/common/get_list/domain/entities/list_category_entity.dart';
import 'package:costeira/core/common/get_list/infra/models/list_subcategory_model.dart';

class ListCategoryModel extends ListCategoryEntity {
  const ListCategoryModel({
    required super.id,
    required super.nome,
    required super.sexo,
    required super.subcategorias,
  });

  factory ListCategoryModel.fromJson(Map<String, dynamic> json) {
    final rawSubcategories =
        (json['subcategorias'] as List<dynamic>? ?? const []);

    final subcategorias = rawSubcategories
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((item) {
          final id = int.tryParse(item['id']?.toString() ?? '') ?? 0;
          final nome = item['nome']?.toString().trim() ?? '';
          return id > 0 && nome.isNotEmpty;
        })
        .map(ListSubcategoryModel.fromJson)
        .toList(growable: false);

    return ListCategoryModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nome: json['nome']?.toString().trim() ?? '',
      sexo: int.tryParse(json['sexo']?.toString() ?? '') ?? 0,
      subcategorias: subcategorias,
    );
  }
}
