class Suplemento {
  const Suplemento({
    required this.id,
    required this.appUsersId,
    required this.appPotreirosId,
    required this.appAnimaisLotesId,
    required this.appEstoquesInsumosId,
    this.dataPostagem,
    this.pesoMedio,
    this.quantidadeAtual,
    this.quantidadeAnimais,
    this.consumoReal,
    this.dataCadastro,
    this.updateAt,
    this.produto,
    this.potreiro,
    this.lote,
    this.registros = const [],
  });

  final int id;
  final int appUsersId;
  final int appPotreirosId;
  final int appAnimaisLotesId;
  final int appEstoquesInsumosId;
  final String? dataPostagem;
  final double? pesoMedio;
  final double? quantidadeAtual;
  final int? quantidadeAnimais;
  final SuplementoConsumoReal? consumoReal;
  final String? dataCadastro;
  final String? updateAt;
  final SuplementoReference? produto;
  final SuplementoReference? potreiro;
  final SuplementoReference? lote;
  final List<SuplementoRegistro> registros;
}

class SuplementoConsumoReal {
  const SuplementoConsumoReal({
    this.intervaloDias,
    this.quantidadeConsumidaPeriodo,
    this.consumoRealDiaLote,
    this.consumoRealAnimalDia,
  });

  final int? intervaloDias;
  final double? quantidadeConsumidaPeriodo;
  final String? consumoRealDiaLote;
  final String? consumoRealAnimalDia;
}

class SuplementoReference {
  const SuplementoReference({
    required this.id,
    required this.nome,
    this.tipoInsumo,
  });

  final int id;
  final String nome;
  final String? tipoInsumo;
}

class SuplementoRegistro {
  const SuplementoRegistro({
    required this.id,
    required this.appSuplementacaoId,
    required this.tipo,
    this.dataRestabastecimento,
    this.quantidade,
    this.dataCadastro,
    this.updateAt,
    this.suplemento,
  });

  final int id;
  final int appSuplementacaoId;
  final SuplementoReference tipo;
  final String? dataRestabastecimento;
  final double? quantidade;
  final String? dataCadastro;
  final String? updateAt;
  final Suplemento? suplemento;
}

class SuplementoUpsertEntity {
  const SuplementoUpsertEntity({
    this.id,
    this.appUsersId,
    required this.appPotreirosId,
    required this.appAnimaisLotesId,
    required this.appEstoquesInsumosId,
    required this.dataPostagem,
    required this.quantidade,
  });

  final int? id;
  final int? appUsersId;
  final int appPotreirosId;
  final int appAnimaisLotesId;
  final int appEstoquesInsumosId;
  final String dataPostagem;
  final double quantidade;

  SuplementoUpsertEntity copyWith({int? appUsersId}) {
    return SuplementoUpsertEntity(
      id: id,
      appUsersId: appUsersId ?? this.appUsersId,
      appPotreirosId: appPotreirosId,
      appAnimaisLotesId: appAnimaisLotesId,
      appEstoquesInsumosId: appEstoquesInsumosId,
      dataPostagem: dataPostagem,
      quantidade: quantidade,
    );
  }
}

class SuplementoRegistroUpsertEntity {
  const SuplementoRegistroUpsertEntity({
    this.id,
    this.appUsersId,
    required this.appSuplementacaoId,
    required this.tipo,
    required this.dataRestabastecimento,
    required this.quantidade,
  });

  final int? id;
  final int? appUsersId;
  final int appSuplementacaoId;
  final int tipo;
  final String dataRestabastecimento;
  final double quantidade;

  SuplementoRegistroUpsertEntity copyWith({int? appUsersId}) {
    return SuplementoRegistroUpsertEntity(
      id: id,
      appUsersId: appUsersId ?? this.appUsersId,
      appSuplementacaoId: appSuplementacaoId,
      tipo: tipo,
      dataRestabastecimento: dataRestabastecimento,
      quantidade: quantidade,
    );
  }
}

class DeleteSuplementoEntity {
  const DeleteSuplementoEntity({required this.appUsersId, required this.id});

  final int appUsersId;
  final int id;
}

class DeleteSuplementoRegistroEntity {
  const DeleteSuplementoRegistroEntity({
    required this.appUsersId,
    required this.id,
  });

  final int appUsersId;
  final int id;
}

class SuplementoChartsFilterEntity {
  const SuplementoChartsFilterEntity({
    required this.appUsersId,
    required this.mesAno,
    this.idPotreiro,
    this.idLote,
    this.idProduto,
  });

  final int appUsersId;
  final String mesAno;
  final int? idPotreiro;
  final int? idLote;
  final int? idProduto;
}

class SuplementoChartsEntity {
  const SuplementoChartsEntity({
    required this.comparativoPotreiroLote,
    required this.mesAMes,
  });

  final List<SuplementoComparativoPotreiroLoteEntity> comparativoPotreiroLote;
  final List<SuplementoMesAMesEntity> mesAMes;

  static const empty = SuplementoChartsEntity(
    comparativoPotreiroLote: [],
    mesAMes: [],
  );
}

class SuplementoComparativoPotreiroLoteEntity {
  const SuplementoComparativoPotreiroLoteEntity({
    required this.suplementacaoId,
    required this.potreiroNome,
    required this.loteNome,
    required this.quantidadeAnimais,
    required this.consumoTotal,
    this.consumoReal,
  });

  final int suplementacaoId;
  final String potreiroNome;
  final String loteNome;
  final int quantidadeAnimais;
  final double consumoTotal;
  final SuplementoConsumoReal? consumoReal;
}

class SuplementoMesAMesEntity {
  const SuplementoMesAMesEntity({required this.label, required this.value});

  final String label;
  final double value;
}
