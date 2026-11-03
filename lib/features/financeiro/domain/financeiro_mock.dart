import 'dart:convert';
import 'dart:io';

import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_params_entity.dart';
import 'package:costeira/core/common/get_list/domain/usecases/get_list_usecase.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/dashboard/domain/entities/dashboard_filter_entity.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_entity.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_filter_entity.dart';
import 'package:costeira/features/fazendas/domain/usecases/get_fazendas_usecase.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/financeiro/domain/chave_idempotencia.dart';
import 'package:costeira/features/financeiro/infra/financeiro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

enum SituacaoLancamento { parcial, liquidado, pendente, rascunho }

class LancamentoMock {
  LancamentoMock({
    required this.id,
    required this.titulo,
    required this.subtitulo,
    required this.tipo,
    required this.categoria,
    required this.rubrica,
    required this.valor,
    required this.liquidado,
    required this.situacao,
    required this.dataCurta,
    required this.competencia,
    this.fornecedor,
    this.comprador,
    this.investidor,
    this.descricao = '',
    this.pagamentos = const [],
    this.alocacao = const [],
    this.historico = const [],
    this.classificacaoId,
    this.categoriaId,
    this.baixaIds = const [],
    this.estado = '',
    this.documento = '',
  });

  final int id;
  final String titulo;
  final String subtitulo;
  final String tipo;
  final String categoria;
  final String rubrica;
  final double valor;
  final double liquidado;
  final SituacaoLancamento situacao;
  final String dataCurta;
  final String competencia;
  final String? fornecedor;
  final String? comprador;
  final String? investidor;
  final String descricao;
  final List<PagamentoMock> pagamentos;
  final List<AlocacaoMock> alocacao;
  final List<String> historico;
  final int? classificacaoId;
  final int? categoriaId;
  final List<int> baixaIds;
  final String estado;
  final String documento;

  double get pendente => (valor - liquidado).clamp(0, valor);

  bool get entrada => tipo == 'recebimento';

  bool get ehAjusteConta {
    final doc = documento.trim().toUpperCase();
    return doc == 'AJUSTE-ENTRADA' || doc == 'AJUSTE-SAIDA';
  }

  bool get temLiquidacao => liquidado > 0.001 || pagamentos.isNotEmpty || baixaIds.isNotEmpty;
}

class PagamentoMock {
  const PagamentoMock(this.data, this.conta, this.valor, {this.id, this.criadoEm = ''});

  final int? id;
  final String data;
  final String conta;
  final double valor;
  final String criadoEm;
}

class AlocacaoMock {
  const AlocacaoMock(this.nome, this.valor, {this.percentual = 0});

  final String nome;
  final double valor;
  final double percentual;
}

class ContaMock {
  ContaMock({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.saldo,
    required this.ativa,
    this.motivo = '',
    this.saldoInicialRegistrado = true,
    this.movimentos = const [],
  });

  final int id;
  String nome;
  String tipo;
  double saldo;
  bool ativa;
  String motivo;
  bool saldoInicialRegistrado;
  final List<MovimentoContaMock> movimentos;
}

class MovimentoContaMock {
  const MovimentoContaMock(this.data, this.titulo, this.valor, this.selo);

  final String data;
  final String titulo;
  final double valor;
  final String selo;
}

class ClassificacaoFin {
  const ClassificacaoFin({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.exigeCentro,
    required this.manual,
    this.codigo = '',
  });

  final int id;
  final String nome;
  final String tipo;
  final bool exigeCentro;
  final bool manual;
  final String codigo;

  bool get ehCapex => codigo == 'capex' || id == 7;
}

class RubricaFin {
  const RubricaFin({required this.id, required this.classificacaoId, required this.nome});

  final int id;
  final int classificacaoId;
  final String nome;
}

class CentroFin {
  const CentroFin({required this.id, required this.nome});

  final int id;
  final String nome;
}

class ParteFin {
  const ParteFin({required this.id, required this.nome, required this.papel});

  final int id;
  final String nome;
  final String papel;
}

bool _registroFinanceiro(Map map) {
  final rows = map['rows'];
  if (rows == 0 || rows?.toString() == '0') return false;
  final id = map['id'] ??
      map['entrada_id'] ??
      map['app_animais_id'] ??
      map['lancamento_id'] ??
      map['venda_id'];
  return id != null && id.toString().trim().isNotEmpty;
}

/// Corrige acentos ausentes em nomes vindos da API (ex.: "nao" → "não").
String _nomeFinanceiroExibicao(String nome) {
  return nome.replaceAllMapped(RegExp(r'\b[Nn][Aa][Oo]\b'), (match) {
    final palavra = match[0]!;
    if (palavra == palavra.toUpperCase()) return 'NÃO';
    if (palavra.startsWith('N')) return 'Não';
    return 'não';
  });
}

/// Rubricas sistêmicas do fluxo de parceria (não entram como despesa operacional).
bool rubricaParceriaSistema(int categoriaId) =>
    categoriaId == 7 || categoriaId == 50 || categoriaId == 51 || categoriaId == 52;

bool rubricaParceriaReceber(int categoriaId) => categoriaId == 7 || categoriaId == 52;

class AnimalParceriaFin {
  const AnimalParceriaFin({
    required this.appAnimaisId,
    required this.brinco,
    required this.pesoEntradaKg,
    this.dataSaida,
    this.pesoSaidaKg,
  });

  final int? appAnimaisId;
  final String brinco;
  final String pesoEntradaKg;
  final String? dataSaida;
  final String? pesoSaidaKg;

  factory AnimalParceriaFin.de(Map<String, dynamic> map) {
    final animal = map['animal'];
    final animalMap = animal is Map ? Map<String, dynamic>.from(animal) : null;
    return AnimalParceriaFin(
      appAnimaisId: int.tryParse(
        map['app_animais_id']?.toString() ?? animalMap?['id']?.toString() ?? '',
      ),
      brinco: map['brinco']?.toString() ??
          animalMap?['brinco']?.toString() ??
          '',
      pesoEntradaKg: map['peso_entrada_kg']?.toString() ??
          map['peso_entrada_kg_string']?.toString() ??
          '',
      dataSaida: map['data_saida']?.toString(),
      pesoSaidaKg: map['peso_saida_kg']?.toString(),
    );
  }
}

class EntradaParceriaFin {
  const EntradaParceriaFin({
    required this.id,
    required this.data,
    required this.animais,
  });

  final int id;
  final String data;
  final List<AnimalParceriaFin> animais;

  factory EntradaParceriaFin.de(Map<String, dynamic> map) {
    final animaisRaw = map['animais'];
    return EntradaParceriaFin(
      id: int.tryParse(map['id']?.toString() ?? map['entrada_id']?.toString() ?? '') ?? 0,
      data: map['data']?.toString() ??
          map['data_entrada']?.toString() ??
          map['data_br']?.toString() ??
          '',
      animais: [
        if (animaisRaw is List)
          for (final item in animaisRaw)
            if (item is Map && _registroFinanceiro(item))
              AnimalParceriaFin.de(Map<String, dynamic>.from(item)),
      ],
    );
  }
}

List<Map<String, dynamic>> _listaRegistros(dynamic raw) {
  if (raw is Map) {
    if (!_registroFinanceiro(raw)) return const [];
    return [Map<String, dynamic>.from(raw)];
  }
  if (raw is! List) return const [];
  return [
    for (final item in raw)
      if (item is Map && _registroFinanceiro(item)) Map<String, dynamic>.from(item),
  ];
}

double _numMap(Map map, String key) =>
    double.tryParse(map[key]?.toString().replaceAll(',', '.') ?? '') ?? 0;

class TituloParceriaFin {
  const TituloParceriaFin({
    required this.id,
    required this.descricao,
    required this.categoriaId,
    required this.valor,
    required this.valorLiquidado,
    required this.saldoPendente,
    required this.estado,
    required this.dataCompetencia,
    this.categoriaNome,
    this.classificacaoNome,
    this.parteNome,
    this.valorString,
    this.saldoPendenteString,
    this.fluxo,
    this.qtdAnimais,
    this.contaPagamento,
  });

  final int id;
  final String descricao;
  final int categoriaId;
  final double valor;
  final double valorLiquidado;
  final double saldoPendente;
  final String estado;
  final String dataCompetencia;
  final String? categoriaNome;
  final String? classificacaoNome;
  final String? parteNome;
  final String? valorString;
  final String? saldoPendenteString;
  final String? fluxo;
  final int? qtdAnimais;
  final String? contaPagamento;

