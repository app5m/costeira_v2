import 'dart:io';

import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/relatorios/domain/relatorio_models.dart';
import 'package:dio/dio.dart';

class RelatoriosDatasource {
  RelatoriosDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<RelatoriosLista> listar({
    required int appUsersId,
    required int appFazendasId,
    int? idAnoAgricola,
    String? dataIn,
    String? dataOut,
    List<String> categorias = const [],
    int limit = 100,
    int pagina = 1,
  }) async {
    final corpo = _payload(
      appUsersId: appUsersId,
      appFazendasId: appFazendasId,
      idAnoAgricola: idAnoAgricola,
      dataIn: dataIn,
      dataOut: dataOut,
      categorias: categorias,
      limit: limit,
      pagina: pagina,
    );
    AppLogger.info('RELATORIOS LISTA PAYLOAD: $corpo');
    final response = await _apiClient.post(
      WSConstantes.relatoriosLista,
      data: corpo,
      timeout: const Duration(seconds: 60),
    );
    final mapa = _envelope(response);
    return RelatoriosLista.de(mapa);
  }

  Future<RelatoriosExportacao> exportar({
    required int appUsersId,
    required int appFazendasId,
    int? idAnoAgricola,
    String? dataIn,
    String? dataOut,
    required List<String> categorias,
  }) async {
    final corpo = _payload(
      appUsersId: appUsersId,
      appFazendasId: appFazendasId,
      idAnoAgricola: idAnoAgricola,
      dataIn: dataIn,
      dataOut: dataOut,
      categorias: categorias,
    );
    AppLogger.info('RELATORIOS EXPORTAR PAYLOAD: $corpo');
    final response = await _apiClient.post(
      WSConstantes.relatoriosExportar,
      data: corpo,
      timeout: const Duration(seconds: 90),
    );
    final mapa = _envelope(response, exigeArquivos: true);
    return RelatoriosExportacao.de(mapa);
  }

  Future<File> baixarArquivo(RelatorioArquivoPdf arquivo) async {
    final url = arquivo.url.trim();
    if (url.isEmpty) {
      throw ApiException('URL do PDF inválida.');
    }
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        responseType: ResponseType.bytes,
      ),
    );
    final response = await dio.get<List<int>>(url);
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw ApiException('PDF vazio ou indisponível.');
    }
    final nome = arquivo.nome.trim().isEmpty ? 'relatorio.pdf' : arquivo.nome.trim();
    final file = File('${Directory.systemTemp.path}/$nome');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Map<String, dynamic> _payload({
    required int appUsersId,
    required int appFazendasId,
    int? idAnoAgricola,
    String? dataIn,
    String? dataOut,
    List<String> categorias = const [],
    int? limit,
    int? pagina,
  }) {
    final periodo = <String, dynamic>{};
    if (idAnoAgricola != null && idAnoAgricola > 0) {
      periodo['id_ano_agricola'] = idAnoAgricola;
    }
    if (dataIn != null && dataIn.isNotEmpty) periodo['data_in'] = dataIn;
    if (dataOut != null && dataOut.isNotEmpty) periodo['data_out'] = dataOut;

    return withSubUser({
      'token': WSConstantes.token,
      'app_users_id': appUsersId,
      'app_fazendas_id': appFazendasId,
      if (periodo.isNotEmpty) 'periodo': periodo,
      if (categorias.isNotEmpty) 'categorias': categorias,
      if (limit != null) 'limit': limit,
      if (pagina != null) 'pagina': pagina,
    });
  }

  Map<String, dynamic> _envelope(dynamic response, {bool exigeArquivos = false}) {
    final mapa = responseAsMap(response);
    final status = mapa['status']?.toString();
    if (status != null && status != '01') {
      throw ApiException(
        mapa['msg']?.toString() ?? 'Não foi possível carregar os relatórios.',
      );
    }
    if (exigeArquivos) {
      if (mapa['arquivos'] is List) return mapa;
      final data = mapa['data'];
      if (data is Map && data['arquivos'] is List) {
        return Map<String, dynamic>.from(data);
      }
      throw ApiException(mapa['msg']?.toString() ?? 'Nenhum PDF retornado.');
    }
    if (mapa.containsKey('relatorios')) return mapa;
    final data = mapa['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    return mapa;
  }
}
