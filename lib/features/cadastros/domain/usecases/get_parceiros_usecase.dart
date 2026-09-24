import 'package:costeira/features/cadastros/domain/entities/parceiro_filter_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_list_entity.dart';
import 'package:costeira/features/cadastros/domain/repository/parceiros_datasource.dart';

class GetParceirosUsecase {
  const GetParceirosUsecase(this._datasource);

  final ParceirosDatasource _datasource;

  Future<ParceiroListEntity> call(ParceiroFilterEntity filter) {
    return _datasource.getParceiros(filter);
  }
}
