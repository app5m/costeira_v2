import 'package:costeira/core/common/get_list/domain/entities/list_subcategory_entity.dart';

class ListSubcategoryModel extends ListSubcategoryEntity {
  const ListSubcategoryModel({required super.id, required super.nome});

  factory ListSubcategoryModel.fromJson(Map<String, dynamic> json) {
    return ListSubcategoryModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nome: json['nome']?.toString().trim() ?? '',
    );
  }
}
