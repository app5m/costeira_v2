import 'package:costeira/features/potreiros/domain/repository/potreiros_datasource.dart';
import 'package:costeira/features/potreiros/domain/usecases/create_potreiro_usecase.dart';
import 'package:costeira/features/potreiros/domain/usecases/delete_potreiro_usecase.dart';
import 'package:costeira/features/potreiros/domain/usecases/get_potreiro_charts_usecase.dart';
import 'package:costeira/features/potreiros/domain/usecases/get_potreiros_usecase.dart';
import 'package:costeira/features/potreiros/domain/usecases/update_potreiro_usecase.dart';
import 'package:costeira/features/potreiros/infra/data/potreiros_datasource_impl.dart';
import 'package:costeira/features/potreiros/presentation/controllers/add_potreiro_controller.dart';
import 'package:costeira/features/potreiros/presentation/controllers/delete_potreiro_controller.dart';
import 'package:costeira/features/potreiros/presentation/controllers/edit_potreiro_controller.dart';
import 'package:costeira/features/potreiros/presentation/controllers/get_potreiro_charts_controller.dart';
import 'package:costeira/features/potreiros/presentation/controllers/list_potreiros_controller.dart';
import 'package:costeira/features/potreiros/presentation/page_controllers/potreiro_add_page_controller.dart';
import 'package:costeira/features/potreiros/presentation/page_controllers/potreiro_edit_page_controller.dart';
import 'package:costeira/features/potreiros/presentation/page_controllers/potreiro_list_page_controller.dart';
import 'package:costeira/features/potreiros/presentation/page_controllers/potreiros_page_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';

class PotreirosBinds {
  static void register(Injector i) {
    i.addLazySingleton<PotreirosDatasource>(PotreirosDatasourceImpl.new);
    i.addLazySingleton(CreatePotreiroUsecase.new);
    i.addLazySingleton(UpdatePotreiroUsecase.new);
    i.addLazySingleton(GetPotreirosUsecase.new);
    i.addLazySingleton(DeletePotreiroUsecase.new);
    i.addLazySingleton(GetPotreiroChartsUsecase.new);
    i.add<ListPotreirosController>(ListPotreirosController.new);
    i.add<AddPotreiroController>(AddPotreiroController.new);
    i.add<EditPotreiroController>(EditPotreiroController.new);
    i.add<DeletePotreiroController>(DeletePotreiroController.new);
    i.add<GetPotreiroChartsController>(GetPotreiroChartsController.new);
    i.add<PotreirosPageController>(PotreirosPageController.new);
    i.add<PotreiroListPageController>(PotreiroListPageController.new);
    i.add<PotreiroAddPageController>(PotreiroAddPageController.new);
    i.add<PotreiroEditPageController>(PotreiroEditPageController.new);
  }
}