  bool get pendente => saldoPendente > 0.001;
  bool get pago => saldoPendente <= 0.001 && valorLiquidado > 0;
  bool get parcial => valorLiquidado > 0.001 && saldoPendente > 0.001;
  bool get eReceber =>
      rubricaParceriaReceber(categoriaId) || (fluxo?.toLowerCase() == 'entrada');
  bool get eDespesa => !rubricaParceriaSistema(categoriaId);

  String get statusRotulo => pago ? 'Liquidado' : (parcial ? 'Parcial' : 'Pendente');

  factory TituloParceriaFin.de(Map<String, dynamic> map) {
    final animaisRaw = map['animais'];
    int? qtd;
    if (animaisRaw is List) {
      qtd = animaisRaw.whereType<Map>().where(_registroFinanceiro).length;
    }
    qtd ??= int.tryParse(
      map['qtd_animais']?.toString() ?? map['quantidade_animais']?.toString() ?? '',
    );
    final baixasRaw = [
      for (final item in (map['baixas'] is List ? map['baixas'] as List : const []))
        if (item is Map) Map<String, dynamic>.from(item),
    ];
    final baixasEstornadas = {
      for (final item in baixasRaw)
        if (item['estorno_de_id'] != null) int.tryParse(item['estorno_de_id'].toString()) ?? 0,
    }.where((id) => id > 0).toSet();
    bool baixaAtiva(Map<String, dynamic> item) {
      final itemId = int.tryParse(item['id']?.toString() ?? '') ?? 0;
      return (item['natureza']?.toString() ?? '') != 'estorno' &&
          item['estorno_de_id'] == null &&
          !baixasEstornadas.contains(itemId);
    }
    final contas = <String>[
      for (final item in baixasRaw)
        if (baixaAtiva(item))
          if ((item['conta'] is Map ? item['conta']['nome']?.toString() : null)?.trim().isNotEmpty == true)
            (item['conta'] as Map)['nome'].toString().trim(),
    ];
    return TituloParceriaFin(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      descricao: map['descricao']?.toString() ??
          map['titulo']?.toString() ??
          map['nome']?.toString() ??
          map['categoria_nome']?.toString() ??
          '',
      categoriaId: int.tryParse(map['categoria_id']?.toString() ?? '') ?? 0,
      valor: _numMap(map, 'valor'),
      valorLiquidado: _numMap(map, 'valor_liquidado'),
      saldoPendente: _numMap(map, 'saldo_pendente'),
      estado: map['estado']?.toString() ?? '',
      dataCompetencia: map['data_competencia']?.toString() ??
          map['data']?.toString() ??
          map['data_br']?.toString() ??
          '',
      categoriaNome: map['categoria_nome']?.toString(),
      classificacaoNome: map['classificacao_nome']?.toString(),
      parteNome: map['parte_nome']?.toString() ?? map['fornecedor_nome']?.toString(),
      valorString: map['valor_string']?.toString(),
      saldoPendenteString: map['saldo_pendente_string']?.toString(),
      fluxo: map['fluxo']?.toString() ?? map['tipo']?.toString(),
      qtdAnimais: qtd,
      contaPagamento: contas.isEmpty ? null : contas.toSet().join(' · '),
    );
  }
}

class CustoParceriaFin {
  const CustoParceriaFin({
    required this.lancamentoId,
    required this.appAnimaisId,
    required this.valor,
    required this.descricao,
    required this.dataCompetencia,
    this.brinco,
  });

  final int lancamentoId;
  final int appAnimaisId;
  final double valor;
  final String descricao;
  final String dataCompetencia;
  final String? brinco;

  factory CustoParceriaFin.de(Map<String, dynamic> map) {
    return CustoParceriaFin(
      lancamentoId: int.tryParse(map['lancamento_id']?.toString() ?? '') ?? 0,
      appAnimaisId: int.tryParse(map['app_animais_id']?.toString() ?? '') ?? 0,
      valor: _numMap(map, 'valor'),
      descricao: map['descricao']?.toString() ?? '',
      dataCompetencia: map['data_competencia']?.toString() ?? '',
      brinco: map['brinco']?.toString(),
    );
  }
}

class VendaParceriaFin {
  const VendaParceriaFin({
    required this.id,
    required this.data,
    required this.precoKg,
    this.appMovimentacoesId,
    this.compradorNome,
    this.valorBruto,
    this.qtdAnimais,
    this.pesoTotal,
    this.acertoConfirmado = false,
    this.lancamentoVendaId,
  });

  final int id;
  final String data;
  final String precoKg;
  final int? appMovimentacoesId;
  final String? compradorNome;
  final double? valorBruto;
  final int? qtdAnimais;
  final double? pesoTotal;
  final bool acertoConfirmado;
  final int? lancamentoVendaId;

  factory VendaParceriaFin.de(Map<String, dynamic> map, {bool forcarAcerto = false}) {
    final acerto = map['apuracao_id'] ??
        map['id_apuracao'] ??
        map['acerto_confirmado'] ??
        map['apurada'] ??
        map['tem_apuracao'];
    return VendaParceriaFin(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      data: map['data']?.toString() ?? map['data_br']?.toString() ?? '',
      precoKg: map['preco_kg']?.toString() ??
          map['valor_unitario']?.toString() ??
          map['preco_kg_string']?.toString() ??
          '',
      appMovimentacoesId: int.tryParse(map['app_movimentacoes_id']?.toString() ?? ''),
      compradorNome: map['comprador_nome']?.toString() ?? map['nome_comprador']?.toString(),
      valorBruto: double.tryParse(
        map['valor_bruto']?.toString() ??
            map['valor_total']?.toString() ??
            map['receita_bruta']?.toString() ??
            '',
      ),
      qtdAnimais: int.tryParse(
        map['quantidade_animais']?.toString() ?? map['qtd_animais']?.toString() ?? '',
      ),
      pesoTotal: double.tryParse(map['peso_total']?.toString() ?? map['peso_saida_kg']?.toString() ?? ''),
      acertoConfirmado: forcarAcerto || _vendaTemAcerto(map, acerto),
      lancamentoVendaId: int.tryParse(map['lancamento_id']?.toString() ?? map['lancamento_venda_id']?.toString() ?? ''),
    );
  }

  VendaParceriaFin copiar({bool? acertoConfirmado}) {
    return VendaParceriaFin(
      id: id,
      data: data,
      precoKg: precoKg,
      appMovimentacoesId: appMovimentacoesId,
      compradorNome: compradorNome,
      valorBruto: valorBruto,
      qtdAnimais: qtdAnimais,
      pesoTotal: pesoTotal,
      acertoConfirmado: acertoConfirmado ?? this.acertoConfirmado,
      lancamentoVendaId: lancamentoVendaId,
    );
  }
}

bool _vendaTemAcerto(Map map, dynamic acerto) {
  if (acerto == true ||
      acerto?.toString() == '1' ||
      acerto?.toString().toLowerCase() == 'true' ||
      (int.tryParse(acerto?.toString() ?? '') ?? 0) > 0) {
    return true;
  }
  final estado = (map['estado_apuracao'] ?? map['estado_acerto'] ?? map['status_acerto'])
      ?.toString()
      .toLowerCase()
      .trim();
  if (estado == 'confirmado' || estado == 'apurado' || estado == 'acertada' || estado == 'acerto') {
    return true;
  }
  final nested = map['apuracao'] ?? map['apuracoes'];
  if (nested is Map) {
    if (!_registroFinanceiro(nested)) return false;
    final id = int.tryParse(nested['id']?.toString() ?? '') ?? 0;
    return id > 0;
  }
  if (nested is List) {
    for (final item in nested) {
      if (item is! Map || !_registroFinanceiro(item)) continue;
      final id = int.tryParse(item['id']?.toString() ?? '') ?? 0;
      if (id > 0) return true;
    }
  }
  return false;
}

class ParceriaFin {
  const ParceriaFin({
    required this.id,
    required this.codigo,
    required this.investidorId,
    required this.investidorNome,
    required this.dataInicio,
    this.dataFim,
    required this.percentualCusto,
    required this.percentualGanho,
    required this.ativo,
    required this.entradas,
    this.lancamentos = const [],
    this.vendas = const [],
    this.custos = const [],
  });

  final int id;
  final String codigo;
  final int investidorId;
  final String investidorNome;
  final String dataInicio;
  final String? dataFim;
  final String percentualCusto;
  final String percentualGanho;
  final bool ativo;
  final List<EntradaParceriaFin> entradas;
  final List<TituloParceriaFin> lancamentos;
  final List<VendaParceriaFin> vendas;
  final List<CustoParceriaFin> custos;

  /// `data_fim` já passou (hoje > fim). Independente de [ativo] (inativação API).
  bool get periodoVencido {
    final fim = parseDataParceria(dataFim);
    if (fim == null) return false;
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    return fim.isBefore(hoje);
  }

