class InsumoEntity {
  const InsumoEntity({
    required this.id,
    required this.appUsersId,
    required this.tipoInsumo,
    this.appEstoquesInsumosSuplementosId,
    required this.nome,
    required this.appEstoquesInsumosUnidadesId,
    this.valorUnidade,
    this.valorTotal,
    this.valorUnidadeRaw,
    this.valorTotalRaw,
    this.qtdTotal,
    this.obs,
    this.dataValidade,
    this.dataCadastro,
    this.updateAt,
    this.unidade,
    this.suplemento,
    this.idLocal,
    this.syncStatus,
    this.pendingAction,
    this.isLocalOnly = false,
  });

  final int id;
  final int appUsersId;
  final String tipoInsumo;
  final int? appEstoquesInsumosSuplementosId;
  final String nome;
  final int appEstoquesInsumosUnidadesId;
  final String? valorUnidade;
  final String? valorTotal;
  final double? valorUnidadeRaw;
  final double? valorTotalRaw;
  final double? qtdTotal;
  final String? obs;
  final String? dataValidade;
  final String? dataCadastro;
  final String? updateAt;
  final InsumoReferenceEntity? unidade;
  final InsumoReferenceEntity? suplemento;
  final String? idLocal;
  final String? syncStatus;
  final String? pendingAction;
  final bool isLocalOnly;
}

class InsumoReferenceEntity {
  const InsumoReferenceEntity({required this.id, required this.nome});

  final dynamic id;
  final String nome;
}

class InsumosFilterEntity {
  const InsumosFilterEntity({
    required this.appUsersId,
    this.id,
    this.tipoInsumo,
  });

  final int appUsersId;
  final int? id;
  final String? tipoInsumo;
}

class InsumosListEntity {
  const InsumosListEntity({
    required this.rows,
    required this.lista,
    this.registros = const [],
    this.suplementos = const [],
    this.unidades = const [],
    this.tipoInsumos = const [],
  });

  final int rows;
  final List<InsumoEntity> lista;
  final List<InsumoRegistroEntity> registros;
  final List<InsumoReferenceEntity> suplementos;
  final List<InsumoReferenceEntity> unidades;
  final List<InsumoReferenceEntity> tipoInsumos;
}

class InsumoRegistroEntity {
  const InsumoRegistroEntity({
    required this.id,
    required this.appEstoquesInsumosId,
    required this.estoqueNome,
    required this.tipoInsumo,
    required this.tipo,
    required this.appEstoquesInsumosUnidadesId,
    this.unidade,
    this.qtd,
    this.obs,
    this.dataCadastro,
    this.updateAt,
    this.idLocal,
    this.syncStatus,
    this.pendingAction,
    this.isLocalOnly = false,
  });

  final int id;
  final int appEstoquesInsumosId;
  final String estoqueNome;
  final String tipoInsumo;
  final InsumoReferenceEntity tipo;
  final int appEstoquesInsumosUnidadesId;
  final InsumoReferenceEntity? unidade;
  final double? qtd;
  final String? obs;
  final String? dataCadastro;
  final String? updateAt;
  final String? idLocal;
  final String? syncStatus;
  final String? pendingAction;
  final bool isLocalOnly;
}

class InsumoUpsertEntity {
  const InsumoUpsertEntity({
    this.id,
    this.appUsersId,
    required this.tipoInsumo,
    this.appEstoquesInsumosSuplementosId,
    required this.nome,
    required this.appEstoquesInsumosUnidadesId,
    required this.valorUnidade,
    required this.qtdTotal,
    this.obs,
    this.dataValidade,
  });

  final int? id;
  final int? appUsersId;
  final String tipoInsumo;
  final int? appEstoquesInsumosSuplementosId;
  final String nome;
  final int appEstoquesInsumosUnidadesId;
  final String valorUnidade;
  final double qtdTotal;
  final String? obs;
  final String? dataValidade;

  InsumoUpsertEntity copyWith({int? appUsersId}) {
    return InsumoUpsertEntity(
      id: id,
      appUsersId: appUsersId ?? this.appUsersId,
      tipoInsumo: tipoInsumo,
      appEstoquesInsumosSuplementosId: appEstoquesInsumosSuplementosId,
      nome: nome,
      appEstoquesInsumosUnidadesId: appEstoquesInsumosUnidadesId,
      valorUnidade: valorUnidade,
      qtdTotal: qtdTotal,
      obs: obs,
      dataValidade: dataValidade,
    );
  }
}

class InsumoRegistroUpsertEntity {
  const InsumoRegistroUpsertEntity({
    this.id,
    this.appUsersId,
    required this.appEstoquesInsumosId,
    required this.tipo,
    required this.appEstoquesInsumosUnidadesId,
    required this.qtd,
    this.obs,
  });

  final int? id;
  final int? appUsersId;
  final int appEstoquesInsumosId;
  final int tipo;
  final int appEstoquesInsumosUnidadesId;
  final double qtd;
  final String? obs;

  InsumoRegistroUpsertEntity copyWith({int? appUsersId}) {
    return InsumoRegistroUpsertEntity(
      id: id,
      appUsersId: appUsersId ?? this.appUsersId,
      appEstoquesInsumosId: appEstoquesInsumosId,
      tipo: tipo,
      appEstoquesInsumosUnidadesId: appEstoquesInsumosUnidadesId,
      qtd: qtd,
      obs: obs,
    );
  }
}

class DeleteInsumoEntity {
  const DeleteInsumoEntity({required this.appUsersId, required this.id});

  final int appUsersId;
  final int id;
}

class InsumosTipoFilterEntity {
  const InsumosTipoFilterEntity({
    required this.appUsersId,
    this.tipo,
    this.nome,
  });

  final int appUsersId;
  final String? tipo;
  final String? nome;
}

class InsumoTipoEntity {
  const InsumoTipoEntity({
    required this.id,
    required this.nome,
    required this.tipoInsumo,
    this.qtdTotal,
    this.unidade,
    this.suplemento,
  });

  final int id;
  final String nome;
  final String tipoInsumo;
  final double? qtdTotal;
  final InsumoReferenceEntity? unidade;
  final InsumoReferenceEntity? suplemento;
}

class InsumosTipoListEntity {
  const InsumosTipoListEntity({required this.rows, required this.data});

  final int rows;
  final List<InsumoTipoEntity> data;
}

class InsumoChartsFilterEntity {
  const InsumoChartsFilterEntity({
    required this.appUsersId,
    required this.mesAno,
  });

  final int appUsersId;
  final String mesAno;
}

class InsumoChartsEntity {
  const InsumoChartsEntity({
    required this.quantidadePorTipo,
    required this.evolucaoMesAMes,
  });

  final List<InsumoQuantidadePorTipoEntity> quantidadePorTipo;
  final List<InsumoChartPointEntity> evolucaoMesAMes;

  static const empty = InsumoChartsEntity(
    quantidadePorTipo: [],
    evolucaoMesAMes: [],
  );
}

class InsumoQuantidadePorTipoEntity {
  const InsumoQuantidadePorTipoEntity({
    required this.tipoInsumo,
    required this.quantidade,
    required this.percentual,
  });

  final String tipoInsumo;
  final double quantidade;
  final double percentual;
}

class InsumoChartPointEntity {
  const InsumoChartPointEntity({required this.label, required this.value});

  final String label;
  final double value;
}
