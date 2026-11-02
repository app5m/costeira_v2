import 'dart:convert';
import 'dart:io';

import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/financeiro/domain/apuracao_parceria.dart';
import 'package:costeira/features/financeiro/domain/chave_idempotencia.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';

class FinanceiroApi {
  FinanceiroApi(this._client);

  final ApiClient _client;

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

  Future<dynamic> _post(String path, [Map<String, dynamic> extra = const {}]) async {
    final body = await _base()..addAll(extra);
    body.removeWhere((key, value) => value == null);
    final raw = await _client.post(path, data: body);
    final map = _primeiroMapa(raw);
    final status = map?['status']?.toString();
    if (status == '02' || status == '03' || status == '04') {
      throw ApiException(map?['msg']?.toString() ?? 'Erro ao executar');
    }
    return raw;
  }

  Map<String, dynamic>? _primeiroMapa(dynamic raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is List && raw.isNotEmpty && raw.first is Map) {
      return Map<String, dynamic>.from(raw.first as Map);
    }
    return null;
  }

  List<Map<String, dynamic>> _lista(dynamic raw) {
    if (raw is Map && raw['dados'] is List) raw = raw['dados'];
    if (raw is List && raw.isNotEmpty && raw.first is Map) {
      final primeiro = Map<String, dynamic>.from(raw.first as Map);
      if (primeiro['status']?.toString() == '02') {
        throw ApiException(primeiro['msg']?.toString() ?? 'Erro ao executar');
      }
      if (primeiro.containsKey('rows') && primeiro['rows'] == 0) return const [];
      if (!primeiro.containsKey('id') && !primeiro.containsKey('dados') && !primeiro.containsKey('indicadores') && !primeiro.containsKey('lista') && !primeiro.containsKey('livro_caixa')) {
        return const [];
      }
      if (primeiro.containsKey('id') || primeiro.containsKey('codigo')) {
        return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
    }
    return const [];
  }

  Future<List<Map<String, dynamic>>> classificacoes() async {
    return _lista(await _post(WSConstantes.financeiroClassificacoes));
  }

  Future<List<Map<String, dynamic>>> rubricas() async {
    return _lista(await _post(WSConstantes.financeiroCategorias));
  }

  Future<List<Map<String, dynamic>>> centros() async {
    return _lista(await _post(WSConstantes.financeiroCentros));
  }

  Future<List<Map<String, dynamic>>> partes({String? papel}) async {
    return _lista(await _post(WSConstantes.financeiroPartes, {'papel': papel}));
  }

  Future<int> vincularParte({
    required String papel,
    int? fornecedorId,
    int? compradorId,
    String? nome,
    required String motivo,
    required String chave,
  }) async {
    final raw = await _post(WSConstantes.financeiroVincularParte, {
      'papel': papel,
      'app_fornecedores_id': fornecedorId,
      'app_compradores_id': compradorId,
      'nome': nome,
      'motivo': motivo,
      'chave_idempotencia': chave,
    });
    final id = int.tryParse(_primeiroMapa(raw)?['id']?.toString() ?? '');
    if (id == null || id <= 0) {
      throw ApiException('A API não devolveu o id da parte.');
    }
    return id;
  }

  Future<void> atualizarParte({
    required int id,
    required String nome,
    required String motivo,
    required String chave,
  }) async {
    await _post(WSConstantes.partesAtualizar, {
      'id': id,
      'nome': nome,
      'motivo': motivo,
      'chave_idempotencia': chave,
    });
  }

  Future<void> excluirParte({
    required int id,
    required String motivo,
    required String chave,
  }) async {
    await _post(WSConstantes.partesExcluir, {
      'id': id,
      'motivo': motivo,
      'chave_idempotencia': chave,
    });
  }

  Future<List<Map<String, dynamic>>> contas({int ativo = 1}) async {
    return _lista(await _post(WSConstantes.financeiroContas, {'ativo': ativo}));
  }

  Future<Map<String, dynamic>> lancamentos({
    int? classificacaoId,
    int? categoriaId,
    String? dataInicio,
    String? dataFim,
    String? estado,
    int limite = 50,
    int pagina = 1,
  }) async {
    final raw = await _post(WSConstantes.financeiroLancamentos, {
      'classificacao_id': classificacaoId,
      'categoria_id': categoriaId,
      'data_inicio': dataInicio,
      'data_fim': dataFim,
      'estado': estado,
      'limite': limite,
      'pagina': pagina,
    });
    return _primeiroMapa(raw) ?? const {};
  }

  Future<int> adicionarLancamento(Map<String, dynamic> campos, {required String chave, required String motivo}) async {
    final raw = await _post(WSConstantes.financeiroAdicionarLancamento, {
      ...campos,
      'motivo': motivo,
      'chave_idempotencia': chave,
    });
    final id = int.tryParse(
      _primeiroMapa(raw)?['id']?.toString() ?? _primeiroMapa(raw)?['lancamento_id']?.toString() ?? '',
    );
    if (id == null) throw ApiException('A API não devolveu o id do lançamento.');
    return id;
  }

  Future<void> confirmarLancamento(int id, {required String chave, required String motivo}) async {
    await _post(WSConstantes.financeiroConfirmarLancamento, {
      'id': id,
      'motivo': motivo,
      'chave_idempotencia': chave,
    });
  }

  Future<void> registrarBaixa({
    required int lancamentoId,
    required int contaId,
    required String data,
    required String valor,
    required String chave,
    required String motivo,
  }) async {
    await _post(WSConstantes.financeiroRegistrarBaixa, {
      'lancamento_id': lancamentoId,
      'conta_id': contaId,
      'data': data,
      'valor': valor,
      'motivo': motivo,
      'chave_idempotencia': chave,
    });
  }

  Future<void> estornarBaixa({required int baixaId, required String data, required String chave, required String motivo}) async {
    await _post(WSConstantes.financeiroEstornarBaixa, {
      'id': baixaId,
      'data': data,
      'motivo': motivo,
      'chave_idempotencia': chave,
    });
  }

  Future<void> estornarLancamento({required int id, required String data, required String chave, required String motivo}) async {
    await _post(WSConstantes.financeiroEstornarLancamento, {
      'id': id,
      'data': data,
      'motivo': motivo,
      'chave_idempotencia': chave,
    });
  }

  Future<int> adicionarConta({
    int? id,
    required String nome,
    required String tipo,
    required String motivo,
    required String chave,
  }) async {
    final raw = await _post(WSConstantes.financeiroAdicionarConta, {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'motivo': motivo,
      'chave_idempotencia': chave,
    });
    return int.tryParse(_primeiroMapa(raw)?['id']?.toString() ?? '') ?? id ?? 0;
  }

  Future<void> saldoInicial({
    required int contaId,
    required String data,
    required String direcao,
    required String valor,
    String? documento,
    required String motivo,
    required String chave,
  }) async {
    await _post(WSConstantes.financeiroRegistrarSaldoInicial, {
      'conta_id': contaId,
      'data': data,
      'direcao': direcao,
      'valor': valor,
      'documento': documento,
      'motivo': motivo,
      'chave_idempotencia': chave,
    });
  }

  Future<void> inativarConta({required int id, required String motivo, required String chave}) async {
    await _post(WSConstantes.financeiroInativarConta, {
      'id': id,
      'motivo': motivo,
      'chave_idempotencia': chave,
    });
  }

  Future<Map<String, dynamic>> extrato({
    FiltroFinanceiro filtro = const FiltroFinanceiro(),
    int limite = 200,
    int pagina = 1,
  }) async {
    final raw = await _post(WSConstantes.financeiroExtrato, {
      ...filtro.toPayload(),
      'limit': limite,
      'pagina': pagina,
    });
    return _primeiroMapa(raw) ?? const {};
  }

  Future<Map<String, dynamic>> fluxo({
    FiltroFinanceiro filtro = const FiltroFinanceiro(),
    int limite = 12,
    int pagina = 1,
  }) async {
    final raw = await _post(WSConstantes.financeiroFluxoCaixa, {
      ...filtro.toPayload(comTipos: false),
      'limit': limite,
      'pagina': pagina,
    });
    return _primeiroMapa(raw) ?? const {};
  }

  Future<Map<String, dynamic>> dre({
    FiltroFinanceiro filtro = const FiltroFinanceiro(),
    int limite = 20,
    int pagina = 1,
  }) async {
    final raw = await _post(WSConstantes.financeiroDre, {
      ...filtro.toPayload(comTipos: false),
      'limit': limite,
      'pagina': pagina,
    });
    return _primeiroMapa(raw) ?? const {};
  }

  Future<Map<String, dynamic>> resultados({
    FiltroFinanceiro filtro = const FiltroFinanceiro(),
    int limite = 50,
    int pagina = 1,
  }) async {
    final raw = await _post(WSConstantes.financeiroResultadosCategorias, {
      ...filtro.toPayload(comTipos: false),
      'limit': limite,
      'pagina': pagina,
    });
    return _primeiroMapa(raw) ?? const {};
  }

  Future<List<Map<String, dynamic>>> investidores({int ativo = 1}) async {
    return _lista(await _post(WSConstantes.financeiroPartes, {
      'papel': 'investidor',
      'ativo': ativo,
    }));
  }

  Future<List<Map<String, dynamic>>> parcerias({
    int? id,
    int? investidorId,
    int limite = 50,
    int pagina = 1,
  }) async {
    final raw = await _post(WSConstantes.financeiroParcerias, {
      'id': id,
      'investidor_id': investidorId,
      'limit': limite,
      'pagina': pagina,
    });
    final mapa = _primeiroMapa(raw);
    final lista = mapa?['lista'];
    if (lista is List) {
      return [
        for (final item in lista)
          if (item is Map && _registroLista(item)) Map<String, dynamic>.from(item),
      ];
    }
    return _lista(raw);
  }

  /// API devolve `[{rows:0,msg}]` em listas vazias (raiz ou `lista[]`).
  bool _registroLista(Map item) {
    final rows = item['rows'];
    if (rows == 0 || rows?.toString() == '0') return false;
    final id = item['id'];
    return id != null && id.toString().trim().isNotEmpty;
  }

  Future<int> adicionarParceria({
    required int investidorId,
    required String codigo,
    required String dataInicio,
    String? dataFim,
    required String percentualCusto,
    required String percentualGanho,
    required String motivo,
    required String chave,
  }) async {
    final raw = await _post(WSConstantes.financeiroAdicionarParceria, {
      'investidor_id': investidorId,
      'codigo': codigo,
      'data_inicio': dataInicio,
      'data_fim': dataFim,
      'percentual_custo_investidor': percentualCusto,
      'percentual_ganho_investidor': percentualGanho,
      'motivo': motivo,
      'chave_idempotencia': chave,
    });
    final id = int.tryParse(_primeiroMapa(raw)?['id']?.toString() ?? '');
    if (id == null || id <= 0) {
      throw ApiException('A API não devolveu o id do contrato.');
    }
    return id;
  }

  Future<void> inativarParceria({
    required int id,
    required String motivo,
    required String chave,
  }) async {
    await _post(WSConstantes.financeiroInativarParceria, {
      'id': id,
      'motivo': motivo,
      'chave_idempotencia': chave,
    });
  }

  Future<int> adicionarEntradaParceria({
    required int parceriaId,
    required String data,
    required List<Map<String, dynamic>> animais,
    required String motivo,
    required String chave,
  }) async {
    final raw = await _post(WSConstantes.financeiroAdicionarEntradaParceria, {
      'parceria_id': parceriaId,
      'data': data,
      'animais': animais,
      'motivo': motivo,
      'chave_idempotencia': chave,
    });
    final mapa = _primeiroMapa(raw);
    // Preferir entrada_id: em lote o campo id pode repetir/não ser a entrada.
    final id = int.tryParse(
      mapa?['entrada_id']?.toString() ?? mapa?['id']?.toString() ?? '',
    );
    if (id == null || id <= 0) {
      if (mapa?['status']?.toString() == '01') return parceriaId;
      throw ApiException('A API não devolveu o id da entrada.');
    }
    return id;
  }

  Future<({int vendaId, int? movimentacaoId, int? financeiroId})> adicionarVendaParceria({
    required int parceriaId,
    required int investidorId,
    required String data,
    required String valorUnitario,
    required int idComprador,
    required List<Map<String, dynamic>> animais,
    String valorFrete = '0.00',
    String valorComissao = '0.00',
    String? obs,
    required String motivo,
    required String chave,
  }) async {
    final raw = await _post(WSConstantes.movimentacoesAdicionarVenda, {
      'vincular_investidor': true,
      'parceria_id': parceriaId,
      'investidor_id': investidorId,
      'data': data,
      'tipo_compra': 'kg',
      'tipo_cadastro': 'individual',
      'valor_unitario': valorUnitario,
      'valor_frete': valorFrete,
      'valor_comissao': valorComissao,
      'id_comprador': idComprador,
      'obs': obs,
      'animais': animais,
      'motivo': motivo,
      'chave_idempotencia': chave,
    });
    final mapa = _primeiroMapa(raw) ?? const {};
    final vendaId = int.tryParse(mapa['venda_id']?.toString() ?? '');
    if (vendaId == null || vendaId <= 0) {
      throw ApiException('A API não devolveu o venda_id da parceria.');
    }
    return (
      vendaId: vendaId,
      movimentacaoId: int.tryParse(mapa['app_movimentacoes_id']?.toString() ?? ''),
      financeiroId: int.tryParse(mapa['id']?.toString() ?? ''),
    );
  }

  Future<Map<String, dynamic>> simularApuracaoParceria({
    required int vendaId,
    String? data,
  }) async {
    final raw = await _post(WSConstantes.financeiroSimularApuracaoParceria, {
      'venda_id': vendaId,
      'data': data,
    });
    return _mapaApuracao(raw);
  }

  Future<Map<String, dynamic>> confirmarApuracaoParceria({
    required int vendaId,
    required String data,
    required String hashSimulacao,
    required String motivo,
    required String chave,
  }) async {
    final raw = await _post(WSConstantes.financeiroConfirmarApuracaoParceria, {
      'venda_id': vendaId,
      'data': data,
      'hash_simulacao': hashSimulacao,
      'motivo': motivo,
      'chave_idempotencia': chave,
    });
    return _mapaApuracao(raw);
  }

  /// Flatten envelope comum da apuração (`dados`/`totais`/`resumo` / soma `itens`).
  Map<String, dynamic> _mapaApuracao(dynamic raw) {
    final raiz = _primeiroMapa(raw);
    if (raiz == null) return const {};
    return flattenApuracaoParceria(raiz);
  }

  Future<File> exportar(
    String path,
    String nomeFallback, {
    FiltroFinanceiro filtro = const FiltroFinanceiro(),
    bool comTipos = true,
  }) async {
    final raw = await _post(path, {
      ...filtro.toPayload(comTipos: comTipos),
      'limit': 100,
      'pagina': 1,
    });
    final map = _primeiroMapa(raw) ?? const {};
    if (map['status']?.toString() != '01') {
      throw ApiException(map['msg']?.toString() ?? 'Falha ao exportar.');
    }
    final nome = map['nome_arquivo']?.toString() ?? nomeFallback;
    final bytes = base64Decode(map['conteudo_base64']?.toString() ?? '');
    final arquivo = File('${Directory.systemTemp.path}/$nome');
    await arquivo.writeAsBytes(bytes);
    return arquivo;
  }

  String chave(String acao) => ChaveIdempotencia.nova(acao);
}

/// Filtros compartilhados entre listar e exportar CSV.
class FiltroFinanceiro {
  const FiltroFinanceiro({
    this.dataIn,
    this.dataOut,
    this.idAnoAgricola,
    this.tipos = const [],
    this.categorias = const [],
    this.origem,
  });

  final String? dataIn;
  final String? dataOut;
  final int? idAnoAgricola;
  final List<String> tipos;
  final List<int> categorias;
  final String? origem;

  static FiltroFinanceiro anoCorrente() {
    final ano = DateTime.now().year;
    return FiltroFinanceiro(
      dataIn: '01/01/$ano',
      dataOut: '31/12/$ano',
    );
  }

  Map<String, dynamic> toPayload({bool comTipos = true}) {
    final mapa = <String, dynamic>{
      if (idAnoAgricola != null) 'id_ano_agricola': idAnoAgricola,
      if (idAnoAgricola == null && dataIn != null && dataOut != null) ...{
        'data_in': dataIn,
        'data_out': dataOut,
      },
      if (comTipos) 'tipos': tipos,
      'categorias': categorias,
      'origem': origem,
    };
    return mapa;
  }
}
