import 'package:costeira/features/manejos_animais/domain/repository/manejos_animais_datasource.dart';
import 'package:costeira/features/manejos_animais/domain/usecases/adicionar_manejo_animal_usecase.dart';
import 'package:costeira/features/manejos_animais/domain/usecases/listar_manejos_animais_usecase.dart';
import 'package:costeira/features/manejos_animais/infra/data/manejos_animais_datasource_impl.dart';
import 'package:costeira/features/manejos_animais/presentation/controllers/adicionar_manejo_animal_controller.dart';
import 'package:costeira/features/manejos_animais/presentation/controllers/listar_manejos_animais_controller.dart';
import 'package:costeira/features/manejos_animais/presentation/page_controllers/manejo_animal_sessao_controller.dart';
import 'package:costeira/features/manejos_animais/presentation/page_controllers/manejo_campo_controller.dart';
import 'package:costeira/features/manejos_animais/presentation/page_controllers/manejo_reprodutivo_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ManejosAnimaisBinds {
  static void register(Injector i) {
    i.addLazySingleton<ManejosAnimaisDatasource>(ManejosAnimaisDatasourceImpl.new);
    i.addLazySingleton(AdicionarManejoAnimalUsecase.new);
    i.addLazySingleton(ListarManejosAnimaisUsecase.new);
    i.add(AdicionarManejoAnimalController.new);
    i.add(ListarManejosAnimaisController.new);
    i.add(ManejoAnimalSessaoController.new);
    i.add(ManejoCampoController.new);
    i.add(ManejoReprodutivoController.new);
  }
}
