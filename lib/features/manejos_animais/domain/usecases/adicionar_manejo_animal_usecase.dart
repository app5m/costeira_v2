import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/manejos_animais/domain/repository/manejos_animais_datasource.dart';

class AdicionarManejoAnimalUsecase {
  const AdicionarManejoAnimalUsecase(this._datasource);

  final ManejosAnimaisDatasource _datasource;

  Future<ApiMessage> call({
    required int appUsersId,
    required int appFazendasId,
    required Map<String, dynamic> fields,
  }) {
    return _datasource.adicionar(
      appUsersId: appUsersId,
      appFazendasId: appFazendasId,
      fields: fields,
    );
  }
}
