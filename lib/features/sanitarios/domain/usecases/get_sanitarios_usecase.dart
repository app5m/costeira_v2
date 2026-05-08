import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';
import 'package:costeira/features/sanitarios/domain/repository/sanitarios_datasource.dart';

class GetSanitariosUsecase {
  const GetSanitariosUsecase(this._datasource);

  final SanitariosDatasource _datasource;

  Future<SanitariosListEntity> call(SanitariosFilterEntity filter) {
    return _datasource.getSanitarios(filter);
  }
}
