import 'package:costeira/features/insumos/domain/usecases/create_insumo_registro_usecase.dart';
import 'package:costeira/features/insumos/domain/usecases/create_insumo_usecase.dart';
import 'package:costeira/features/insumos/domain/usecases/delete_insumo_registro_usecase.dart';
import 'package:costeira/features/insumos/domain/usecases/delete_insumo_usecase.dart';
import 'package:costeira/features/insumos/domain/repository/insumos_datasource.dart';
import 'package:costeira/features/insumos/domain/usecases/get_insumo_charts_usecase.dart';
import 'package:costeira/features/insumos/domain/usecases/get_insumos_usecase.dart';
import 'package:costeira/features/insumos/domain/usecases/get_insumos_tipo_usecase.dart';
import 'package:costeira/features/insumos/domain/usecases/update_insumo_registro_usecase.dart';
import 'package:costeira/features/insumos/domain/usecases/update_insumo_usecase.dart';
import 'package:costeira/features/insumos/infra/data/insumos_datasource_impl.dart';
import 'package:costeira/features/insumos/presentation/controllers/add_insumo_controller.dart';
import 'package:costeira/features/insumos/presentation/controllers/add_insumo_registro_controller.dart';
import 'package:costeira/features/insumos/presentation/controllers/delete_insumo_controller.dart';
import 'package:costeira/features/insumos/presentation/controllers/get_insumo_charts_controller.dart';
import 'package:costeira/features/insumos/presentation/controllers/list_insumos_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';

class InsumosBinds {
  static void register(Injector i) {
    i.addLazySingleton<InsumosDatasource>(InsumosDatasourceImpl.new);
    i.addLazySingleton(GetInsumosUsecase.new);
    i.addLazySingleton(GetInsumoChartsUsecase.new);
    i.addLazySingleton(GetInsumosTipoUsecase.new);
    i.addLazySingleton(CreateInsumoUsecase.new);
    i.addLazySingleton(UpdateInsumoUsecase.new);
    i.addLazySingleton(CreateInsumoRegistroUsecase.new);
    i.addLazySingleton(UpdateInsumoRegistroUsecase.new);
    i.addLazySingleton(DeleteInsumoUsecase.new);
    i.addLazySingleton(DeleteInsumoRegistroUsecase.new);
    i.add<ListInsumosController>(ListInsumosController.new);
    i.add<AddInsumoController>(AddInsumoController.new);
    i.add<AddInsumoRegistroController>(AddInsumoRegistroController.new);
    i.add<DeleteInsumoController>(DeleteInsumoController.new);
    i.add<GetInsumoChartsController>(GetInsumoChartsController.new);
  }
}
