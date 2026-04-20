import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/animals/domain/entities/animal_charts_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_charts_filter_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lots_filter_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lots_list_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_upsert_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_upsert_entity.dart';
import 'package:costeira/features/animals/domain/entities/animals_filter_entity.dart';
import 'package:costeira/features/animals/domain/entities/animals_list_entity.dart';
import 'package:costeira/features/animals/domain/entities/delete_animal_entity.dart';
import 'package:costeira/features/animals/domain/entities/delete_animal_lot_entity.dart';
import 'package:costeira/features/animals/domain/repository/animals_datasource.dart';
import 'package:costeira/features/animals/infra/models/animal_charts_filter_request_model.dart';
import 'package:costeira/features/animals/infra/models/animal_charts_response_model.dart';
import 'package:costeira/features/animals/infra/models/animal_lots_filter_request_model.dart';
import 'package:costeira/features/animals/infra/models/animal_lots_list_response_model.dart';
import 'package:costeira/features/animals/infra/models/animal_lot_upsert_request_model.dart';
import 'package:costeira/features/animals/infra/models/animal_upsert_request_model.dart';
import 'package:costeira/features/animals/infra/models/animals_filter_request_model.dart';
import 'package:costeira/features/animals/infra/models/animals_list_response_model.dart';
import 'package:costeira/features/animals/infra/models/delete_animal_lot_request_model.dart';
import 'package:costeira/features/animals/infra/models/delete_animal_request_model.dart';

class AnimalsDatasourceImpl implements AnimalsDatasource {
  const AnimalsDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ApiMessage> createAnimal(AnimalUpsertEntity animal) async {
    if (animal.appUsersId == null) {
      throw ApiException('Usuário não autenticado para cadastrar animal.');
    }

    final payload = AnimalUpsertRequestModel.create(animal).data;
    AppLogger.info('ANIMAIS DATASOURCE: CREATE PAYLOAD=$payload');

    final response = await _apiClient.post(WSConstantes.animaisAdd, data: payload);

    AppLogger.success('ANIMAIS DATASOURCE: CREATE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'CREATE ANIMAL',
      expectedSuccessMessage: 'Animal cadastrado com sucesso',
    );
  }

  @override
  Future<ApiMessage> updateAnimal(AnimalUpsertEntity animal) async {
    if (animal.id == null) {
      throw ApiException('Informe o id do animal para atualizar.');
    }
    if (animal.appUsersId == null) {
      throw ApiException('Usuário não autenticado para atualizar animal.');
    }

    final payload = AnimalUpsertRequestModel.update(animal).data;
    AppLogger.info('ANIMAIS DATASOURCE: UPDATE PAYLOAD=$payload');

    final response = await _apiClient.post(WSConstantes.animaisEdit, data: payload);

    AppLogger.success('ANIMAIS DATASOURCE: UPDATE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'UPDATE ANIMAL',
      expectedSuccessMessage: 'Animal atualizado com sucesso',
    );
  }

  @override
  Future<AnimalsListEntity> getAnimals(AnimalsFilterEntity filter) async {
    final payload = AnimalsFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('ANIMAIS DATASOURCE: LIST PAYLOAD=$payload');

    final response = await _apiClient.post(WSConstantes.animaisListar, data: payload);

    AppLogger.success('ANIMAIS DATASOURCE: LIST RAW RESPONSE=$response');
    return AnimalsListResponseModel.fromJson(responseAsMap(response));
  }

  @override
  Future<ApiMessage> deleteAnimal(DeleteAnimalEntity animal) async {
    final payload = DeleteAnimalRequestModel.fromEntity(animal).data;
    AppLogger.info('ANIMAIS DATASOURCE: DELETE PAYLOAD=$payload');

    final response = await _apiClient.post(WSConstantes.animaisExcluir, data: payload);

    AppLogger.success('ANIMAIS DATASOURCE: DELETE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'DELETE ANIMAL',
      expectedSuccessMessage: 'Animal excluído com sucesso',
    );
  }

  @override
  Future<ApiMessage> createAnimalLot(AnimalLotUpsertEntity lot) async {
    if (lot.appUsersId == null) {
      throw ApiException('Usuário não autenticado para cadastrar lote.');
    }

    final payload = AnimalLotUpsertRequestModel.create(lot).data;
    AppLogger.info('ANIMAIS DATASOURCE: CREATE LOT PAYLOAD=$payload');

    final response = await _apiClient.post(WSConstantes.animaisAdicionarLote, data: payload);

    AppLogger.success('ANIMAIS DATASOURCE: CREATE LOT RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'CREATE LOT',
      expectedSuccessMessage: 'Lote cadastrado com sucesso',
    );
  }

