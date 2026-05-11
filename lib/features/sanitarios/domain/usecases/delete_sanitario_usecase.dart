import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';
import 'package:costeira/features/sanitarios/domain/repository/sanitarios_datasource.dart';

class DeleteSanitarioUsecase {
  const DeleteSanitarioUsecase(this._datasource);

  final SanitariosDatasource _datasource;

  Future<ApiMessage> call(DeleteSanitarioEntity sanitario) {
    return _datasource.deleteSanitario(sanitario);
  }
}
