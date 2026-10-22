import 'package:flutter/material.dart';

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
    this.descricao = '',
    this.pagamentos = const [],
    this.alocacao = const [],
    this.historico = const [],
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
  final String descricao;
  final List<PagamentoMock> pagamentos;
  final List<AlocacaoMock> alocacao;
  final List<String> historico;

  double get pendente => (valor - liquidado).clamp(0, valor);

  bool get entrada => tipo == 'recebimento';
}

class PagamentoMock {
  const PagamentoMock(this.data, this.conta, this.valor);

  final String data;
  final String conta;
  final double valor;
}

class AlocacaoMock {
  const AlocacaoMock(this.nome, this.valor);

  final String nome;
  final double valor;
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

class FinanceiroLoja extends ChangeNotifier {
  FinanceiroLoja() {
    lancamentos = [
      LancamentoMock(
        id: 1,
        titulo: 'Energia elétrica',
        subtitulo: '20 out · Custo fixo',
        tipo: 'pagamento',
        categoria: 'Custo Fixo',
        rubrica: 'Luz',
        valor: 1000,
        liquidado: 400,
        situacao: SituacaoLancamento.parcial,
        dataCurta: '20 out',
        competencia: '20/10/2026',
        fornecedor: 'Cooperativa local',
        descricao: 'Energia elétrica',
        alocacao: const [
          AlocacaoMock('Vacas matrizes', 600),
          AlocacaoMock('Cria', 400),
        ],
        pagamentos: const [
          PagamentoMock('20/10/2026', 'Banco principal', 400),
        ],
        historico: const [
          'Lançamento confirmado · 20/10/2026 às 10:15',
          'Pagamento registrado · 20/10/2026 às 14:32 · R\$ 400,00',
        ],
      ),
      LancamentoMock(
        id: 2,
        titulo: 'Serviço recebido',
        subtitulo: '19 out · Receita operacional',
        tipo: 'recebimento',
        categoria: 'Operacional',
        rubrica: 'Receita Agrícola',
        valor: 2500,
        liquidado: 2500,
        situacao: SituacaoLancamento.liquidado,
        dataCurta: '19 out',
        competencia: '19/10/2026',
        comprador: 'Frigorífico Sul',
        descricao: 'Serviço recebido',
        historico: const ['Lançamento liquidado · 19/10/2026'],
      ),
      LancamentoMock(
        id: 3,
        titulo: 'Manutenção de cerca',
        subtitulo: '18 out · Custo fixo',
        tipo: 'pagamento',
        categoria: 'Custo Fixo',
        rubrica: 'Manutenções',
        valor: 750,
        liquidado: 0,
        situacao: SituacaoLancamento.pendente,
        dataCurta: '18 out',
        competencia: '18/10/2026',
        fornecedor: 'Casa Agro',
        descricao: 'Manutenção de cerca',
        historico: const ['Lançamento pendente · 18/10/2026'],
      ),
      LancamentoMock(
        id: 4,
        titulo: 'Compra direta de alimentação',
        subtitulo: '17 out · Insumos',
        tipo: 'pagamento',
        categoria: 'Custo Variável',
        rubrica: 'Suplementação',
        valor: 900,
        liquidado: 0,
        situacao: SituacaoLancamento.rascunho,
        dataCurta: '17 out',
        competencia: '17/10/2026',
        descricao: 'Compra direta de alimentação',
        historico: const ['Rascunho · 17/10/2026'],
      ),
    ];
    contas = [
      ContaMock(
        id: 1,
        nome: 'Banco principal',
        tipo: 'Banco',
        saldo: 18000,
        ativa: true,
        motivo: 'Cadastro da conta da fazenda',
        movimentos: const [
          MovimentoContaMock('20 out', 'Pagamento de energia', -1000, ''),
          MovimentoContaMock('18 out', 'Recebimento de serviço', 2500, ''),
          MovimentoContaMock('15 out', 'Pagamento de manutenção', -3500, ''),
          MovimentoContaMock('01 out', 'Saldo inicial', 20000, 'Abertura'),
        ],
      ),
      ContaMock(
        id: 2,
        nome: 'Caixa da fazenda',
        tipo: 'Caixa',
        saldo: 1580,
        ativa: true,
      ),
      ContaMock(
        id: 3,
        nome: 'Banco reserva',
        tipo: 'Banco',
        saldo: 5000,
        ativa: true,
        saldoInicialRegistrado: false,
      ),
    ];
  }

  late List<LancamentoMock> lancamentos;
  late List<ContaMock> contas;
  int _seq = 10;

