import 'package:costeira/features/climate_and_rain/domain/repository/climate_datasource.dart';
import 'package:costeira/features/climate_and_rain/domain/usecases/create_climate_usecase.dart';
import 'package:costeira/features/climate_and_rain/domain/usecases/delete_climate_usecase.dart';
import 'package:costeira/features/climate_and_rain/domain/usecases/get_climate_charts_usecase.dart';
import 'package:costeira/features/climate_and_rain/domain/usecases/get_climates_usecase.dart';
import 'package:costeira/features/climate_and_rain/domain/usecases/update_climate_usecase.dart';
import 'package:costeira/features/climate_and_rain/infra/data/climate_datasource_impl.dart';
import 'package:costeira/features/climate_and_rain/presentation/controllers/add_climate_controller.dart';
import 'package:costeira/features/climate_and_rain/presentation/controllers/delete_climate_controller.dart';
import 'package:costeira/features/climate_and_rain/presentation/controllers/edit_climate_controller.dart';
import 'package:costeira/features/climate_and_rain/presentation/controllers/get_climate_charts_controller.dart';
import 'package:costeira/features/climate_and_rain/presentation/controllers/list_climates_controller.dart';
import 'package:costeira/features/climate_and_rain/presentation/page_controllers/climate_add_page_controller.dart';
import 'package:costeira/features/climate_and_rain/presentation/page_controllers/climate_edit_page_controller.dart';
import 'package:costeira/features/climate_and_rain/presentation/page_controllers/climate_list_page_controller.dart';
import 'package:costeira/features/climate_and_rain/presentation/page_controllers/climate_page_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ClimateAndRainBinds {
  static void register(Injector i) {
    i.addLazySingleton<ClimateDatasource>(ClimateDatasourceImpl.new);
    i.addLazySingleton(CreateClimateUsecase.new);
    i.addLazySingleton(UpdateClimateUsecase.new);
    i.addLazySingleton(GetClimatesUsecase.new);
    i.addLazySingleton(DeleteClimateUsecase.new);
    i.addLazySingleton(GetClimateChartsUsecase.new);
    i.add<ListClimatesController>(ListClimatesController.new);
    i.add<AddClimateController>(AddClimateController.new);
    i.add<EditClimateController>(EditClimateController.new);
    i.add<DeleteClimateController>(DeleteClimateController.new);
    i.add<GetClimateChartsController>(GetClimateChartsController.new);
    i.add<ClimatePageController>(ClimatePageController.new);
    i.add<ClimateListPageController>(ClimateListPageController.new);
    i.add<ClimateAddPageController>(ClimateAddPageController.new);
    i.add<ClimateEditPageController>(ClimateEditPageController.new);
  }
}
