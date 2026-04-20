import 'package:costeira/core/common/get_list/domain/entities/list_item_entity.dart';

class ListItemModel extends ListItemEntity {
  const ListItemModel({required super.id, required super.nome});

  factory ListItemModel.fromJson(Map<String, dynamic> json) {
    return ListItemModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nome: json['nome']?.toString().trim() ?? '',
    );
  }
}
