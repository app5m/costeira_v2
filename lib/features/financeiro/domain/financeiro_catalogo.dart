class TipoLancamentoOpcao {
  const TipoLancamentoOpcao(this.id, this.rotulo, {this.travado = false});

  final String id;
  final String rotulo;
  final bool travado;
}

const tiposLancamento = [
  TipoLancamentoOpcao('recebimento', 'Recebimento'),
  TipoLancamentoOpcao('pagamento', 'Pagamento'),
  TipoLancamentoOpcao('investimento', 'Investimento', travado: true),
  TipoLancamentoOpcao('estoque', 'Estoque', travado: true),
];

const categoriasRecebimento = ['Operacional', 'Não Operacional'];

const categoriasPagamento = [
  'Custo Variável',
  'Custo Fixo',
  'Custo Financeiro',
  'Quitação de Dívida',
];

const rubricasRecebimentoOperacional = [
  'Touros Gordos',
  'Bois Gordos',
  'Novilhos Gordos',
  'Novilhas Gordas',
  'Vacas Gordas',
  'Vacas com cria',
  'Terneiros',
  'Terneiras',
  'Cordeiros',
  'Receita Agrícola',
];

const rubricasRecebimentoNaoOperacional = [
  'Arrendamentos Recebidos',
  'Receita Financeira',
  'Venda de bem usado',
  'Outras Receitas',
  'Resina',
];

const rubricasCustoVariavel = [
  'Suplementação',
  'Sanitário',
  'Veterinário',
  'Reprodução',
  'Adubação Pastagens',
  'Sementes',
  'Combustível/Diesel',
  'Manutenções de Maquinários',
  'Diaristas',
  'Serviço Terceirizado',
  'Fretes',
  'Comissões',
  'Impostos Variáveis',
  'Taxas',
  'Pastoreio por cabeça',
  'Parcela de pastagem plurianual',
  'Outras Despesas-CV',
  'Combustível',
  'Serviço terceirizado',
];

const rubricasCustoFixo = [
  'Folha de Pagamento',
  'Encargos',
  'Gerente',
  'Pró-labore',
  'Assessoria',
  'Contador',
  'Luz',
  'Internet',
  'Sede',
  'Impostos',
  'Arrendamentos',
  'Manutenções de Instalações',
  'Outras Despesas-CF',
  'Sede',
  'Impostos',
  'Seguro',
  'Manutenções',
];

const rubricasCustoFinanceiro = [
  'Juros',
  'Aplicação',
  'Juros cheque especial',
];

const categoriasAnimal = [
  'Geral',
  'Terneira',
  'Novilha',
  'Vaca',
  'Terneiro',
  'Novilho',
  'Boi',
  'Touro',
];

const fasesAnimal = [
  'Todas',
  'Ao pé',
  'Recria',
  'Matriz',
  'Terminação',
  'Reprodutor',
];

const statusAnimal = [
  'Todos',
  'Prenha',
  'Vazia',
  'Parida',
  'Descarte',
  'Engorda',
  'CUT',
  'Reprodução',
];

const parceirosMock = [
  'Cooperativa local',
  'Frigorífico Sul',
  'Posto Rural',
  'Casa Agro',
];

List<String> categoriasDoTipo(String tipo) {
  if (tipo == 'recebimento') return categoriasRecebimento;
  if (tipo == 'pagamento') return categoriasPagamento;
  return const [];
}

List<String> rubricasDaCategoria(String tipo, String categoria) {
  if (tipo == 'recebimento' && categoria == 'Operacional') {
    return rubricasRecebimentoOperacional;
  }
  if (tipo == 'recebimento' && categoria == 'Não Operacional') {
    return rubricasRecebimentoNaoOperacional;
  }
  if (tipo == 'pagamento' && categoria == 'Custo Variável') {
    return rubricasCustoVariavel;
  }
  if (tipo == 'pagamento' && categoria == 'Custo Fixo') {
    return rubricasCustoFixo;
  }
  if (tipo == 'pagamento' && categoria == 'Custo Financeiro') {
    return rubricasCustoFinanceiro;
  }
  return const [];
}

bool categoriaPedeRebanho(String tipo, String categoria) {
  return tipo == 'pagamento' && categoria == 'Custo Variável';
}
