import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_filter_entity.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_list_entity.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_upsert_entity.dart';
import 'package:costeira/features/fazendas/domain/repository/fazendas_datasource.dart';
import 'package:costeira/features/fazendas/infra/models/fazenda_filter_request_model.dart';
import 'package:costeira/features/fazendas/infra/models/fazenda_list_response_model.dart';
import 'package:costeira/features/fazendas/infra/models/fazenda_upsert_request_model.dart';

class FazendasDatasourceImpl implements FazendasDatasource {
  const FazendasDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<FazendaListEntity> getFazendas(FazendaFilterEntity filter) async {
    final payload = FazendaFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('FAZENDAS DATASOURCE: LIST PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.fazendasListar,
      data: payload,
    );
    AppLogger.success('FAZENDAS DATASOURCE: LIST RAW RESPONSE=$response');

    return _parseList(response);
  }

  @override
  Future<ApiMessage> createFazenda(FazendaUpsertEntity fazenda) async {
    if (fazenda.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar fazenda.');
    }

    final payload = FazendaUpsertRequestModel.create(fazenda).data;
    AppLogger.info('FAZENDAS DATASOURCE: CREATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.fazendasAdicionar,
      data: payload,
    );
    AppLogger.success('FAZENDAS DATASOURCE: CREATE RAW RESPONSE=$response');

    return _parseMutation(
      response,
      fallbackMessage: 'Fazenda cadastrada com sucesso',
    );
  }

  @override
  Future<ApiMessage> updateFazenda(FazendaUpsertEntity fazenda) async {
    if (fazenda.id == null) {
      throw ApiException('Informe o id da fazenda para atualizar.');
    }
    if (fazenda.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar fazenda.');
    }

    final payload = FazendaUpsertRequestModel.update(fazenda).data;
    AppLogger.info('FAZENDAS DATASOURCE: UPDATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.fazendasAdicionar,
      data: payload,
    );
    AppLogger.success('FAZENDAS DATASOURCE: UPDATE RAW RESPONSE=$response');

    return _parseMutation(
      response,
      fallbackMessage: 'Fazenda atualizada com sucesso',
    );
  }

  FazendaListEntity _parseList(dynamic response) {
    final map = responseAsMap(response);

    if (map['data'] != null ||
        map['fazendas'] != null ||
        map['rows'] != null ||
        map['items'] != null) {
      return FazendaListResponseModel.fromJson(map);
    }

    final rootItems = _rootEntityList(response);
    if (rootItems != null) {
      return FazendaListResponseModel.fromList(rootItems);
    }

    if (_looksLikeStatusEnvelope(map)) {
      return const FazendaListResponseModel(rows: 0, data: []);
    }

    if (map['id'] != null || map['nome'] != null) {
      return FazendaListResponseModel.fromList([map]);
    }

    return const FazendaListResponseModel(rows: 0, data: []);
  }

  List<Map<String, dynamic>>? _rootEntityList(dynamic response) {
    final normalized = responseAsList(response);
    if (normalized.isEmpty) {
      return null;
    }

    final items = normalized
        .where((item) => !_looksLikeStatusEnvelope(item))
        .toList(growable: false);
    return items;
  }

  bool _looksLikeStatusEnvelope(Map<String, dynamic> map) {
    final hasStatusOrMsg = map.containsKey('status') || map.containsKey('msg');
    final hasEntity =
        map['id'] != null ||
        (map['nome']?.toString().trim().isNotEmpty ?? false);
    return hasStatusOrMsg && !hasEntity;
  }

  ApiMessage _parseMutation(
    dynamic response, {
    required String fallbackMessage,
  }) {
    final parsed = ApiMessage.fromResponse(response);
    if (!parsed.isSuccess) {
      throw ApiException(parsed.message);
    }
    return parsed.message.trim().isEmpty
        ? ApiMessage(status: parsed.status, message: fallbackMessage)
        : parsed;
  }
}
