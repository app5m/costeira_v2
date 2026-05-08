import 'package:costeira/features/pastagem_nutricao_suplemento/domain/repository/manejo_datasource.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/repository/suplemento_datasource.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/create_manejo_usecase.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/create_suplemento_registro_usecase.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/create_suplemento_usecase.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/delete_manejo_usecase.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/delete_suplemento_registro_usecase.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/delete_suplemento_usecase.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/get_manejo_charts_usecase.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/get_manejos_usecase.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/get_suplemento_charts_usecase.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/get_suplementos_usecase.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/get_tipos_manejo_usecase.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/update_manejo_usecase.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/update_suplemento_registro_usecase.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/update_suplemento_usecase.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/data/manejo_datasource_impl.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/data/suplemento_datasouce_impl.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/controllers/delete_manejo_controller.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/controllers/delete_suplemento_controller.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/controllers/get_manejo_charts_controller.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/controllers/get_suplemento_charts_controller.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/controllers/list_manejos_controller.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/controllers/list_suplementos_controller.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/controllers/manejo_form_controller.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/controllers/suplemento_form_controller.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/controllers/suplemento_registro_form_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';

class PastagemNutricaoSuplementoBinds {
  static void register(Injector i) {
    i.addLazySingleton<ManejoDataSource>(ManejoDataSourceImpl.new);
    i.addLazySingleton<SuplementoDatasource>(SuplementoDatasouceImpl.new);
    i.addLazySingleton(GetManejosUsecase.new);
    i.addLazySingleton(GetTiposManejoUsecase.new);
    i.addLazySingleton(CreateManejoUsecase.new);
    i.addLazySingleton(UpdateManejoUsecase.new);
    i.addLazySingleton(DeleteManejoUsecase.new);
    i.addLazySingleton(GetManejoChartsUsecase.new);
    i.addLazySingleton(GetSuplementosUsecase.new);
    i.addLazySingleton(GetSuplementoChartsUsecase.new);
    i.addLazySingleton(CreateSuplementoUsecase.new);
    i.addLazySingleton(UpdateSuplementoUsecase.new);
    i.addLazySingleton(CreateSuplementoRegistroUsecase.new);
    i.addLazySingleton(UpdateSuplementoRegistroUsecase.new);
    i.addLazySingleton(DeleteSuplementoUsecase.new);
    i.addLazySingleton(DeleteSuplementoRegistroUsecase.new);
    i.add<ListManejosController>(ListManejosController.new);
    i.add<ManejoFormController>(ManejoFormController.new);
    i.add<DeleteManejoController>(DeleteManejoController.new);
    i.add<GetManejoChartsController>(GetManejoChartsController.new);
    i.add<ListSuplementosController>(ListSuplementosController.new);
    i.add<GetSuplementoChartsController>(GetSuplementoChartsController.new);
    i.add<DeleteSuplementoController>(DeleteSuplementoController.new);
    i.add<SuplementoFormController>(SuplementoFormController.new);
    i.add<SuplementoRegistroFormController>(
      SuplementoRegistroFormController.new,
    );
  }
}
