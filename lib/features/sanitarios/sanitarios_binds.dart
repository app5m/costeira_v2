import 'package:costeira/features/sanitarios/domain/repository/sanitarios_datasource.dart';
import 'package:costeira/features/sanitarios/domain/usecases/create_sanitario_usecase.dart';
import 'package:costeira/features/sanitarios/domain/usecases/get_sanitarios_usecase.dart';
import 'package:costeira/features/sanitarios/domain/usecases/update_sanitario_usecase.dart';
import 'package:costeira/features/sanitarios/infra/data/sanitarios_datasource_impl.dart';
import 'package:costeira/features/sanitarios/presentation/controllers/list_sanitarios_controller.dart';
import 'package:costeira/features/sanitarios/presentation/controllers/sanitario_form_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';

class SanitariosBinds {
  static void register(Injector i) {
    i.addLazySingleton<SanitariosDatasource>(SanitariosDatasourceImpl.new);
    i.addLazySingleton(GetSanitariosUsecase.new);
    i.addLazySingleton(CreateSanitarioUsecase.new);
    i.addLazySingleton(UpdateSanitarioUsecase.new);
    i.add<ListSanitariosController>(ListSanitariosController.new);
    i.add<SanitarioFormController>(SanitarioFormController.new);
  }
}
