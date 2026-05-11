import 'package:costeira/features/dashboard/domain/repository/dashboard_datasource.dart';
import 'package:costeira/features/dashboard/domain/usecases/get_dashboard_usecase.dart';
import 'package:costeira/features/dashboard/infra/data/dashboard_datasource_impl.dart';
import 'package:costeira/features/dashboard/presentation/controllers/get_dashboard_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';

class DashboardBinds {
  static void register(Injector i) {
    i.addLazySingleton<DashboardDatasource>(DashboardDatasourceImpl.new);
    i.addLazySingleton(GetDashboardUsecase.new);
    i.add<GetDashboardController>(GetDashboardController.new);
  }
}
