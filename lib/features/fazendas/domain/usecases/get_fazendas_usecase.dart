import 'package:costeira/features/fazendas/domain/entities/fazenda_filter_entity.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_list_entity.dart';
import 'package:costeira/features/fazendas/domain/repository/fazendas_datasource.dart';

class GetFazendasUsecase {
  const GetFazendasUsecase(this._datasource);

  final FazendasDatasource _datasource;

  Future<FazendaListEntity> call(FazendaFilterEntity filter) {
    return _datasource.getFazendas(filter);
  }
}
