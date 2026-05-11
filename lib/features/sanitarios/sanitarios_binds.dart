import 'package:costeira/features/sanitarios/domain/repository/sanitarios_datasource.dart';
import 'package:costeira/features/sanitarios/domain/usecases/create_sanitario_usecase.dart';
import 'package:costeira/features/sanitarios/domain/usecases/delete_sanitario_usecase.dart';
import 'package:costeira/features/sanitarios/domain/usecases/executar_sanitario_usecase.dart';
import 'package:costeira/features/sanitarios/domain/usecases/get_sanitario_charts_usecase.dart';
import 'package:costeira/features/sanitarios/domain/usecases/get_sanitarios_usecase.dart';
import 'package:costeira/features/sanitarios/domain/usecases/update_sanitario_usecase.dart';
import 'package:costeira/features/sanitarios/infra/data/sanitarios_datasource_impl.dart';
import 'package:costeira/features/sanitarios/presentation/controllers/delete_sanitario_controller.dart';
import 'package:costeira/features/sanitarios/presentation/controllers/executar_sanitario_controller.dart';
import 'package:costeira/features/sanitarios/presentation/controllers/get_sanitario_charts_controller.dart';
import 'package:costeira/features/sanitarios/presentation/controllers/list_sanitarios_controller.dart';
import 'package:costeira/features/sanitarios/presentation/controllers/sanitario_form_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';

class SanitariosBinds {
  static void register(Injector i) {
    i.addLazySingleton<SanitariosDatasource>(SanitariosDatasourceImpl.new);
    i.addLazySingleton(GetSanitariosUsecase.new);
    i.addLazySingleton(CreateSanitarioUsecase.new);
    i.addLazySingleton(UpdateSanitarioUsecase.new);
    i.addLazySingleton(DeleteSanitarioUsecase.new);
    i.addLazySingleton(ExecutarSanitarioUsecase.new);
    i.addLazySingleton(GetSanitarioChartsUsecase.new);
    i.add<ListSanitariosController>(ListSanitariosController.new);
    i.add<SanitarioFormController>(SanitarioFormController.new);
    i.add<DeleteSanitarioController>(DeleteSanitarioController.new);
    i.add<ExecutarSanitarioController>(ExecutarSanitarioController.new);
    i.add<GetSanitarioChartsController>(GetSanitarioChartsController.new);
  }
}
