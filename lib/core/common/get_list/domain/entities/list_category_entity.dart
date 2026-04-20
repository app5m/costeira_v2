import 'package:costeira/core/common/get_list/domain/entities/list_item_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_subcategory_entity.dart';

class ListCategoryEntity extends ListItemEntity {
  const ListCategoryEntity({
    required super.id,
    required super.nome,
    required this.sexo,
    required this.subcategorias,
  });

  final int sexo;
  final List<ListSubcategoryEntity> subcategorias;
}
