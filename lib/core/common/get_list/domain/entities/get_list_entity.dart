import 'package:costeira/core/common/get_list/domain/entities/app_menu_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_category_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_item_entity.dart';

class GetListEntity {
  const GetListEntity({
    required this.animaisCategorias,
    required this.animaisBasesRaciais,
    required this.animaisSistemasProducoes,
    this.dashboardMenu = const [],
    this.menu = const [],
    this.menuNavigation = const [],
    this.menuMovimentacoes = const [],
    this.estoqueInsumosMotivos = const [],
    this.estoqueInsumosCategorias = const [],
    this.estoqueUnidadesMedidas = const [],
  });

  final List<ListCategoryEntity> animaisCategorias;
  final List<ListItemEntity> animaisBasesRaciais;
  final List<ListItemEntity> animaisSistemasProducoes;
  final List<AppMenuEntity> dashboardMenu;
  final List<AppMenuEntity> menu;
  final List<AppMenuEntity> menuNavigation;
  final List<AppMenuEntity> menuMovimentacoes;
  final List<ListItemEntity> estoqueInsumosMotivos;
  final List<ListCategoryEntity> estoqueInsumosCategorias;
  final List<ListItemEntity> estoqueUnidadesMedidas;
}
