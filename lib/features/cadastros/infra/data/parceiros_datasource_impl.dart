import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/cadastros/domain/entities/delete_parceiro_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_filter_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_list_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_upsert_entity.dart';
import 'package:costeira/features/cadastros/domain/repository/parceiros_datasource.dart';
import 'package:costeira/features/cadastros/infra/models/delete_parceiro_request_model.dart';
import 'package:costeira/features/cadastros/infra/models/parceiro_filter_request_model.dart';
import 'package:costeira/features/cadastros/infra/models/parceiro_list_response_model.dart';
import 'package:costeira/features/cadastros/infra/models/parceiro_upsert_request_model.dart';

class ParceirosDatasourceImpl implements ParceirosDatasource {
  const ParceirosDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ParceiroListEntity> getParceiros(ParceiroFilterEntity filter) async {
    final payload = ParceiroFilterRequestModel.fromEntity(filter).data;
    AppLogger.info(
      'CADASTROS DATASOURCE: LIST KIND=${filter.kind.name} PAYLOAD=$payload',
    );

    final response = await _apiClient.post(
      filter.kind.listPath,
      data: payload,
    );
    AppLogger.success('CADASTROS DATASOURCE: LIST RAW RESPONSE=$response');
    return _parseList(response);
  }

  @override
  Future<ApiMessage> createParceiro(ParceiroUpsertEntity parceiro) async {
    if (parceiro.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar.');
    }

    final payload = ParceiroUpsertRequestModel.create(parceiro).data;
    AppLogger.info(
      'CADASTROS DATASOURCE: CREATE KIND=${parceiro.kind.name} PAYLOAD=$payload',
    );

    final response = await _apiClient.post(
      parceiro.kind.savePath,
      data: payload,
    );
    AppLogger.success('CADASTROS DATASOURCE: CREATE RAW RESPONSE=$response');
    return _parseMutation(
      response,
      fallbackMessage: '${parceiro.kind.singular} cadastrado com sucesso',
    );
  }

  @override
  Future<ApiMessage> updateParceiro(ParceiroUpsertEntity parceiro) async {
    if (parceiro.id == null) {
      throw ApiException('Informe o id para atualizar.');
    }
    if (parceiro.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar.');
    }

    final payload = ParceiroUpsertRequestModel.update(parceiro).data;
    AppLogger.info(
      'CADASTROS DATASOURCE: UPDATE KIND=${parceiro.kind.name} PAYLOAD=$payload',
    );

    final response = await _apiClient.post(
      parceiro.kind.savePath,
      data: payload,
    );
    AppLogger.success('CADASTROS DATASOURCE: UPDATE RAW RESPONSE=$response');
    return _parseMutation(
      response,
      fallbackMessage: '${parceiro.kind.singular} atualizado com sucesso',
    );
  }

  @override
  Future<ApiMessage> deleteParceiro(DeleteParceiroEntity parceiro) async {
    final payload = DeleteParceiroRequestModel.fromEntity(parceiro).data;
    AppLogger.info(
      'CADASTROS DATASOURCE: DELETE KIND=${parceiro.kind.name} PAYLOAD=$payload',
    );

    final response = await _apiClient.post(
      parceiro.kind.deletePath,
      data: payload,
    );
    AppLogger.success('CADASTROS DATASOURCE: DELETE RAW RESPONSE=$response');
    return _parseMutation(
      response,
      fallbackMessage: '${parceiro.kind.singular} excluido com sucesso',
    );
  }

  ParceiroListEntity _parseList(dynamic response) {
    final map = responseAsMap(response);

    if (map['data'] != null ||
        map['fornecedores'] != null ||
        map['compradores'] != null ||
        map['rows'] != null ||
        map['items'] != null) {
      return ParceiroListResponseModel.fromJson(map);
    }

    final normalized = responseAsList(
      response,
    ).where((item) => !_looksLikeStatusEnvelope(item)).toList(growable: false);
    if (normalized.isNotEmpty) {
      return ParceiroListResponseModel.fromList(normalized);
    }

    return const ParceiroListResponseModel(rows: 0, data: []);
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