  int get qtdAnimais => entradas.fold(0, (s, e) => s + e.animais.length);

  List<AnimalParceriaFin> get animaisAtivos {
    final saida = <AnimalParceriaFin>[];
    final vistos = <int>{};
    for (final entrada in entradas) {
      for (final animal in entrada.animais) {
        final id = animal.appAnimaisId;
        if (id == null) continue;
        if (animal.dataSaida != null && animal.dataSaida!.trim().isNotEmpty) continue;
        if (!vistos.add(id)) continue;
        saida.add(animal);
      }
    }
    return saida;
  }

  List<TituloParceriaFin> get despesas => [for (final l in lancamentos) if (l.eDespesa) l];

  List<TituloParceriaFin> get titulosSistema => [
        for (final l in lancamentos)
          if (rubricaParceriaSistema(l.categoriaId)) l,
      ];

  double get totalDespesas => despesas.fold(0.0, (s, l) => s + l.valor);

  double get saldoAPagarDespesas => despesas.fold(0.0, (s, l) => s + l.saldoPendente);

  double get aReceber => lancamentos.where((l) => l.eReceber).fold(0.0, (s, l) => s + l.saldoPendente);

  double get aPagar => lancamentos
      .where((l) => !l.eReceber && l.pendente)
      .fold(0.0, (s, l) => s + l.saldoPendente);

  int qtdAnimaisDoLancamento(int lancamentoId) {
    final ids = {
      for (final c in custos)
        if (c.lancamentoId == lancamentoId && c.appAnimaisId > 0) c.appAnimaisId,
    };
    return ids.length;
  }

  Set<int> get idsAnimais {
    return {
      for (final entrada in entradas)
        for (final animal in entrada.animais)
          if (animal.appAnimaisId != null) animal.appAnimaisId!,
    };
  }

  ParceriaFin comVendaAcertada(int vendaId) {
    return ParceriaFin(
      id: id,
      codigo: codigo,
      investidorId: investidorId,
      investidorNome: investidorNome,
      dataInicio: dataInicio,
      dataFim: dataFim,
      percentualCusto: percentualCusto,
      percentualGanho: percentualGanho,
      ativo: ativo,
      entradas: entradas,
      lancamentos: lancamentos,
      vendas: [
        for (final v in vendas)
          if (v.id == vendaId && !v.acertoConfirmado) v.copiar(acertoConfirmado: true) else v,
      ],
      custos: custos,
    );
  }

  /// Coleta IDs de `animais[]` / `entradas[].animais[]` (ignora sentinel rows:0).
  static Set<int> idsAnimaisDoMapa(Map<String, dynamic> map) {
    final ids = <int>{};
    void coletar(dynamic raw) {
      if (raw is! List) return;
      for (final item in raw) {
        if (item is! Map) continue;
        if (!_registroFinanceiro(item)) continue;
        final id = int.tryParse(
          item['app_animais_id']?.toString() ?? item['id']?.toString() ?? '',
        );
        if (id != null && id > 0) ids.add(id);
        final animal = item['animal'];
        if (animal is Map) {
          final nested = int.tryParse(animal['id']?.toString() ?? '');
          if (nested != null && nested > 0) ids.add(nested);
        }
        coletar(item['animais']);
      }
    }

    coletar(map['animais']);
    coletar(map['entradas']);
    return ids;
  }

  factory ParceriaFin.de(Map<String, dynamic> map) {
    final investidor = map['investidor'];
    final investidorMap = investidor is Map ? Map<String, dynamic>.from(investidor) : null;
    final estado = (map['estado'] ?? map['status'] ?? map['ativo'] ?? 'ativo').toString();
    return ParceriaFin(
      id: int.tryParse(map['id'].toString()) ?? 0,
      codigo: map['codigo']?.toString() ?? '',
      investidorId: int.tryParse(
            map['investidor_id']?.toString() ?? investidorMap?['id']?.toString() ?? '',
          ) ??
          0,
      investidorNome: map['investidor_nome']?.toString() ??
          investidorMap?['nome']?.toString() ??
          '',
      dataInicio: map['data_inicio']?.toString() ?? map['data_inicio_br']?.toString() ?? '',
      dataFim: map['data_fim']?.toString() ?? map['data_fim_br']?.toString(),
      percentualCusto: map['percentual_custo_investidor']?.toString() ?? '0',
      percentualGanho: map['percentual_ganho_investidor']?.toString() ?? '0',
      ativo: estado == '1' || estado.toLowerCase() == 'ativo' || estado.toLowerCase() == 'true',
      entradas: [
        for (final item in _listaRegistros(map['entradas'])) EntradaParceriaFin.de(item),
      ],
      lancamentos: [
        for (final item in _listaRegistros(map['lancamentos'])) TituloParceriaFin.de(item),
      ],
      vendas: _vendasComAcerto(
        vendas: [for (final item in _listaRegistros(map['vendas'])) VendaParceriaFin.de(item)],
        apuracoes: _listaRegistros(map['apuracoes']),
      ),
      custos: [
        for (final item in _listaRegistros(map['custos'])) CustoParceriaFin.de(item),
      ],
    );
  }
}

DateTime? parseDataParceria(String? valor) {
  final texto = (valor ?? '').trim();
  if (texto.isEmpty) return null;
  final br = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(texto);
  if (br != null) {
    final dia = int.tryParse(br.group(1)!);
    final mes = int.tryParse(br.group(2)!);
    final ano = int.tryParse(br.group(3)!);
    if (dia == null || mes == null || ano == null) return null;
    final data = DateTime(ano, mes, dia);
    if (data.year != ano || data.month != mes || data.day != dia) return null;
    return data;
  }
  final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(texto);
  if (iso == null) return null;
  final ano = int.tryParse(iso.group(1)!);
  final mes = int.tryParse(iso.group(2)!);
  final dia = int.tryParse(iso.group(3)!);
  if (dia == null || mes == null || ano == null) return null;
  final data = DateTime(ano, mes, dia);
  if (data.year != ano || data.month != mes || data.day != dia) return null;
  return data;
}

List<VendaParceriaFin> _vendasComAcerto({
  required List<VendaParceriaFin> vendas,
  required List<Map<String, dynamic>> apuracoes,
}) {
  if (vendas.isEmpty || apuracoes.isEmpty) return vendas;
  final idsConfirmados = <int>{};
  for (final a in apuracoes) {
    final estado = (a['estado'] ?? a['status'])?.toString().toLowerCase().trim();
    // Só conta apuração confirmada (ignora rascunho/cancelada se existir).
    if (estado != null &&
        estado.isNotEmpty &&
        estado != 'confirmado' &&
        estado != 'apurado' &&
        estado != '1' &&
        estado != 'true') {
      continue;
    }
    final vendaId = _vendaIdDaApuracao(a);
    if (vendaId > 0) idsConfirmados.add(vendaId);
  }
  if (idsConfirmados.isEmpty) return vendas;
  return [
    for (final v in vendas)
      if (idsConfirmados.contains(v.id) && !v.acertoConfirmado)
        v.copiar(acertoConfirmado: true)
      else
        v,
  ];
}

/// API manda `venda_id` na raiz **ou** dentro de `parametros_snapshot` (JSON string).
int _vendaIdDaApuracao(Map<String, dynamic> a) {
  final direto = int.tryParse(
        a['venda_id']?.toString() ??
            a['parceria_venda_id']?.toString() ??
            a['fn_parcerias_vendas_id']?.toString() ??
            '',
      ) ??
      0;
  if (direto > 0) return direto;

  final venda = a['venda'];
  if (venda is Map) {
    final nested = int.tryParse(venda['id']?.toString() ?? '') ?? 0;
    if (nested > 0) return nested;
  }

  final snap = a['parametros_snapshot'];
  if (snap is Map) {
    return int.tryParse(snap['venda_id']?.toString() ?? '') ?? 0;
  }
  if (snap is String && snap.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(snap);
      if (decoded is Map) {
        return int.tryParse(decoded['venda_id']?.toString() ?? '') ?? 0;
      }
    } catch (_) {}
  }
  return 0;
}

class FinanceiroLoja extends ChangeNotifier {
  FinanceiroLoja({FinanceiroApi? api}) : _api = api ?? FinanceiroApi(ApiClient.instance) {
    carregar();
  }

  final FinanceiroApi _api;

