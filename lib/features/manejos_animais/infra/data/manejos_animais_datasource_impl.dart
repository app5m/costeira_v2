import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/offline/offline_api_service.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/offline/sync/sync_priority.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/manejos_animais/domain/entities/manejo_animal_lista.dart';
import 'package:costeira/features/manejos_animais/domain/repository/manejos_animais_datasource.dart';
import 'package:costeira/features/manejos_animais/infra/models/manejo_animal_lista_request_model.dart';
import 'package:costeira/features/manejos_animais/infra/models/manejo_animal_lista_response_model.dart';
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
    return _post(
      appUsersId: appUsersId,
      appFazendasId: appFazendasId,
      fields: fields,
      endpoint: WSConstantes.manejosAdicionarAnimal,
      log: 'MANEJO ANIMAL',
    );
  }

  @override
  Future<ApiMessage> adicionarCampo({
    required int appUsersId,
    required int appFazendasId,
    required Map<String, dynamic> fields,
  }) {
    return _post(
      appUsersId: appUsersId,
      appFazendasId: appFazendasId,
      fields: fields,
      endpoint: WSConstantes.manejosAdicionarCampo,
      log: 'MANEJO CAMPO',
    );
  }

  @override
  Future<ApiMessage> adicionarReprodutivo({
    required int appUsersId,
    required int appFazendasId,
    required Map<String, dynamic> fields,
  }) {
    return _post(
      appUsersId: appUsersId,
      appFazendasId: appFazendasId,
      fields: fields,
      endpoint: WSConstantes.manejosAdicionarReprodutivo,
      log: 'MANEJO REPRODUTIVO',
    );
  }

  Future<ApiMessage> _post({
    required int appUsersId,
    required int appFazendasId,
    required Map<String, dynamic> fields,
    required String endpoint,
    required String log,
  }) {
    final payload = ManejoAnimalRequestModel.create(
      appUsersId: appUsersId,
      appFazendasId: appFazendasId,
      fields: fields,
    ).data;
    AppLogger.info('$log: PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'manejos',
      action: SyncOperation.create,
      endpoint: endpoint,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Manejo salvo localmente para sincronizar.',
      rawResponseLog: '$log: RAW RESPONSE',
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

  @override
  Future<ManejoAnimalListaEntity> listar({
    required int appUsersId,
    required int appFazendasId,
    required int idCategoria,
    bool? estacaoAtiva,
    String? dataReferencia,
  }) {
    final payload = ManejoAnimalListaRequestModel.create(
      appUsersId: appUsersId,
      appFazendasId: appFazendasId,
      idCategoria: idCategoria,
      estacaoAtiva: estacaoAtiva,
      dataReferencia: dataReferencia,
    ).data;
    AppLogger.info('MANEJO ANIMAL: LIST PAYLOAD=$payload');

    return _offlineApiService.postCached<ManejoAnimalListaEntity>(
      endpoint: WSConstantes.manejosListar,
      payload: payload,
      userId: appUsersId,
      parser: ManejoAnimalListaResponseModel.fromResponse,
      missingCacheMessage: 'Sem conexão e sem dados salvos para manejos.',
      rawResponseLog: 'MANEJO ANIMAL: LIST RAW RESPONSE',
    );
  }
}
