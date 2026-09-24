import 'package:costeira/core/common/get_list/domain/repository/get_list_datasource.dart';
import 'package:costeira/core/common/get_list/domain/usecases/get_list_usecase.dart';
import 'package:costeira/core/common/get_list/infra/data/get_list_datasource_impl.dart';
import 'package:costeira/core/common/get_list/presentation/controllers/get_list_controller.dart';
import 'package:costeira/core/menus/app_menus_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';

class GetListBinds {
  static void register(Injector i) {
    i.addLazySingleton<GetListDatasource>(GetListDatasourceImpl.new);
    i.addLazySingleton(GetListUsecase.new);
    i.addLazySingleton(AppMenusController.new);
    i.add<GetListController>(GetListController.new);
  }
}
