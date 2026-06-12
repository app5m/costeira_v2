class SanitarioEntity {
  const SanitarioEntity({
    required this.id,
    required this.appUsersId,
    required this.tipoManejo,
    this.tipoCarrapaticida,
    this.dataPlanejada,
    this.dataExecucao,
    this.obs,
    this.dataCadastro,
    this.updateAt,
    required this.status,
    this.categorias = const [],
    this.lotes = const [],
    this.insumos = const [],
    this.idLocal,
    this.syncStatus,
    this.pendingAction,
    this.isLocalOnly = false,
  });

  final int id;
  final int appUsersId;
  final String tipoManejo;
  final String? tipoCarrapaticida;
  final String? dataPlanejada;
  final String? dataExecucao;
  final String? obs;
  final String? dataCadastro;
  final String? updateAt;
  final String status;
  final List<SanitarioCategoriaEntity> categorias;
  final List<SanitarioLoteEntity> lotes;
  final List<SanitarioInsumoEntity> insumos;
  final String? idLocal;
  final String? syncStatus;
  final String? pendingAction;
  final bool isLocalOnly;
}

class SanitarioCategoriaEntity {
  const SanitarioCategoriaEntity({
    required this.id,
    this.appSanitariosId,
    this.appAnimaisCategoriasId,
    required this.nome,
    this.sexo,
  });

  final int id;
  final int? appSanitariosId;
  final int? appAnimaisCategoriasId;
  final String nome;
  final int? sexo;
}

class SanitarioLoteEntity {
  const SanitarioLoteEntity({
    required this.id,
    this.appSanitariosId,
    this.appAnimaisLotesId,
    required this.nome,
    this.appUsersId,
    this.createAt,
    this.updateAt,
  });

  final int id;
  final int? appSanitariosId;
  final int? appAnimaisLotesId;
  final String nome;
  final int? appUsersId;
  final String? createAt;
  final String? updateAt;
}

class SanitarioInsumoEntity {
  const SanitarioInsumoEntity({
    required this.id,
    required this.appUsersId,
    required this.tipoInsumo,
    required this.nome,
    this.qtdTotal,
    this.valorUnidade,
    this.valorTotal,
    this.dataValidade,
    this.unidade,
  });

  final int id;
  final int appUsersId;
  final String tipoInsumo;
  final String nome;
  final double? qtdTotal;
  final double? valorUnidade;
  final double? valorTotal;
  final String? dataValidade;
  final SanitarioReferenceEntity? unidade;
}

class SanitarioReferenceEntity {
  const SanitarioReferenceEntity({required this.id, required this.nome});

  final dynamic id;
  final String nome;
}

class SanitarioTipoManejoEntity {
  const SanitarioTipoManejoEntity({
    required this.id,
    required this.nome,
    this.tiposCarrapaticida = const [],
  });

  final String id;
  final String nome;
  final List<SanitarioReferenceEntity> tiposCarrapaticida;
}

class SanitariosFilterEntity {
  const SanitariosFilterEntity({
    required this.appUsersId,
    this.id,
    this.tipoManejo,
    this.dataIn,
    this.dataOut,
  });

  final int appUsersId;
  final int? id;
  final String? tipoManejo;
  final String? dataIn;
  final String? dataOut;
}

class SanitariosListEntity {
  const SanitariosListEntity({
    required this.rows,
    required this.lista,
    this.tiposManejos = const [],
    this.status = const [],
    this.categorias = const [],
    this.lotes = const [],
    this.insumos = const [],
  });

  final int rows;
  final List<SanitarioEntity> lista;
  final List<SanitarioTipoManejoEntity> tiposManejos;
  final List<SanitarioReferenceEntity> status;
  final List<SanitarioCategoriaEntity> categorias;
  final List<SanitarioLoteEntity> lotes;
  final List<SanitarioInsumoEntity> insumos;

  List<SanitarioEntity> byStatus(String value) {
    return lista.where((item) => item.status == value).toList(growable: false);
  }
}

class SanitarioUpsertEntity {
  const SanitarioUpsertEntity({
    this.id,
    this.appUsersId,
    required this.tipoManejo,
    this.tipoCarrapaticida,
    required this.dataPlanejada,
    this.obs,
    required this.categorias,
    required this.lotes,
  });

  final int? id;
  final int? appUsersId;
  final String tipoManejo;
  final String? tipoCarrapaticida;
  final String dataPlanejada;
  final String? obs;
  final List<int> categorias;
  final List<int> lotes;

  SanitarioUpsertEntity copyWith({int? appUsersId}) {
    return SanitarioUpsertEntity(
      id: id,
      appUsersId: appUsersId ?? this.appUsersId,
      tipoManejo: tipoManejo,
      tipoCarrapaticida: tipoCarrapaticida,
      dataPlanejada: dataPlanejada,
      obs: obs,
      categorias: categorias,
      lotes: lotes,
    );
  }
}

class DeleteSanitarioEntity {
  const DeleteSanitarioEntity({required this.appUsersId, required this.id});

  final int appUsersId;
  final int id;
}

class SanitarioExecucaoInsumoEntity {
  const SanitarioExecucaoInsumoEntity({
    required this.idInsumo,
    required this.quantidade,
  });

  final int idInsumo;
  final double quantidade;
}

class SanitarioExecucaoEntity {
  const SanitarioExecucaoEntity({
    required this.id,
    this.appUsersId,
    required this.dataExecucao,
    required this.insumos,
  });

  final int id;
  final int? appUsersId;
  final String dataExecucao;
  final List<SanitarioExecucaoInsumoEntity> insumos;

  SanitarioExecucaoEntity copyWith({int? appUsersId}) {
    return SanitarioExecucaoEntity(
      id: id,
      appUsersId: appUsersId ?? this.appUsersId,
      dataExecucao: dataExecucao,
      insumos: insumos,
    );
  }
}

class SanitarioChartsFilterEntity {
  const SanitarioChartsFilterEntity({
    required this.appUsersId,
    required this.mesAno,
  });

  final int appUsersId;
  final String mesAno;
}

class SanitarioChartsEntity {
  const SanitarioChartsEntity({
    required this.planejadosExecutados,
    required this.executadoPorInsumoTipoManejo,
    required this.planejadosExecutadosMesAMes,
  });

  final SanitarioPlanejadoExecutadoEntity planejadosExecutados;
  final List<SanitarioExecutadoInsumoTipoManejoEntity>
  executadoPorInsumoTipoManejo;
  final List<SanitarioPlanejadoExecutadoMesEntity> planejadosExecutadosMesAMes;

  static const empty = SanitarioChartsEntity(
    planejadosExecutados: SanitarioPlanejadoExecutadoEntity(
      planejado: 0,
      executado: 0,
    ),
    executadoPorInsumoTipoManejo: [],
    planejadosExecutadosMesAMes: [],
  );
}

class SanitarioPlanejadoExecutadoEntity {
  const SanitarioPlanejadoExecutadoEntity({
    required this.planejado,
    required this.executado,
  });

  final double planejado;
  final double executado;
}

class SanitarioExecutadoInsumoTipoManejoEntity {
  const SanitarioExecutadoInsumoTipoManejoEntity({
    required this.tipoManejo,
    required this.insumo,
    required this.quantidade,
  });

  final String tipoManejo;
  final SanitarioReferenceEntity insumo;
  final double quantidade;
}

class SanitarioPlanejadoExecutadoMesEntity {
  const SanitarioPlanejadoExecutadoMesEntity({
    required this.ano,
    required this.mes,
    required this.status,
    required this.quantidade,
  });

  final int ano;
  final int mes;
  final String status;
  final double quantidade;
}
