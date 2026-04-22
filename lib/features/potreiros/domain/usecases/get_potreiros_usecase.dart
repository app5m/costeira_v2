import 'package:costeira/features/potreiros/domain/entities/potreiros_filter_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiros_list_entity.dart';
import 'package:costeira/features/potreiros/domain/repository/potreiros_datasource.dart';

class GetPotreirosUsecase {
  const GetPotreirosUsecase(this._datasource);

  final PotreirosDatasource _datasource;

  Future<PotreirosListEntity> call(PotreirosFilterEntity filter) {
    return _datasource.getPotreiros(filter);
  }
}
