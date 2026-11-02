import 'dart:convert';

import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/financeiro/infra/financeiro_api.dart';
import 'package:costeira/features/financeiro/presentation/web/financeiro_web_download_stub.dart'
    if (dart.library.html) 'package:costeira/features/financeiro/presentation/web/financeiro_web_download_web.dart'
    as web_download;
import 'package:flutter_modular/flutter_modular.dart';

/// Exportação CSV exclusiva da web (sem `dart:io`).
class FinanceiroWebExport {
  const FinanceiroWebExport(this._client);

  final ApiClient _client;

  Future<void> exportar(String qual, {FiltroFinanceiro? filtro}) async {
    final filtroFinal = filtro ?? FiltroFinanceiro.anoCorrente();
    final path = switch (qual) {
      'extrato' => WSConstantes.financeiroExportarExtrato,
      'fluxo' => WSConstantes.financeiroExportarFluxoCaixa,
      'dre' => WSConstantes.financeiroExportarDre,
      _ => throw ApiException('Exportação não disponível.'),
    };
    final body = await _base()
      ..addAll(filtroFinal.toPayload(comTipos: qual == 'extrato'))
      ..addAll({'limit': 100, 'pagina': 1});
    body.removeWhere((_, value) => value == null);
    final raw = await _client.post(path, data: body);
    final map = _primeiroMapa(raw) ?? const {};
    if (map['status']?.toString() != '01') {
      throw ApiException(map['msg']?.toString() ?? 'Falha ao exportar.');
    }
    final nome = map['nome_arquivo']?.toString() ?? '$qual.csv';
    final bytes = base64Decode(map['conteudo_base64']?.toString() ?? '');
    web_download.downloadBytes(bytes, nome);
  }

  Future<Map<String, dynamic>> _base() async {
    final user = await SessionStorage.getUserSession();
    if (user == null) {
      throw ApiException('Usuario nao autenticado.');
    }
    int? farmId;
    try {
      farmId = await Modular.get<ResolveCurrentFarmId>()(userId: user.id);
    } catch (_) {
      farmId = await SessionStorage.getSelectedFarmId();
    }
    farmId ??= await SessionStorage.getSelectedFarmId();
    if (farmId == null || farmId <= 0) {
      throw ApiException('Selecione uma fazenda.');
    }
    return withSubUser({
      'token': WSConstantes.token,
      'app_users_id': user.id,
      'app_fazendas_id': farmId,
    });
  }

  Map<String, dynamic>? _primeiroMapa(dynamic raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is List && raw.isNotEmpty && raw.first is Map) {
      return Map<String, dynamic>.from(raw.first as Map);
    }
    return null;
  }
}
