import 'package:costeira/core/common/get_list/domain/entities/list_category_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_item_entity.dart';

class GetListEntity {
  const GetListEntity({
    required this.animaisCategorias,
    required this.animaisBasesRaciais,
    required this.animaisSistemasProducoes,
  });

  final List<ListCategoryEntity> animaisCategorias;
  final List<ListItemEntity> animaisBasesRaciais;
  final List<ListItemEntity> animaisSistemasProducoes;
}