  List<LancamentoMock> lancamentos = const [];
  List<ContaMock> contas = const [];
  List<ClassificacaoFin> classificacoes = const [];
  List<RubricaFin> rubricas = const [];
  List<CentroFin> centros = const [];
  List<ParteFin> partes = const [];
  List<ParteFin> investidores = const [];
  List<ParceriaFin> parcerias = const [];
  ParceriaFin? parceriaDetalhe;
  List<FazendaEntity> fazendas = const [];
  List<AgriculturalYearRange> anosAgricolas = const [];
  AgriculturalYearRange? anoAgricola;
  int? fazendaId;
  Map<String, dynamic> fluxo = const {};
  Map<String, dynamic> extrato = const {};
  Map<String, dynamic> dre = const {};
  Map<String, dynamic> resultados = const {};
  bool carregando = true;
  bool carregandoContexto = true;
  bool carregandoInvestidores = false;
  bool carregandoParcerias = false;
  String? erro;
  String? erroParcerias;

  String get fazendaNome {
    if (carregandoContexto && fazendas.isEmpty) return 'Carregando…';
    if (fazendas.isEmpty) return 'Nenhuma fazenda';
    final atual = fazendas.where((f) => f.id == fazendaId);
    final farm = atual.isNotEmpty ? atual.first : fazendas.first;
    final nome = farm.nome.trim().isNotEmpty ? farm.nome.trim() : farm.nomeFantasia.trim();
    return nome.isEmpty ? 'Fazenda ${farm.id}' : nome;
  }

  String get anoAgricolaLabel => anoAgricola?.label ?? 'Ano agrícola';

  FiltroFinanceiro get filtroPeriodo {
    final ano = anoAgricola;
    if (ano == null) return FiltroFinanceiro.anoCorrente();
    if (ano.id != null && ano.id! > 0) {
      return FiltroFinanceiro(idAnoAgricola: ano.id);
    }
    return FiltroFinanceiro(
      dataIn: _dataBr(ano.dataIn),
      dataOut: _dataBr(ano.dataOut),
    );
  }

  String get saldoTexto => fluxo['indicadores']?['saldo_disponivel_string']?.toString() ?? r'R$ 0,00';
  String get entradasTexto => fluxo['indicadores']?['total_entradas_string']?.toString() ?? r'R$ 0,00';
  String get saidasTexto => fluxo['indicadores']?['total_saidas_string']?.toString() ?? r'R$ 0,00';

  List<double> get barrasFluxo => _serieFluxo('entradas');

  List<double> get barrasSaidasFluxo => _serieFluxo('saidas');

  List<String> get rotulosFluxo {
    final grafico = fluxo['grafico'];
    if (grafico is! Map) return const [];
    final mapa = Map<String, dynamic>.from(grafico);
    final bruto =
        mapa['categorias'] ??
        mapa['labels'] ??
        mapa['rotulos'] ??
        mapa['meses'];
    if (bruto is List && bruto.isNotEmpty) {
      return [for (final item in bruto) item.toString()];
    }
    final n = barrasFluxo.length;
    if (n == 0) return const [];
    const meses = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    final inicio = anoAgricola?.dataIn.month ?? 7;
    return [
      for (var i = 0; i < n; i++) meses[(inicio - 1 + i) % 12],
    ];
  }

  List<double> _serieFluxo(String chave) {
    final series = (fluxo['grafico']?['series'] as List?) ?? const [];
    final alvo = series
        .cast<Map?>()
        .whereType<Map>()
        .where((s) => s['chave']?.toString() == chave);
    if (alvo.isEmpty) return const [];
    final dados = (alvo.first['dados'] as List?) ?? const [];
    return [
      for (final item in dados) double.tryParse(item.toString()) ?? 0,
    ];
  }

  double get saldoDisponivel =>
      contas.where((c) => c.ativa).fold(0, (s, c) => s + c.saldo);

  double get aPagar => lancamentos
      .where((l) => !l.entrada && l.estado != 'estornado' && l.estado != 'cancelado' && l.situacao != SituacaoLancamento.rascunho)
      .fold(0, (s, l) => s + l.pendente);

  double get aReceber => lancamentos
      .where((l) => l.entrada && l.estado != 'estornado' && l.estado != 'cancelado' && l.situacao != SituacaoLancamento.liquidado)
      .fold(0, (s, l) => s + l.pendente);

