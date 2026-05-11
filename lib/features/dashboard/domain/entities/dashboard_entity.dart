class DashboardPeriodEntity {
  const DashboardPeriodEntity({required this.dataIn, required this.dataOut});

  final String dataIn;
  final String dataOut;
}

class DashboardValueEntity {
  const DashboardValueEntity({
    this.valor,
    this.observacao,
    this.descricao,
    this.hectares,
  });

  final String? valor;
  final String? observacao;
  final String? descricao;
  final String? hectares;
}

class DashboardTasksMonthEntity {
  const DashboardTasksMonthEntity({
    required this.quantidade,
    required this.concluidas,
    required this.percentualConcluido,
  });

  final int quantidade;
  final int concluidas;
  final String percentualConcluido;
}

class DashboardIndicatorsEntity {
  const DashboardIndicatorsEntity({
    required this.quantidadeKilosProduzidos,
    required this.kilosPorHectare,
    required this.estoqueRebanhoReais,
    required this.totalAnimais,
    required this.mediaFazenda,
    required this.mortalidadePercentual,
    required this.ganhoMedioDiario,
    required this.tarefasMes,
  });

  final DashboardValueEntity quantidadeKilosProduzidos;
  final DashboardValueEntity kilosPorHectare;
  final DashboardValueEntity estoqueRebanhoReais;
  final int totalAnimais;
  final DashboardValueEntity mediaFazenda;
  final DashboardValueEntity mortalidadePercentual;
  final DashboardValueEntity ganhoMedioDiario;
  final DashboardTasksMonthEntity tarefasMes;
}

class DashboardProductionMonthEntity {
  const DashboardProductionMonthEntity({
    required this.label,
    required this.valor,
  });

  final String label;
  final double valor;
}

class DashboardAnimalCategoryEntity {
  const DashboardAnimalCategoryEntity({
    required this.id,
    required this.nome,
    required this.quantidade,
    required this.percentual,
  });

  final int id;
  final String nome;
  final int quantidade;
  final String percentual;
}

class DashboardTasksProgressEntity {
  const DashboardTasksProgressEntity({
    required this.total,
    required this.concluidas,
    required this.percentual,
  });

  final int total;
  final int concluidas;
  final String percentual;
}

class DashboardChartsEntity {
  const DashboardChartsEntity({
    required this.producaoKgMes,
    required this.animaisCategoria,
    required this.progressoTarefas,
  });

  final List<DashboardProductionMonthEntity> producaoKgMes;
  final List<DashboardAnimalCategoryEntity> animaisCategoria;
  final DashboardTasksProgressEntity progressoTarefas;
}

class DashboardEntity {
  const DashboardEntity({
    required this.periodo,
    required this.indicadores,
    required this.graficos,
  });

  final DashboardPeriodEntity periodo;
  final DashboardIndicatorsEntity indicadores;
  final DashboardChartsEntity graficos;

  static const empty = DashboardEntity(
    periodo: DashboardPeriodEntity(dataIn: '', dataOut: ''),
    indicadores: DashboardIndicatorsEntity(
      quantidadeKilosProduzidos: DashboardValueEntity(valor: '0,00'),
      kilosPorHectare: DashboardValueEntity(valor: '0,00', hectares: '0,00'),
      estoqueRebanhoReais: DashboardValueEntity(),
      totalAnimais: 0,
      mediaFazenda: DashboardValueEntity(valor: '0,00', descricao: 'kg/ha'),
      mortalidadePercentual: DashboardValueEntity(),
      ganhoMedioDiario: DashboardValueEntity(),
      tarefasMes: DashboardTasksMonthEntity(
        quantidade: 0,
        concluidas: 0,
        percentualConcluido: '0,00',
      ),
    ),
    graficos: DashboardChartsEntity(
      producaoKgMes: [],
      animaisCategoria: [],
      progressoTarefas: DashboardTasksProgressEntity(
        total: 0,
        concluidas: 0,
        percentual: '0,00',
      ),
    ),
  );
}
