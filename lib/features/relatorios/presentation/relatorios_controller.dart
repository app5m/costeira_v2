import 'dart:io';

import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_params_entity.dart';
import 'package:costeira/core/common/get_list/domain/usecases/get_list_usecase.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/dashboard/domain/entities/dashboard_filter_entity.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/relatorios/domain/relatorio_models.dart';
import 'package:costeira/features/relatorios/infra/data/relatorios_datasource.dart';
import 'package:flutter/foundation.dart';

enum TipoPeriodoRelatorio { anoAgricola, mesAtual, mesAnterior, personalizado }

class RelatoriosController extends ChangeNotifier {
  RelatoriosController({
    required RelatoriosDatasource datasource,
    required GetListUsecase getList,
    required ResolveCurrentFarmId fazenda,
  })  : _datasource = datasource,
        _getList = getList,
        _fazenda = fazenda;

  final RelatoriosDatasource _datasource;
  final GetListUsecase _getList;
  final ResolveCurrentFarmId _fazenda;

  bool carregando = false;
  bool exportando = false;
  String? erro;
  RelatoriosLista lista = RelatoriosLista.vazia;
  TipoPeriodoRelatorio periodo = TipoPeriodoRelatorio.anoAgricola;
  DateTime? dataDe;
  DateTime? dataAte;
  List<AgriculturalYearRange> anos = const [];
  AgriculturalYearRange? anoAtual;
  String? aberta;

  RelatorioBloco? get blocoAberto => aberta == null ? null : lista.bloco(aberta!);

  String get rotuloPeriodo {
    switch (periodo) {
      case TipoPeriodoRelatorio.anoAgricola:
        return anoAtual?.label ?? 'Ano agrícola';
      case TipoPeriodoRelatorio.mesAtual:
        return 'Mês atual';
      case TipoPeriodoRelatorio.mesAnterior:
        return 'Mês anterior';
      case TipoPeriodoRelatorio.personalizado:
        if (dataDe == null || dataAte == null) return 'Personalizado';
        return '${_dataBr(dataDe!)} a ${_dataBr(dataAte!)}';
    }
  }

  Future<void> preparar() async {
    final sessao = await SessionStorage.getUserSession();
    if (sessao == null || sessao.id <= 0) {
      erro = 'Usuário não autenticado.';
      notifyListeners();
      return;
    }
    final userId = sessionAccountUserId(sessao.id);
    try {
      final listas = await _getList(GetListParamsEntity(sexo: 1, userId: userId));
      anos = listas.anosAgricolas;
      anoAtual = _anoDeHoje(anos);
    } catch (_) {}
    notifyListeners();
    await carregar();
  }

  /// Sem `categorias` no payload → API devolve o que existir.
  Future<void> carregar({String? so}) async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      final ids = await _ids();
      final datas = _datas();
      lista = await _datasource.listar(
        appUsersId: ids.$1,
        appFazendasId: ids.$2,
        idAnoAgricola: datas.$1,
        dataIn: datas.$2,
        dataOut: datas.$3,
        // omitido / só a aberta → dinâmico conforme API
        categorias: so == null || so.isEmpty ? const [] : [so],
      );
      if (aberta != null && lista.bloco(aberta!) == null) {
        aberta = null;
      }
    } on ApiException catch (error) {
      erro = error.message;
    } catch (_) {
      erro = 'Não foi possível carregar os relatórios.';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<File> exportarPdf(String chave) async {
    exportando = true;
    erro = null;
    notifyListeners();
    try {
      final ids = await _ids();
      final datas = _datas();
      final exportacao = await _datasource.exportar(
        appUsersId: ids.$1,
        appFazendasId: ids.$2,
        idAnoAgricola: datas.$1,
        dataIn: datas.$2,
        dataOut: datas.$3,
        categorias: [chave],
      );
      if (exportacao.arquivos.isEmpty) {
        throw ApiException('Nenhum PDF gerado.');
      }
      return _datasource.baixarArquivo(exportacao.arquivos.first);
    } finally {
      exportando = false;
      notifyListeners();
    }
  }

  void abrir(String chave) {
    aberta = chave;
    notifyListeners();
    if (lista.bloco(chave) == null && !carregando) {
      carregar(so: chave);
    }
  }

  void fecharDetalhe() {
    aberta = null;
    notifyListeners();
  }

  void setPeriodo(TipoPeriodoRelatorio valor) {
    periodo = valor;
    final hoje = DateTime.now();
    switch (valor) {
      case TipoPeriodoRelatorio.mesAtual:
        dataDe = DateTime(hoje.year, hoje.month, 1);
        dataAte = hoje;
      case TipoPeriodoRelatorio.mesAnterior:
        final ant = DateTime(hoje.year, hoje.month - 1, 1);
        dataDe = ant;
        dataAte = DateTime(hoje.year, hoje.month, 0);
      case TipoPeriodoRelatorio.anoAgricola:
        dataDe = null;
        dataAte = null;
      case TipoPeriodoRelatorio.personalizado:
        dataDe ??= DateTime(hoje.year, hoje.month, 1);
        dataAte ??= hoje;
        notifyListeners();
        return;
    }
    notifyListeners();
    carregar(so: aberta);
  }

  void setDatas(DateTime? de, DateTime? ate) {
    dataDe = de;
    dataAte = ate;
    periodo = TipoPeriodoRelatorio.personalizado;
    notifyListeners();
  }

  Future<void> aplicarPeriodoPersonalizado() async {
    if (dataDe == null || dataAte == null) return;
    await carregar(so: aberta);
  }

  Future<(int, int)> _ids() async {
    final sessao = await SessionStorage.getUserSession();
    if (sessao == null || sessao.id <= 0) {
      throw ApiException('Usuário não autenticado.');
    }
    final userId = sessionAccountUserId(sessao.id);
    final fazendaId = await _fazenda(userId: userId);
    if (fazendaId == null || fazendaId <= 0) {
      throw ApiException('Selecione uma fazenda.');
    }
    return (userId, fazendaId);
  }

  (int?, String?, String?) _datas() {
    switch (periodo) {
      case TipoPeriodoRelatorio.anoAgricola:
        final ano = anoAtual;
        if (ano == null) return (null, null, null);
        return (ano.id, _dataBr(ano.dataIn), _dataBr(ano.dataOut));
      case TipoPeriodoRelatorio.mesAtual:
      case TipoPeriodoRelatorio.mesAnterior:
      case TipoPeriodoRelatorio.personalizado:
        if (dataDe == null || dataAte == null) return (null, null, null);
        return (null, _dataBr(dataDe!), _dataBr(dataAte!));
    }
  }

  AgriculturalYearRange? _anoDeHoje(List<AgriculturalYearRange> anos) {
    if (anos.isEmpty) return null;
    final hoje = DateTime.now();
    for (final ano in anos) {
      if (!hoje.isBefore(ano.dataIn) && !hoje.isAfter(ano.dataOut)) return ano;
    }
    return anos.last;
  }

  String _dataBr(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
