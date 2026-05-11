class Manejo {
  const Manejo({
    required this.id,
    required this.appUsersId,
    required this.appPotreirosId,
    required this.tipoManejo,
    required this.appEstoquesInsumosUnidadesId,
    this.dataManejo,
    this.quantidade,
    this.dataCadastro,
    this.updateAt,
    this.potreiro,
    this.unidade,
  });

  final int id;
  final int appUsersId;
  final int appPotreirosId;
  final String tipoManejo;
  final String? dataManejo;
  final double? quantidade;
  final int appEstoquesInsumosUnidadesId;
  final String? dataCadastro;
  final String? updateAt;
  final ManejoReference? potreiro;
  final ManejoReference? unidade;
}

class TipoManejo {
  const TipoManejo({
    required this.id,
    required this.nome,
    required this.unidade,
    this.tipoInsumo = '',
  });

  final String id;
  final String nome;
  final String unidade;
  final String tipoInsumo;
}

class ManejoReference {
  const ManejoReference({required this.id, required this.nome});

  final int id;
  final String nome;
}

class ManejoUpsertEntity {
  const ManejoUpsertEntity({
    this.id,
    this.appUsersId,
    required this.appPotreirosId,
    required this.tipoManejo,
    required this.dataManejo,
    required this.quantidade,
  });

  final int? id;
  final int? appUsersId;
  final int appPotreirosId;
  final String tipoManejo;
  final String dataManejo;
  final double quantidade;

  ManejoUpsertEntity copyWith({int? appUsersId}) {
    return ManejoUpsertEntity(
      id: id,
      appUsersId: appUsersId ?? this.appUsersId,
      appPotreirosId: appPotreirosId,
      tipoManejo: tipoManejo,
      dataManejo: dataManejo,
      quantidade: quantidade,
    );
  }
}

class DeleteManejoEntity {
  const DeleteManejoEntity({required this.appUsersId, required this.id});

  final int appUsersId;
  final int id;
}

class ManejoChartsFilterEntity {
  const ManejoChartsFilterEntity({
    required this.appUsersId,
    required this.mesAno,
  });

  final int appUsersId;
  final String mesAno;
}

class ManejoChartsEntity {
  const ManejoChartsEntity({
    required this.manejosPorPotreiro,
    required this.manejosTipoPotreiroMes,
  });

  final List<ManejoPorPotreiroEntity> manejosPorPotreiro;
  final List<ManejoTipoPotreiroMesEntity> manejosTipoPotreiroMes;

  static const empty = ManejoChartsEntity(
    manejosPorPotreiro: [],
    manejosTipoPotreiroMes: [],
  );
}

class ManejoPorPotreiroEntity {
  const ManejoPorPotreiroEntity({
    required this.appPotreirosId,
    required this.potreiroNome,
    required this.quantidade,
  });

  final int appPotreirosId;
  final String potreiroNome;
  final double quantidade;
}

class ManejoTipoPotreiroMesEntity {
  const ManejoTipoPotreiroMesEntity({
    required this.ano,
    required this.mes,
    required this.appPotreirosId,
    required this.potreiroNome,
    required this.tipoManejo,
    required this.quantidade,
  });

  final int ano;
  final int mes;
  final int appPotreirosId;
  final String potreiroNome;
  final String tipoManejo;
  final double quantidade;
}