  double get saldoDisponivel =>
      contas.where((c) => c.ativa).fold(0, (s, c) => s + c.saldo);

  double get aPagar => lancamentos
      .where((l) => !l.entrada && l.situacao != SituacaoLancamento.rascunho)
      .fold(0, (s, l) => s + l.pendente);

  double get aReceber => lancamentos
      .where((l) => l.entrada && l.situacao != SituacaoLancamento.liquidado)
      .fold(0, (s, l) => s + l.pendente);

  void adicionar(LancamentoMock item) {
    lancamentos = [item, ...lancamentos];
    notifyListeners();
  }

  LancamentoMock novo({
    required String titulo,
    required String tipo,
    required String categoria,
    required String rubrica,
    required double valor,
    required String descricao,
    String? fornecedor,
    String? comprador,
    bool rascunho = false,
  }) {
    final id = _seq++;
    return LancamentoMock(
      id: id,
      titulo: titulo,
      subtitulo: '21 out · $categoria',
      tipo: tipo,
      categoria: categoria,
      rubrica: rubrica,
      valor: valor,
      liquidado: 0,
      situacao: rascunho
          ? SituacaoLancamento.rascunho
          : SituacaoLancamento.pendente,
      dataCurta: '21 out',
      competencia: '21/10/2026',
      fornecedor: fornecedor,
      comprador: comprador,
      descricao: descricao,
      historico: [
        rascunho
            ? 'Rascunho · 21/10/2026'
            : 'Lançamento confirmado · 21/10/2026',
      ],
    );
  }

  void registrarBaixa(int id, {required double valor, required String conta}) {
    lancamentos = [
      for (final item in lancamentos)
        if (item.id != id)
          item
        else
          LancamentoMock(
            id: item.id,
            titulo: item.titulo,
            subtitulo: item.subtitulo,
            tipo: item.tipo,
            categoria: item.categoria,
            rubrica: item.rubrica,
            valor: item.valor,
            liquidado: item.liquidado + valor,
            situacao: item.liquidado + valor >= item.valor
                ? SituacaoLancamento.liquidado
                : SituacaoLancamento.parcial,
            dataCurta: item.dataCurta,
            competencia: item.competencia,
            fornecedor: item.fornecedor,
            comprador: item.comprador,
            descricao: item.descricao,
            alocacao: item.alocacao,
            pagamentos: [
              ...item.pagamentos,
              PagamentoMock('21/10/2026', conta, valor),
            ],
            historico: [
              ...item.historico,
              'Pagamento registrado · 21/10/2026 · conta $conta',
            ],
          ),
    ];
    notifyListeners();
  }

  void estornarPagamento(int id) {
    lancamentos = [
      for (final item in lancamentos)
        if (item.id != id)
          item
        else
          LancamentoMock(
            id: item.id,
            titulo: item.titulo,
            subtitulo: item.subtitulo,
            tipo: item.tipo,
            categoria: item.categoria,
            rubrica: item.rubrica,
            valor: item.valor,
            liquidado: 0,
            situacao: SituacaoLancamento.pendente,
            dataCurta: item.dataCurta,
            competencia: item.competencia,
            fornecedor: item.fornecedor,
            comprador: item.comprador,
            descricao: item.descricao,
            alocacao: item.alocacao,
            historico: [
              ...item.historico,
              'Pagamento estornado · 21/10/2026',
            ],
          ),
    ];
    notifyListeners();
  }

  void estornar(int id) {
    lancamentos = [
      for (final item in lancamentos)
        if (item.id != id)
          item
        else
          LancamentoMock(
            id: item.id,
            titulo: item.titulo,
            subtitulo: item.subtitulo,
            tipo: item.tipo,
            categoria: item.categoria,
            rubrica: item.rubrica,
            valor: item.valor,
            liquidado: 0,
            situacao: SituacaoLancamento.pendente,
            dataCurta: item.dataCurta,
            competencia: item.competencia,
            fornecedor: item.fornecedor,
            comprador: item.comprador,
            descricao: item.descricao,
            alocacao: item.alocacao,
            historico: [
              ...item.historico,
              'Lançamento estornado · 21/10/2026',
            ],
          ),
    ];
    notifyListeners();
  }

  void salvarConta(ContaMock conta) {
    final i = contas.indexWhere((c) => c.id == conta.id);
    if (i < 0) {
      contas = [conta, ...contas];
    } else {
      contas = [...contas]..[i] = conta;
    }
    notifyListeners();
  }

  int novoIdConta() => _seq++;
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
