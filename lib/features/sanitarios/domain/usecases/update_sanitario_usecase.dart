import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';
import 'package:costeira/features/sanitarios/domain/repository/sanitarios_datasource.dart';

class UpdateSanitarioUsecase {
  const UpdateSanitarioUsecase(this._datasource);

  final SanitariosDatasource _datasource;

  Future<ApiMessage> call(SanitarioUpsertEntity sanitario) {
    return _datasource.updateSanitario(sanitario);
  }
}
