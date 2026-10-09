import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/offline/offline_api_service.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/offline/sync/sync_priority.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/manejos_animais/domain/repository/manejos_animais_datasource.dart';
import 'package:costeira/features/manejos_animais/infra/models/manejo_animal_request_model.dart';

class ManejosAnimaisDatasourceImpl implements ManejosAnimaisDatasource {
  const ManejosAnimaisDatasourceImpl(this._offlineApiService);

  final OfflineApiService _offlineApiService;

  @override
  Future<ApiMessage> adicionar({
    required int appUsersId,
    required int appFazendasId,
    required Map<String, dynamic> fields,
  }) {
    final payload = ManejoAnimalRequestModel.create(
      appUsersId: appUsersId,
      appFazendasId: appFazendasId,
      fields: fields,
    ).data;
    AppLogger.info('MANEJO ANIMAL: PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'manejos',
      action: SyncOperation.create,
      endpoint: WSConstantes.manejosAdicionarAnimal,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Manejo salvo localmente para sincronizar.',
      rawResponseLog: 'MANEJO ANIMAL: RAW RESPONSE',
      parseResponse: (response) {
        final map = responseAsMap(response);
        if (!map.containsKey('status') && !map.containsKey('msg')) {
          throw ApiException('Resposta inesperada ao registrar o manejo.');
        }
        final message = ApiMessage.fromResponse(response);
        if (!message.isSuccess) {
          throw ApiException(message.message);
        }
        return message;
      },
    );
  }
}
