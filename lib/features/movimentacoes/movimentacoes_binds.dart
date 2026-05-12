import 'package:costeira/features/movimentacoes/compras/domain/repository/compras_datasource.dart';
import 'package:costeira/features/movimentacoes/compras/domain/usecases/create_compra_usecase.dart';
import 'package:costeira/features/movimentacoes/compras/domain/usecases/delete_compra_usecase.dart';
import 'package:costeira/features/movimentacoes/compras/domain/usecases/update_compra_usecase.dart';
import 'package:costeira/features/movimentacoes/compras/infra/data/compras_datasource_impl.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/controllers/add_compra_controller.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/controllers/delete_compra_controller.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/controllers/edit_compra_controller.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/controllers/get_compra_charts_controller.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/controllers/list_compras_controller.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/page_controllers/compra_form_page_controller.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/page_controllers/compras_list_page_controller.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/page_controllers/compras_page_controller.dart';
import 'package:costeira/features/movimentacoes/domain/repository/movimentacoes_datasource.dart';
import 'package:costeira/features/movimentacoes/domain/usecases/get_compra_charts_usecase.dart';
import 'package:costeira/features/movimentacoes/domain/usecases/get_compras_usecase.dart';
import 'package:costeira/features/movimentacoes/infra/data/movimentacoes_datasource_impl.dart';
import 'package:flutter_modular/flutter_modular.dart';

class MovimentacoesBinds {
  static void register(Injector i) {
    i.addLazySingleton<MovimentacoesDatasource>(
      MovimentacoesDatasourceImpl.new,
    );
    i.addLazySingleton<ComprasDatasource>(ComprasDatasourceImpl.new);
    i.addLazySingleton(GetComprasUsecase.new);
    i.addLazySingleton(GetCompraChartsUsecase.new);
    i.addLazySingleton(CreateCompraUsecase.new);
    i.addLazySingleton(UpdateCompraUsecase.new);
    i.addLazySingleton(DeleteCompraUsecase.new);
    i.add<AddCompraController>(AddCompraController.new);
    i.add<EditCompraController>(EditCompraController.new);
    i.add<DeleteCompraController>(DeleteCompraController.new);
    i.add<GetCompraChartsController>(GetCompraChartsController.new);
    i.add<ListComprasController>(ListComprasController.new);
    i.add<ComprasPageController>(ComprasPageController.new);
    i.add<ComprasListPageController>(ComprasListPageController.new);
    i.add<CompraFormPageController>(CompraFormPageController.new);
  }
}
