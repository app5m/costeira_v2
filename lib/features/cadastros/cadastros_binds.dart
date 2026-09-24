import 'package:costeira/core/services/places_service.dart';
import 'package:costeira/features/cadastros/domain/repository/parceiros_datasource.dart';
import 'package:costeira/features/cadastros/domain/usecases/create_parceiro_usecase.dart';
import 'package:costeira/features/cadastros/domain/usecases/delete_parceiro_usecase.dart';
import 'package:costeira/features/cadastros/domain/usecases/get_parceiros_usecase.dart';
import 'package:costeira/features/cadastros/domain/usecases/update_parceiro_usecase.dart';
import 'package:costeira/features/cadastros/infra/data/parceiros_datasource_impl.dart';
import 'package:costeira/features/cadastros/presentation/controllers/delete_parceiro_controller.dart';
import 'package:costeira/features/cadastros/presentation/controllers/list_parceiros_controller.dart';
import 'package:costeira/features/cadastros/presentation/controllers/save_parceiro_controller.dart';
import 'package:costeira/features/cadastros/presentation/page_controllers/parceiro_form_page_controller.dart';
import 'package:costeira/features/cadastros/presentation/page_controllers/parceiros_list_page_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';

class CadastrosBinds {
  static void register(Injector i) {
    i.addLazySingleton<PlacesService>(PlacesService.new);
    i.addLazySingleton<ParceirosDatasource>(ParceirosDatasourceImpl.new);
    i.addLazySingleton(GetParceirosUsecase.new);
    i.addLazySingleton(CreateParceiroUsecase.new);
    i.addLazySingleton(UpdateParceiroUsecase.new);
    i.addLazySingleton(DeleteParceiroUsecase.new);
    i.add(ListParceirosController.new);
    i.add(SaveParceiroController.new);
    i.add(DeleteParceiroController.new);
    i.add(ParceirosListPageController.new);
    i.add(ParceiroFormPageController.new);
  }
}
