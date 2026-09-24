import 'package:costeira/features/fazendas/domain/repository/fazendas_datasource.dart';
import 'package:costeira/features/fazendas/domain/usecases/create_fazenda_usecase.dart';
import 'package:costeira/features/fazendas/domain/usecases/get_fazendas_usecase.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/fazendas/domain/usecases/update_fazenda_usecase.dart';
import 'package:costeira/features/fazendas/infra/data/fazendas_datasource_impl.dart';
import 'package:costeira/features/fazendas/presentation/controllers/list_fazendas_controller.dart';
import 'package:costeira/features/fazendas/presentation/controllers/save_fazenda_controller.dart';
import 'package:costeira/features/fazendas/presentation/page_controllers/fazenda_form_page_controller.dart';
import 'package:costeira/features/fazendas/presentation/page_controllers/fazendas_list_page_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';

class FazendasBinds {
  static void register(Injector i) {
    i.addLazySingleton<FazendasDatasource>(FazendasDatasourceImpl.new);
    i.addLazySingleton(GetFazendasUsecase.new);
    i.addLazySingleton(ResolveCurrentFarmId.new);
    i.addLazySingleton(CreateFazendaUsecase.new);
    i.addLazySingleton(UpdateFazendaUsecase.new);
    i.add(ListFazendasController.new);
    i.add(SaveFazendaController.new);
    i.add(FazendasListPageController.new);
    i.add(FazendaFormPageController.new);
  }
}