  Future<void> carregar() async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      await _carregarContexto();
      final filtro = filtroPeriodo;
      final pacote = await Future.wait([
        _api.classificacoes(),
        _api.rubricas(),
        _api.centros(),
        _api.partes(),
        _api.contas(),
        _api.contas(ativo: 0),
        _api.lancamentos(),
        _api.extrato(filtro: filtro, limite: 200),
        _api.fluxo(filtro: filtro),
        _api.dre(filtro: filtro),
        _api.resultados(filtro: filtro),
      ]);
      classificacoes = [
        for (final item in pacote[0] as List<Map<String, dynamic>>)
          ClassificacaoFin(
            id: int.tryParse(item['id'].toString()) ?? 0,
            nome: _nomeFinanceiroExibicao(item['nome']?.toString() ?? ''),
            tipo: item['tipo']?.toString() ?? '',
            exigeCentro: item['exige_centro'].toString() == '1',
            manual: item['manual_etapa2'].toString() == '1',
            codigo: item['codigo']?.toString() ?? '',
          ),
      ];
      rubricas = [
        for (final item in pacote[1] as List<Map<String, dynamic>>)
          RubricaFin(
            id: int.tryParse(item['id'].toString()) ?? 0,
            classificacaoId: int.tryParse(item['classificacao_id'].toString()) ?? 0,
            nome: _nomeFinanceiroExibicao(item['nome']?.toString() ?? ''),
          ),
      ];
      centros = [
        for (final item in pacote[2] as List<Map<String, dynamic>>)
          CentroFin(id: int.tryParse(item['id'].toString()) ?? 0, nome: item['nome']?.toString() ?? ''),
      ];
      partes = [
        for (final item in pacote[3] as List<Map<String, dynamic>>)
          ParteFin(
            id: int.tryParse(item['id'].toString()) ?? 0,
            nome: item['nome']?.toString() ?? '',
            papel: item['papel']?.toString() ?? '',
          ),
      ];
      extrato = pacote[7] as Map<String, dynamic>;
      fluxo = pacote[8] as Map<String, dynamic>;
      dre = pacote[9] as Map<String, dynamic>;
      resultados = pacote[10] as Map<String, dynamic>;
      final linhas = _linhasExtrato(extrato);
      final vistas = <int>{};
      contas = [
        for (final item in [...pacote[4] as List<Map<String, dynamic>>, ...pacote[5] as List<Map<String, dynamic>>])
          if (vistas.add(int.tryParse(item['id'].toString()) ?? 0)) _contaDe(item, linhas),
      ];
      final dados = (pacote[6] as Map)['dados'];
      lancamentos = [
        for (final item in (dados is List ? dados : const []))
          if (item is Map) _lancamentoDe(Map<String, dynamic>.from(item), linhas),
      ];
    } on ApiException catch (error) {
      erro = error.message;
    } catch (error) {
      erro = error.toString();
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<void> salvarLancamento({
    required bool rascunho,
    int? id,
    required int classificacaoId,
    required int categoriaId,
    int? centroId,
    int? parteId,
    required String competencia,
    String? vencimento,
    required String descricao,
    String? documento,
    required String valor,
    String? quantidade,
    String? unidade,
    List<Map<String, dynamic>> rateios = const [],
    List<Map<String, dynamic>>? bens,
    List<Map<String, dynamic>>? animais,
    bool pago = false,
    int? contaId,
    String? dataBaixa,
  }) async {
    final lote = ChaveIdempotencia.loteSalvar();
    final chaveCriar = id == null ? lote.criar : ChaveIdempotencia.montar(lote.uuid, 'editar');
    final novoId = await _api.adicionarLancamento(
      {
        'id': id,
        'classificacao_id': classificacaoId,
        'categoria_id': categoriaId,
        'centro_id': centroId,
        'parte_id': parteId,
        'data_competencia': competencia,
        'data_vencimento': vencimento,
        'descricao': descricao,
        'documento': documento,
        'valor': valor,
        'quantidade': quantidade,
        'unidade': unidade,
        'rateios': rateios,
        if (bens != null) 'bens': bens,
        'animais': animais,
      },
      chave: chaveCriar,
      motivo: descricao,
    );
    if (rascunho) {
      await carregar();
      return;
    }
    await _api.confirmarLancamento(novoId, chave: lote.confirmar, motivo: descricao);
    if (pago && contaId != null) {
      await _api.registrarBaixa(
        lancamentoId: novoId,
        contaId: contaId,
        data: dataBaixa ?? competencia,
        valor: valor,
        chave: lote.baixa,
        motivo: descricao,
      );
    }
    await carregar();
  }

  Future<void> registrarBaixa(int id, {required double valor, required String conta, String? data}) async {
    ContaMock? alvo;
    for (final item in contas) {
      if (item.nome == conta) alvo = item;
    }
    if (alvo == null) throw ApiException('Selecione a conta.');
    LancamentoMock? item;
    for (final atual in lancamentos) {
      if (atual.id == id) item = atual;
    }
    await _api.registrarBaixa(
      lancamentoId: id,
      contaId: alvo.id,
      data: data ?? item?.competencia ?? _hoje(),
      valor: valor.toStringAsFixed(2),
      chave: ChaveIdempotencia.nova('baixa'),
      motivo: 'Baixa do lançamento $id',
    );
    await carregar();
  }

  Future<void> estornarPagamento(
    int id, {
    required String data,
    required String motivo,
    int? baixaId,
  }) async {
    LancamentoMock? item;
    for (final atual in lancamentos) {
      if (atual.id == id) item = atual;
    }
    final idBaixa = baixaId ??
        (item?.baixaIds.isNotEmpty == true ? item!.baixaIds.last : null);
    if (idBaixa == null) throw ApiException('Nenhuma baixa encontrada para estornar.');
    final textoMotivo = motivo.trim().isEmpty ? 'Estorno da baixa' : motivo.trim();
    await _api.estornarBaixa(
      baixaId: idBaixa,
      data: _dataApiIso(data),
      chave: ChaveIdempotencia.nova('estornar-baixa'),
      motivo: textoMotivo,
    );
    await carregar();
  }

  Future<void> estornar(
    int id, {
    required String data,
    required String motivo,
  }) async {
    LancamentoMock? item;
    for (final atual in lancamentos) {
      if (atual.id == id) item = atual;
    }
    final textoMotivo = motivo.trim().isEmpty ? 'Estorno do lançamento' : motivo.trim();
    final dataIso = _dataApiIso(data);

    // Ajuste de saldo = lançamento + baixa. API exige baixa estornada antes;
    // se UI não listou pagamento, ainda assim limpa baixaIds e tenta.
    if (item != null && (item.ehAjusteConta || item.temLiquidacao)) {
      for (final baixaId in item.baixaIds) {
        await _api.estornarBaixa(
          baixaId: baixaId,
          data: dataIso,
          chave: ChaveIdempotencia.nova('estornar-baixa'),
          motivo: textoMotivo,
        );
      }
    }

    try {
      await _api.estornarLancamento(
        id: id,
        data: dataIso,
        chave: ChaveIdempotencia.nova('estornar'),
        motivo: textoMotivo,
      );
    } on ApiException catch (error) {
      final msg = error.message.toLowerCase();
      if (msg.contains('manual original') || msg.contains('lançamento manual')) {
        throw ApiException(
          item?.ehAjusteConta == true
              ? 'Ajuste de saldo ainda tem baixa ativa. Estorne o pagamento primeiro (ou atualize a tela).'
              : 'Estorne o pagamento/baixa antes de estornar o lançamento.',
        );
      }
      rethrow;
    }
    await carregar();
  }

  Future<int> vincularParte({
    required String papel,
    int? fornecedorId,
    int? compradorId,
    String? nome,
    required String motivo,
  }) async {
    final id = await _api.vincularParte(
      papel: papel,
      fornecedorId: fornecedorId,
      compradorId: compradorId,
      nome: nome,
      motivo: motivo,
      chave: ChaveIdempotencia.nova('parte'),
    );
    await carregar();
    if (papel == 'investidor') await carregarInvestidores();
    return id;
  }

  Future<void> carregarInvestidores() async {
    carregandoInvestidores = true;
    notifyListeners();
    try {
      final lista = await _api.investidores();
      investidores = [
        for (final item in lista)
          ParteFin(
            id: int.tryParse(item['id'].toString()) ?? 0,
            nome: item['nome']?.toString() ?? '',
            papel: item['papel']?.toString() ?? 'investidor',
          ),
      ]..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    } finally {
      carregandoInvestidores = false;
      notifyListeners();
    }
  }

  Future<void> carregarParcerias({required int investidorId}) async {
    carregandoParcerias = true;
    notifyListeners();
    erroParcerias = null;
    notifyListeners();
    try {
      final lista = await _api.parcerias(investidorId: investidorId);
      parcerias = [for (final item in lista) ParceriaFin.de(item)];
      erroParcerias = null;
    } on ApiException catch (error) {
      erroParcerias = error.message;
      parcerias = const [];
    } catch (_) {
      erroParcerias = 'Não foi possível carregar os contratos.';
      parcerias = const [];
    } finally {
      carregandoParcerias = false;
      notifyListeners();
    }
  }

  Future<ParceriaFin?> carregarParceria(int id) async {
    carregandoParcerias = true;
    erroParcerias = null;
    notifyListeners();
    try {
      final lista = await _api.parcerias(id: id);
      parceriaDetalhe = lista.isEmpty ? null : ParceriaFin.de(lista.first);
      return parceriaDetalhe;
    } on ApiException catch (error) {
      erroParcerias = error.message;
      return null;
    } catch (_) {
      erroParcerias = 'Não foi possível carregar o contrato.';
      return null;
    } finally {
      carregandoParcerias = false;
      notifyListeners();
    }
  }

  /// Marca venda como acertada no cache local (lista/detalhe).
  void marcarVendaAcertada({required int parceriaId, required int vendaId}) {
    if (parceriaDetalhe?.id == parceriaId) {
      parceriaDetalhe = parceriaDetalhe!.comVendaAcertada(vendaId);
    }
    parcerias = [
      for (final p in parcerias)
        if (p.id == parceriaId) p.comVendaAcertada(vendaId) else p,
    ];
    notifyListeners();
  }

  /// Animais já em qualquer contrato (não podem entrar de novo).
  /// Lista sem detalhe às vezes omite `animais`/`entradas` — busca id a id se vazio.
  Future<Set<int>> idsAnimaisVinculadosParceria() async {
    final lista = await _api.parcerias(limite: 100);
    final ids = <int>{};
    for (final item in lista) {
      final doMapa = ParceriaFin.idsAnimaisDoMapa(item);
      if (doMapa.isNotEmpty) {
        ids.addAll(doMapa);
        continue;
      }
      final id = int.tryParse(item['id']?.toString() ?? '') ?? 0;
      if (id <= 0) continue;
      final detalhe = await _api.parcerias(id: id);
      if (detalhe.isNotEmpty) {
        ids.addAll(ParceriaFin.idsAnimaisDoMapa(detalhe.first));
      }
    }
    return ids;
  }

  Future<int> adicionarInvestidor({required String nome, String? motivo}) async {
    final texto = nome.trim();
    if (texto.isEmpty) throw ApiException('Informe o nome do investidor.');
    return vincularParte(
      papel: 'investidor',
      nome: texto,
      motivo: (motivo ?? '').trim().isEmpty ? 'Cadastro de investidor' : motivo!.trim(),
    );
  }

  Future<void> atualizarInvestidor({
    required int id,
    required String nome,
    String? motivo,
  }) async {
    final texto = nome.trim();
    if (texto.isEmpty) throw ApiException('Informe o nome do investidor.');
    await _api.atualizarParte(
      id: id,
      nome: texto,
      motivo: (motivo ?? '').trim().isEmpty ? 'Correção do nome' : motivo!.trim(),
      chave: ChaveIdempotencia.nova('editar'),
    );
    await carregarInvestidores();
  }

  Future<void> excluirInvestidor({required int id, String? motivo}) async {
    await _api.excluirParte(
      id: id,
      motivo: (motivo ?? '').trim().isEmpty ? 'Parte não será mais utilizada' : motivo!.trim(),
      chave: ChaveIdempotencia.nova('excluir'),
    );
    await carregarInvestidores();
    if (parceriaDetalhe?.investidorId == id) parceriaDetalhe = null;
    parcerias = const [];
  }

  Future<void> inativarParceria({required int id, String? motivo}) async {
    await _api.inativarParceria(
      id: id,
      motivo: (motivo ?? '').trim().isEmpty ? 'Encerramento do contrato' : motivo!.trim(),
      chave: ChaveIdempotencia.nova('inativar'),
    );
    final investidorId = parceriaDetalhe?.investidorId ??
        parcerias.where((e) => e.id == id).firstOrNull?.investidorId;
    await carregarParceria(id);
    if (investidorId != null) {
      await carregarParcerias(investidorId: investidorId);
    }
  }

  Future<int> adicionarContrato({
    required int investidorId,
    required String codigo,
    required String dataInicio,
    String? dataFim,
    required String percentualCusto,
    required String percentualGanho,
    String? motivo,
  }) async {
    final codigoLimpo = codigo.trim();
    if (codigoLimpo.isEmpty) throw ApiException('Informe o código do contrato.');
    final inicio = _parseDataBr(dataInicio);
    if (inicio == null) throw ApiException('Data de início inválida.');
    DateTime? fim;
    if (dataFim != null && dataFim.trim().isNotEmpty) {
      fim = _parseDataBr(dataFim);
      if (fim == null) throw ApiException('Data fim inválida.');
      if (fim.isBefore(inicio)) throw ApiException('Fim anterior ao início.');
    }
    final custo = double.tryParse(percentualCusto.trim().replaceAll(',', '.'));
    final ganho = double.tryParse(percentualGanho.trim().replaceAll(',', '.'));
    if (custo == null || ganho == null) {
      throw ApiException('Percentuais inválidos.');
    }
    if (custo < 0 || custo > 100 || ganho < 0 || ganho > 100) {
      throw ApiException('Percentuais devem ficar entre 0 e 100.');
    }
    final id = await _api.adicionarParceria(
      investidorId: investidorId,
      codigo: codigoLimpo,
      dataInicio: _dataApiIso(dataInicio),
      dataFim: fim == null ? null : _dataApiIso(dataFim!),
      percentualCusto: _percentual6(percentualCusto),
      percentualGanho: _percentual6(percentualGanho),
      motivo: (motivo ?? '').trim().isEmpty ? 'Cadastro de contrato' : motivo!.trim(),
      chave: ChaveIdempotencia.nova('parceria'),
    );
    await carregarParcerias(investidorId: investidorId);
    return id;
  }

  DateTime? _parseDataBr(String valor) {
    final texto = valor.trim();
    final br = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(texto);
    if (br != null) {
      final dia = int.tryParse(br.group(1)!);
      final mes = int.tryParse(br.group(2)!);
      final ano = int.tryParse(br.group(3)!);
      if (dia == null || mes == null || ano == null) return null;
      final data = DateTime(ano, mes, dia);
      if (data.year != ano || data.month != mes || data.day != dia) return null;
      return data;
    }
    final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(texto);
    if (iso == null) return null;
    final ano = int.tryParse(iso.group(1)!);
    final mes = int.tryParse(iso.group(2)!);
    final dia = int.tryParse(iso.group(3)!);
    if (dia == null || mes == null || ano == null) return null;
    final data = DateTime(ano, mes, dia);
    if (data.year != ano || data.month != mes || data.day != dia) return null;
    return data;
  }

  Future<int> adicionarEntradaParceria({
    required int parceriaId,
    required String data,
    required List<Map<String, dynamic>> animais,
    String? motivo,
  }) async {
    if (animais.isEmpty) throw ApiException('Selecione ao menos 1 animal.');
    if (animais.length > 100) throw ApiException('No máximo 100 animais por entrada.');
    final id = await _api.adicionarEntradaParceria(
      parceriaId: parceriaId,
      data: data.trim(),
      animais: animais,
      motivo: (motivo ?? '').trim().isEmpty ? 'Entrada de animais na parceria' : motivo!.trim(),
      chave: ChaveIdempotencia.nova('entrada'),
    );
    await carregarParceria(parceriaId);
    return id;
  }

  static const centroParceria = 5;

  Future<int> adicionarDespesaParceria({
    required int parceriaId,
    required int classificacaoId,
    required int categoriaId,
    int? parteId,
    required String competencia,
    String? vencimento,
    required String descricao,
    String? documento,
    required String valor,
    required List<Map<String, dynamic>> animais,
    bool pago = false,
    int? contaId,
    String? dataBaixa,
    String? motivo,
  }) async {
    if (animais.isEmpty) throw ApiException('Selecione ao menos 1 animal do contrato.');
    final texto = descricao.trim().isEmpty ? 'Despesa da parceria' : descricao.trim();
    final lote = ChaveIdempotencia.loteSalvar();
    final id = await _api.adicionarLancamento(
      {
        'classificacao_id': classificacaoId,
        'categoria_id': categoriaId,
        'centro_id': centroParceria,
        'parte_id': parteId,
        'data_competencia': competencia,
        'data_vencimento': vencimento,
        'descricao': texto,
        'documento': documento,
        'valor': valor,
        'rateios': const <Map<String, dynamic>>[],
        'bens': const <Map<String, dynamic>>[],
        'animais': animais,
      },
      chave: lote.criar,
      motivo: (motivo ?? '').trim().isEmpty ? texto : motivo!.trim(),
    );
    await _api.confirmarLancamento(id, chave: lote.confirmar, motivo: texto);
    if (pago && contaId != null) {
      await _api.registrarBaixa(
        lancamentoId: id,
        contaId: contaId,
        data: dataBaixa ?? competencia,
        valor: valor,
        chave: lote.baixa,
        motivo: texto,
      );
    }
    await carregarParceria(parceriaId);
    await carregar();
    return id;
  }

  Future<int> adicionarVendaParceria({
    required int parceriaId,
    required int investidorId,
    required String data,
    required String valorUnitario,
    required int idComprador,
    required List<Map<String, dynamic>> animais,
    String valorFrete = '0.00',
    String valorComissao = '0.00',
    String? obs,
    String? motivo,
  }) async {
    if (animais.isEmpty) throw ApiException('Selecione ao menos 1 animal.');
    final texto = (motivo ?? '').trim().isEmpty ? 'Venda de parceria' : motivo!.trim();
    final resultado = await _api.adicionarVendaParceria(
      parceriaId: parceriaId,
      investidorId: investidorId,
      data: data.trim(),
      valorUnitario: valorUnitario,
      idComprador: idComprador,
      animais: animais,
      valorFrete: valorFrete,
      valorComissao: valorComissao,
      obs: obs,
      motivo: texto,
      chave: ChaveIdempotencia.nova('venda'),
    );
    await carregarParceria(parceriaId);
    await carregar();
    return resultado.vendaId;
  }

  Future<Map<String, dynamic>> simularApuracaoParceria({
    required int vendaId,
    String? data,
  }) {
    return _api.simularApuracaoParceria(vendaId: vendaId, data: data);
  }

  Future<Map<String, dynamic>> confirmarApuracaoParceria({
    required int parceriaId,
    required int vendaId,
    required String data,
    required String hashSimulacao,
    String? motivo,
  }) async {
    final mapa = await _api.confirmarApuracaoParceria(
      vendaId: vendaId,
      data: data.trim(),
      hashSimulacao: hashSimulacao,
      motivo: (motivo ?? '').trim().isEmpty ? 'Confirmação de acerto da parceria' : motivo!.trim(),
      chave: ChaveIdempotencia.nova('apuracao'),
    );
    await carregarParceria(parceriaId);
    await carregar();
    return mapa;
  }

  Future<void> registrarBaixaTituloParceria({
    required int parceriaId,
    required int lancamentoId,
    required int contaId,
    required String data,
    required String valor,
    String? motivo,
  }) async {
    await _api.registrarBaixa(
      lancamentoId: lancamentoId,
      contaId: contaId,
      data: data,
      valor: valor,
      chave: ChaveIdempotencia.nova('baixa'),
      motivo: (motivo ?? '').trim().isEmpty ? 'Baixa do título $lancamentoId' : motivo!.trim(),
    );
    await carregarParceria(parceriaId);
    await carregar();
  }

  String _percentual6(String valor) {
    final n = double.tryParse(valor.trim().replaceAll(',', '.'));
    if (n == null) throw ApiException('Percentual inválido.');
    return n.toStringAsFixed(6);
  }

  Future<void> _carregarContexto() async {
    carregandoContexto = true;
    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        fazendas = const [];
        fazendaId = null;
        return;
      }
      final userId = sessionAccountUserId(user.id);
      final saved = await SessionStorage.getSelectedFarmId();
      try {
        final farms = await Modular.get<GetFazendasUsecase>()(
          FazendaFilterEntity(appUsersId: userId),
        );
        final match = farms.data.where((f) => f.id == saved);
        final selected = match.isNotEmpty
            ? match.first.id
            : (farms.data.isEmpty ? null : farms.data.first.id);
        if (selected != null) {
          await SessionStorage.saveSelectedFarmId(selected);
        }
        fazendas = farms.data;
        fazendaId = selected;
      } catch (_) {
        // /fazendas/listar 500: mantém farm da sessão pra financeiro continuar.
        fazendaId = saved;
        fazendas = saved != null && saved > 0
            ? [FazendaEntity.stub(id: saved)]
            : const [];
      }

      try {
        final listas = await Modular.get<GetListUsecase>()(
          GetListParamsEntity(sexo: 1, userId: userId),
        );
        final anos = listas.anosAgricolas;
        if (anos.isNotEmpty) {
          anosAgricolas = anos;
          final atual = anoAgricola;
          if (atual == null || !anos.any((a) => a.label == atual.label)) {
            anoAgricola = AgriculturalYearRange.containingIn(anos, DateTime.now()) ?? anos.first;
          }
        } else if (anoAgricola == null) {
          anosAgricolas = AgriculturalYearRange.options(DateTime.now());
          anoAgricola = AgriculturalYearRange.containing(DateTime.now());
        }
      } catch (_) {
        if (anoAgricola == null) {
          anosAgricolas = AgriculturalYearRange.options(DateTime.now());
          anoAgricola = AgriculturalYearRange.containing(DateTime.now());
        }
      }
    } finally {
      carregandoContexto = false;
    }
  }

  Future<void> selecionarFazenda(int id) async {
    if (id == fazendaId) return;
    await SessionStorage.saveSelectedFarmId(id);
    await Modular.get<ResolveCurrentFarmId>()(preferred: id);
    notifyListeners();
    await carregar();
  }

  Future<void> selecionarAnoAgricola(AgriculturalYearRange ano) async {
    if (ano.label == anoAgricola?.label && ano.id == anoAgricola?.id) return;
    anoAgricola = ano;
    notifyListeners();
    await carregar();
  }

  Future<int> salvarConta({
    int? id,
    required String nome,
    required String tipo,
    required String motivo,
  }) async {
    final novoId = await _api.adicionarConta(
      id: id,
      nome: nome,
      tipo: tipo.toLowerCase() == 'caixa' ? 'caixa' : 'banco',
      motivo: motivo,
      chave: ChaveIdempotencia.nova(id == null ? 'conta' : 'editar'),
    );
    await carregar();
    return novoId;
  }

  Future<Map<String, dynamic>> carregarRelatorio(String qual, FiltroFinanceiro filtro) async {
    return switch (qual) {
      'extrato' => _api.extrato(filtro: filtro, limite: 200),
      'fluxo' => _api.fluxo(filtro: filtro, limite: 12),
      'dre' => _api.dre(filtro: filtro, limite: 20),
      'resultado' => _api.resultados(filtro: filtro, limite: 50),
      _ => throw ApiException('Relatório não disponível.'),
    };
  }

  Future<void> registrarSaldoInicial({
    required int contaId,
    required String data,
    required bool positivo,
    required String valor,
    String? documento,
    required String motivo,
  }) async {
    await _api.saldoInicial(
      contaId: contaId,
      data: data,
      direcao: positivo ? 'entrada' : 'saida',
      valor: valor,
      documento: documento,
      motivo: motivo,
      chave: ChaveIdempotencia.nova('saldo'),
    );
    await carregar();
  }

  /// Ajuste pós-abertura: cria lançamento confirmado + baixa na conta.
  /// (`registrarSaldoInicial` só vale na 1ª abertura — API rejeita conta com movimento.)
  Future<void> registrarAjusteConta({
    required int contaId,
    required String data,
    required bool entrada,
    required String valor,
    String? documento,
    required String motivo,
  }) async {
    final tipo = entrada ? 'recebimento' : 'pagamento';
    final classifs = [
      for (final c in classificacoes)
        if (c.tipo == tipo && c.manual) c,
    ];
    if (classifs.isEmpty) {
      throw ApiException('Sem classificação disponível para ajuste de saldo.');
    }
    final escolhida = entrada
        ? (classifs.where((c) {
              final n = c.nome.toLowerCase();
              return n.contains('não operacional') || n.contains('nao operacional');
            }).firstOrNull ??
            classifs.first)
        : (classifs.where((c) {
              final n = c.nome.toLowerCase();
              return n.contains('financeiro') || n.contains('fixo');
            }).firstOrNull ??
            classifs.first);
    final rubs = [for (final r in rubricas) if (r.classificacaoId == escolhida.id) r];
    if (rubs.isEmpty) {
      throw ApiException('Sem rubrica disponível para ajuste de saldo.');
    }
    final rubrica = rubs.where((r) {
          final n = r.nome.toLowerCase();
          return n.contains('outras') || n.contains('ajuste') || n.contains('financeira');
        }).firstOrNull ??
        rubs.first;
    // API: centro_id OU rateios (nunca os dois). Centro único basta.
    if (centros.isEmpty) {
      throw ApiException('Cadastre um centro de custo antes do ajuste.');
    }
    final centro = centros.where((c) {
          final n = c.nome.toLowerCase();
          return n == 'geral' || n.contains('geral');
        }).firstOrNull ??
        centros.first;
    final doc = (documento ?? '').trim().isEmpty
        ? (entrada ? 'AJUSTE-ENTRADA' : 'AJUSTE-SAIDA')
        : documento!.trim();
    final desc = motivo.trim().isEmpty
        ? (entrada ? 'Adicionar saldo na conta' : 'Remover saldo da conta')
        : motivo.trim();
    await salvarLancamento(
      rascunho: false,
      classificacaoId: escolhida.id,
      categoriaId: rubrica.id,
      centroId: centro.id,
      competencia: data,
      vencimento: data,
      descricao: desc,
      documento: doc,
      valor: valor,
      pago: true,
      contaId: contaId,
      dataBaixa: data,
    );
  }

  Future<void> inativar(int id, String motivo) async {
    await _api.inativarConta(id: id, motivo: motivo, chave: ChaveIdempotencia.nova('inativar'));
    await carregar();
  }

  Future<File> exportarCsv(String qual, {FiltroFinanceiro? filtro}) async {
    final filtroFinal = filtro ?? FiltroFinanceiro.anoCorrente();
    final path = switch (qual) {
      'extrato' => WSConstantes.financeiroExportarExtrato,
      'fluxo' => WSConstantes.financeiroExportarFluxoCaixa,
      'dre' => WSConstantes.financeiroExportarDre,
      _ => throw ApiException('Exportação não disponível.'),
    };
    return _api.exportar(
      path,
      '$qual.csv',
      filtro: filtroFinal,
      comTipos: qual == 'extrato',
    );
  }

  ContaMock _contaDe(Map<String, dynamic> json, List<Map<String, dynamic>> linhas) {
    final id = int.tryParse(json['id'].toString()) ?? 0;
    final movimentos = [
      for (final linha in linhas)
        if (int.tryParse(linha['conta_id']?.toString() ?? '') == id)
          MovimentoContaMock(
            linha['data']?.toString() ?? '',
            linha['descricao']?.toString() ?? '',
            double.tryParse(linha['valor_assinado']?.toString() ?? '') ?? 0,
            linha['natureza']?.toString() == 'saldo_inicial' ? 'Abertura' : '',
          ),
    ];
    final saldo = movimentos.fold<double>(0, (s, m) => s + m.valor);
    final tipo = json['tipo']?.toString() == 'caixa' ? 'Caixa' : 'Banco';
    return ContaMock(
      id: id,
      nome: json['nome']?.toString() ?? '',
      tipo: tipo,
      saldo: saldo,
      ativa: json['ativo'].toString() != '0',
      saldoInicialRegistrado: movimentos.any((m) => m.selo == 'Abertura'),
      movimentos: movimentos,
    );
  }

  LancamentoMock _lancamentoDe(Map<String, dynamic> json, List<Map<String, dynamic>> linhas) {
    final id = int.tryParse(json['id'].toString()) ?? 0;
    final valor = double.tryParse(json['valor']?.toString() ?? '') ?? 0;
    final saldoPendenteApi = double.tryParse(json['saldo_pendente']?.toString() ?? '');
    final liquidadoApi = double.tryParse(json['valor_liquidado']?.toString() ?? '') ?? 0;
    final liquidado = saldoPendenteApi != null
        ? (valor - saldoPendenteApi).clamp(0.0, valor)
        : liquidadoApi;
    final estado = json['estado']?.toString() ?? '';
    final tipo = (json['tipo']?.toString() ?? '').toLowerCase();
    final competencia = _dataTela(json['data_competencia']?.toString() ?? '');
    final classificacao = json['classificacao_nome']?.toString() ?? '';
    final rubrica = json['categoria_nome']?.toString() ?? '';
    final descricao = json['descricao']?.toString() ?? '';
    final criadoEm = json['criado_em']?.toString() ?? '';

    final centrosNome = <int, String>{
      for (final item in (json['centros'] is List ? json['centros'] as List : const []))
        if (item is Map)
          (int.tryParse(item['id']?.toString() ?? '') ?? 0): (item['nome']?.toString() ?? ''),
    };

    final alocacao = <AlocacaoMock>[
      for (final item in (json['rateios'] is List ? json['rateios'] as List : const []))
        if (item is Map && item['id'] != null)
          AlocacaoMock(
            centrosNome[int.tryParse(item['centro_id']?.toString() ?? '') ?? 0] ??
                'Centro ${item['centro_id'] ?? ''}',
            double.tryParse(item['valor']?.toString() ?? '') ?? 0,
            percentual: double.tryParse(item['percentual']?.toString() ?? '') ?? 0,
          ),
    ];

    final partes = [
      for (final item in (json['partes'] is List ? json['partes'] as List : const []))
        if (item is Map && item['id'] != null) Map<String, dynamic>.from(item),
    ];
    String? fornecedor;
    String? comprador;
    String? investidor;
    for (final parte in partes) {
      final papel = (parte['papel']?.toString() ?? '').toLowerCase();
      final nome = parte['nome']?.toString() ?? '';
      if (nome.isEmpty) continue;
      if (papel.contains('comprador')) {
        comprador = nome;
      } else if (papel.contains('investidor')) {
        investidor = nome;
      } else {
        fornecedor = nome;
      }
    }

    final documento = json['documento']?.toString() ?? '';
    final baixasRaw = [
      for (final item in (json['baixas'] is List ? json['baixas'] as List : const []))
        if (item is Map && item['id'] != null) Map<String, dynamic>.from(item),
    ];
    final linhasDoLancamento = [
      for (final linha in linhas)
        if (int.tryParse(linha['lancamento_id']?.toString() ?? '') == id) linha,
    ];
    // Só confia em baixas do próprio lançamento — extrato já poluiu estorno_de_id
    // e escondia pagamentos → UI liberava estorno do lançamento liquidado.
    final baixasEstornadas = {
      for (final item in baixasRaw)
        if ((item['natureza']?.toString() ?? '') == 'estorno')
          int.tryParse(item['estorno_de_id']?.toString() ?? '') ?? 0,
    }.where((item) => item > 0).toSet();
    bool ehEstornoBaixa(Map<String, dynamic> item) {
      final natureza = (item['natureza']?.toString() ?? '').toLowerCase();
      final estornoDe = item['estorno_de_id'];
      final temEstornoDe = estornoDe != null && '$estornoDe'.trim().isNotEmpty && '$estornoDe' != '0';
      return natureza == 'estorno' || temEstornoDe;
    }
    bool baixaAtiva(Map<String, dynamic> item) {
      final itemId = int.tryParse(item['id']?.toString() ?? '') ?? 0;
      if (itemId <= 0) return false;
      if (ehEstornoBaixa(item)) return false;
      if (baixasEstornadas.contains(itemId)) return false;
      return true;
    }

    final pagamentosApi = <PagamentoMock>[
      for (final item in baixasRaw)
        if (baixaAtiva(item))
          PagamentoMock(
            _dataTela(item['data']?.toString() ?? ''),
            (item['conta'] is Map ? item['conta']['nome']?.toString() : null) ?? 'Conta',
            double.tryParse(item['valor']?.toString() ?? '') ?? 0,
            id: int.tryParse(item['id']?.toString() ?? ''),
            criadoEm: item['criado_em']?.toString() ?? '',
          ),
    ];
    final baixaIdsApi = [
      for (final pag in pagamentosApi)
        if (pag.id != null) pag.id!,
    ];
    final baixaIdsExtrato = [
      for (final linha in linhasDoLancamento)
        if (baixaAtiva(linha)) int.tryParse(linha['id']?.toString() ?? '') ?? 0,
    ].where((item) => item > 0).toList();
    final baixaIds = baixaIdsApi.isNotEmpty ? baixaIdsApi : baixaIdsExtrato;

    final estornosHistorico = <String>[
      for (final item in baixasRaw)
        if (ehEstornoBaixa(item))
          'Baixa estornada · ${_dataTela(item['criado_em']?.toString() ?? item['data']?.toString() ?? '')}',
    ];

    final historico = <String>[
      if (estado == 'confirmado' || estado == 'liquidado' || estado == 'parcial')
        'Lançamento confirmado · ${_dataTela(criadoEm.isEmpty ? competencia : criadoEm)}',
      if (estado == 'rascunho') 'Rascunho criado · ${_dataTela(criadoEm.isEmpty ? competencia : criadoEm)}',
      for (final item in baixasRaw)
        if (baixaAtiva(item))
          'Pagamento registrado · ${_dataTela(item['data']?.toString() ?? '')}'
              '${(double.tryParse(item['valor']?.toString() ?? '') ?? 0) > 0 ? ' · R\$ ${(double.tryParse(item['valor']?.toString() ?? '') ?? 0).toStringAsFixed(2).replaceAll('.', ',')}' : ''}',
      ...estornosHistorico.toSet(),
      if (estado == 'estornado') 'Lançamento estornado',
    ];

    return LancamentoMock(
      id: id,
      titulo: descricao.trim().isNotEmpty ? descricao : (rubrica.isNotEmpty ? rubrica : 'Lançamento'),
      subtitulo: '$competencia · $classificacao',
      tipo: tipo,
      categoria: classificacao,
      rubrica: rubrica,
      valor: valor,
      liquidado: liquidado,
      situacao: _situacao(estado, valor, liquidado),
      dataCurta: competencia,
      competencia: competencia,
      fornecedor: fornecedor,
      comprador: comprador,
      investidor: investidor,
      descricao: descricao,
      pagamentos: pagamentosApi,
      alocacao: alocacao,
      historico: historico,
      classificacaoId: int.tryParse(json['classificacao_id']?.toString() ?? ''),
      categoriaId: int.tryParse(json['categoria_id']?.toString() ?? ''),
      baixaIds: baixaIds,
      estado: estado,
      documento: documento,
    );
  }

  SituacaoLancamento _situacao(String estado, double valor, double liquidado) {
    if (estado == 'rascunho') return SituacaoLancamento.rascunho;
    if (estado == 'estornado' || estado == 'cancelado') return SituacaoLancamento.pendente;
    if (liquidado <= 0) return SituacaoLancamento.pendente;
    if (liquidado + 0.001 >= valor) return SituacaoLancamento.liquidado;
    return SituacaoLancamento.parcial;
  }

  List<Map<String, dynamic>> _linhasExtrato(Map<String, dynamic> mapa) {
    final lista = mapa['lista'];
    if (lista is! List) return const [];
    return [
      for (final item in lista)
        if (item is Map && item['id'] != null) Map<String, dynamic>.from(item),
    ];
  }

  String _dataTela(String valor) {
    final texto = valor.trim();
    final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(texto);
    if (iso != null) return '${iso.group(3)}/${iso.group(2)}/${iso.group(1)}';
    final brTraco = RegExp(r'^(\d{2})-(\d{2})-(\d{4})').firstMatch(texto);
    if (brTraco != null) return '${brTraco.group(1)}/${brTraco.group(2)}/${brTraco.group(3)}';
    final comHora = RegExp(r'^(\d{2})/(\d{2})/(\d{4})').firstMatch(texto);
    if (comHora != null) {
      final hora = RegExp(r'\d{2}:\d{2}').firstMatch(texto);
      if (hora != null) return '${comHora.group(0)} ${hora.group(0)}';
      return comHora.group(0)!;
    }
    return texto;
  }

  String _hoje() {
    final agora = DateTime.now();
    final d = agora.day.toString().padLeft(2, '0');
    final m = agora.month.toString().padLeft(2, '0');
    return '$d/$m/${agora.year}';
  }

  /// Estornos pedem `YYYY-MM-DD`. Tela usa `dd/MM/yyyy`.
  String _dataApiIso(String valor) {
    final texto = valor.trim();
    final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(texto);
    if (iso != null) return texto;
    final brBarra = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(texto);
    if (brBarra != null) return '${brBarra.group(3)}-${brBarra.group(2)}-${brBarra.group(1)}';
    final brTraco = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$').firstMatch(texto);
    if (brTraco != null) return '${brTraco.group(3)}-${brTraco.group(2)}-${brTraco.group(1)}';
    throw ApiException('data inválida. Use YYYY-MM-DD.');
  }

  String _dataBr(DateTime data) {
    final d = data.day.toString().padLeft(2, '0');
    final m = data.month.toString().padLeft(2, '0');
    return '$d/$m/${data.year}';
  }
}

class FinanceiroEscopo extends InheritedNotifier<FinanceiroLoja> {
  const FinanceiroEscopo({
    super.key,
    required FinanceiroLoja loja,
    required super.child,
  }) : super(notifier: loja);

  static FinanceiroLoja of(BuildContext context) {
    final escopo = context
        .dependOnInheritedWidgetOfExactType<FinanceiroEscopo>();
    assert(escopo != null, 'FinanceiroEscopo ausente');
    return escopo!.notifier!;
  }
}
