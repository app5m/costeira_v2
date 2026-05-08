import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';
import 'package:costeira/core/models/api_message.dart';

abstract class SanitariosDatasource {
  Future<SanitariosListEntity> getSanitarios(SanitariosFilterEntity filter);
  Future<ApiMessage> createSanitario(SanitarioUpsertEntity sanitario);
  Future<ApiMessage> updateSanitario(SanitarioUpsertEntity sanitario);
}
