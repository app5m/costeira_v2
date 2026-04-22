import 'package:costeira/features/animals/domain/usecases/create_animal_lot_usecase.dart';
import 'package:costeira/features/animals/domain/repository/animals_datasource.dart';
import 'package:costeira/features/animals/domain/usecases/create_animal_usecase.dart';
import 'package:costeira/features/animals/domain/usecases/delete_animal_lot_usecase.dart';
import 'package:costeira/features/animals/domain/usecases/delete_animal_usecase.dart';
import 'package:costeira/features/animals/domain/usecases/get_animal_charts_usecase.dart';
import 'package:costeira/features/animals/domain/usecases/get_animal_lots_usecase.dart';
import 'package:costeira/features/animals/domain/usecases/get_animals_usecase.dart';
import 'package:costeira/features/animals/domain/usecases/update_animal_lot_usecase.dart';
import 'package:costeira/features/animals/domain/usecases/update_animal_usecase.dart';
import 'package:costeira/features/animals/infra/data/animals_datasource_impl.dart';
import 'package:costeira/features/animals/presentation/controllers/add_animal_lot_controller.dart';
import 'package:costeira/features/animals/presentation/controllers/add_animal_controller.dart';
import 'package:costeira/features/animals/presentation/controllers/delete_animal_lot_controller.dart';
import 'package:costeira/features/animals/presentation/controllers/delete_animal_controller.dart';
import 'package:costeira/features/animals/presentation/controllers/edit_animal_lot_controller.dart';
import 'package:costeira/features/animals/presentation/controllers/edit_animal_controller.dart';
import 'package:costeira/features/animals/presentation/controllers/get_animal_charts_controller.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animal_lots_controller.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animals_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/add_lote_page_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/animal_add_page_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/animal_edit_page_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/animal_list_page_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/animals_page_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/edit_lote_page_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/lotes_page_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AnimalsBinds {
  static void register(Injector i) {
    i.addLazySingleton<AnimalsDatasource>(AnimalsDatasourceImpl.new);
    i.addLazySingleton(CreateAnimalUsecase.new);
    i.addLazySingleton(UpdateAnimalUsecase.new);
    i.addLazySingleton(GetAnimalsUsecase.new);
    i.addLazySingleton(DeleteAnimalUsecase.new);
    i.addLazySingleton(CreateAnimalLotUsecase.new);
    i.addLazySingleton(UpdateAnimalLotUsecase.new);
    i.addLazySingleton(GetAnimalLotsUsecase.new);
    i.addLazySingleton(DeleteAnimalLotUsecase.new);
    i.addLazySingleton(GetAnimalChartsUsecase.new);
    i.add<AddAnimalController>(AddAnimalController.new);
    i.add<EditAnimalController>(EditAnimalController.new);
    i.add<ListAnimalsController>(ListAnimalsController.new);
    i.add<DeleteAnimalController>(DeleteAnimalController.new);
    i.add<AddAnimalLotController>(AddAnimalLotController.new);
    i.add<EditAnimalLotController>(EditAnimalLotController.new);
    i.add<ListAnimalLotsController>(ListAnimalLotsController.new);
    i.add<DeleteAnimalLotController>(DeleteAnimalLotController.new);
    i.add<GetAnimalChartsController>(GetAnimalChartsController.new);
    i.add<AnimalsPageController>(AnimalsPageController.new);
    i.add<AnimalListPageController>(AnimalListPageController.new);
    i.add<AnimalAddPageController>(AnimalAddPageController.new);
    i.add<AnimalEditPageController>(AnimalEditPageController.new);
    i.add<LotesPageController>(LotesPageController.new);
    i.add<AddLotePageController>(AddLotePageController.new);
    i.add<EditLotePageController>(EditLotePageController.new);
  }
}