  @override
  Future<ApiMessage> updateAnimalLot(AnimalLotUpsertEntity lot) async {
    if (lot.id == null) {
      throw ApiException('Informe o id do lote para atualizar.');
    }
    if (lot.appUsersId == null) {
      throw ApiException('Usuário não autenticado para atualizar lote.');
    }

    final payload = AnimalLotUpsertRequestModel.update(lot).data;
    AppLogger.info('ANIMAIS DATASOURCE: UPDATE LOT PAYLOAD=$payload');

    final response = await _apiClient.post(WSConstantes.animaisAdicionarLote, data: payload);

    AppLogger.success('ANIMAIS DATASOURCE: UPDATE LOT RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'UPDATE LOT',
      expectedSuccessMessage: 'Lote atualizado com sucesso',
    );
  }

  @override
  Future<AnimalLotsListEntity> getAnimalLots(AnimalLotsFilterEntity filter) async {
    final payload = AnimalLotsFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('ANIMAIS DATASOURCE: LIST LOTS PAYLOAD=$payload');

    final response = await _apiClient.post(WSConstantes.animaisListarLotes, data: payload);

    AppLogger.success('ANIMAIS DATASOURCE: LIST LOTS RAW RESPONSE=$response');
    return AnimalLotsListResponseModel.fromJson(responseAsMap(response));
  }

  @override
  Future<ApiMessage> deleteAnimalLot(DeleteAnimalLotEntity lot) async {
    final payload = DeleteAnimalLotRequestModel.fromEntity(lot).data;
    AppLogger.info('ANIMAIS DATASOURCE: DELETE LOT PAYLOAD=$payload');

    final response = await _apiClient.post(WSConstantes.animaisExcluirLote, data: payload);

    AppLogger.success('ANIMAIS DATASOURCE: DELETE LOT RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'DELETE LOT',
      expectedSuccessMessage: 'Lote excluído com sucesso',
    );
  }

  @override
  Future<AnimalChartsEntity> getAnimalCharts(AnimalChartsFilterEntity filter) async {
    final payload = AnimalChartsFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('ANIMAIS DATASOURCE: CHARTS PAYLOAD=$payload');

    final response = await _apiClient.post(WSConstantes.animaisGraficos, data: payload);

    AppLogger.success('ANIMAIS DATASOURCE: CHARTS RAW RESPONSE=$response');

    final wrapper = responseAsMap(response);
    final dataList = wrapper['data'] as List<dynamic>? ?? const [];
    final first = dataList.whereType<Map>().cast<Map>().firstOrNull;

    if (first == null) {
      AppLogger.warning('ANIMAIS DATASOURCE: CHARTS SEM DADOS, RETORNANDO VAZIO');
      return const AnimalChartsEntity(
        pesoTotalRebanho: 0,
        pesoMedioFazenda: 0,
        totalUa: 0,
        quantidadeAnimais: 0,
        porCategoria: [],
        porSexo: [],
        distribuicaoCategoria: [],
        proporcaoSexo: [],
      );
    }

    return AnimalChartsResponseModel.fromJson(Map<String, dynamic>.from(first));
  }

  ApiMessage _parseMutationResponse(
    dynamic response, {
    required String operationName,
    required String expectedSuccessMessage,
  }) {
    final map = responseAsMap(response);
    final hasMutationContract = map.containsKey('status') || map.containsKey('msg');

    if (!hasMutationContract) {
      AppLogger.error(
        'ANIMAIS DATASOURCE: $operationName RETORNOU CONTRATO INVALIDO RAW=$response',
      );
      throw ApiException(
        'Resposta inesperada da API ao executar $operationName. '
        'Esperado status/msg, recebido: $response',
      );
    }

    final message = ApiMessage.fromResponse(response);
    AppLogger.success(
      'ANIMAIS DATASOURCE: $operationName PARSED STATUS=${message.status} MSG=${message.message}',
    );

    if (!message.isSuccess) {
      throw ApiException(message.message);
    }

    if (message.message.trim().isEmpty) {
      return ApiMessage(status: message.status, message: expectedSuccessMessage);
    }

    return message;
  }
}
