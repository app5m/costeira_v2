import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo_filter.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/repository/manejo_datasource.dart';

class GetTiposManejoUsecase {
  const GetTiposManejoUsecase(this._datasource);

  final ManejoDataSource _datasource;

  Future<List<TipoManejo>> call(ManejoFilterEntity filter) async {
    final result = await _datasource.getManejos(filter);
    return result.tiposManejo;
  }
}
