class ManejoEdicaoCampos {
  const ManejoEdicaoCampos({
    required this.id,
    required this.categoria,
    required this.data,
    this.obs = '',
    this.score = '',
    this.dosagem = '',
    this.tipoDosagem,
    this.tipoId,
    this.responsavel = '',
    this.novoBrinco = '',
    this.motivo = '',
    this.loteId,
    this.piqueteId,
    this.categoriaAnimalId,
    this.faseId,
    this.racaId,
    this.duracao = '',
    this.semen = '',
    this.classificacao,
    this.estoqueId,
    this.quantidade = '',
    this.trocaBrinco = false,
    this.usarProduto = false,
    this.destinoPiquete = false,
  });

  final int id;
  final int categoria;
  final String data;
  final String obs;
  final String score;
  final String dosagem;
  final int? tipoDosagem;
  final int? tipoId;
  final String responsavel;
  final String novoBrinco;
  final String motivo;
  final int? loteId;
  final int? piqueteId;
  final int? categoriaAnimalId;
  final int? faseId;
  final int? racaId;
  final String duracao;
  final String semen;
  final int? classificacao;
  final int? estoqueId;
  final String quantidade;
  final bool trocaBrinco;
  final bool usarProduto;
  final bool destinoPiquete;
}

Map<String, dynamic> montarAtualizacaoManejo(ManejoEdicaoCampos campos) {
  final base = <String, dynamic>{
    'id': campos.id,
    'data': campos.data,
  };
  final obs = campos.obs.trim();
  return switch (campos.categoria) {
    1 => {
      ...base,
      if (campos.score.trim().isNotEmpty) 'score': _numero(campos.score),
      if (obs.isNotEmpty) 'obs': obs,
    },
    2 || 3 => {
      ...base,
      'tipo_dosagem': campos.tipoDosagem ?? 2,
      'dosagem': _numero(campos.dosagem),
      if (obs.isNotEmpty) 'obs': obs,
    },
    4 => {
      ...base,
      'id_tipo': campos.tipoId,
      if (campos.responsavel.trim().isNotEmpty) 'responsavel': campos.responsavel.trim(),
      if (campos.tipoDosagem != null) 'tipo_dosagem': campos.tipoDosagem,
      if (campos.tipoDosagem != null) 'dosagem': _numero(campos.dosagem),
      if (obs.isNotEmpty) 'obs': obs,
    },
    5 when campos.trocaBrinco => {
      ...base,
      'id_tipo': campos.tipoId,
      'novo_brinco': campos.novoBrinco.trim(),
      if (campos.motivo.trim().isNotEmpty) 'motivo_troca_brinco': campos.motivo.trim(),
    },
    5 => {
      ...base,
      'id_tipo': campos.tipoId,
    },
    6 => {
      'id': campos.id,
      'id_categoria': 6,
      'app_animais_categorias_id': campos.categoriaAnimalId,
      'app_animais_subcategorias_id': campos.faseId,
      'data': campos.data,
      'app_animais_lotes_id': campos.loteId,
    },
    7 => {
      'id': campos.id,
      'id_categoria': 7,
      'data': campos.data,
      if (campos.destinoPiquete) 'app_potreiros_id': campos.piqueteId,
      if (!campos.destinoPiquete) 'app_animais_lotes_id': campos.loteId,
    },
    8 => {
      'id': campos.id,
      'id_categoria': 8,
      'data': campos.data,
      if (campos.racaId != null) 'ut_bases_raciais_id': campos.racaId,
      'app_animais_lotes_id': campos.loteId,
      'duracao_estacao': int.tryParse(campos.duracao.trim()) ?? 0,
    },
    9 => {
      'id': campos.id,
      'id_categoria': 9,
      'data': campos.data,
    },
    10 => {
      'id': campos.id,
      'id_categoria': 10,
      'data': campos.data,
      'app_animais_lotes_id': campos.loteId,
      'id_tipo': campos.tipoId,
      if (campos.semen.trim().isNotEmpty) 'semen_utilizado': campos.semen.trim(),
      if (campos.responsavel.trim().isNotEmpty) 'responsavel': campos.responsavel.trim(),
    },
    11 => {
      'id': campos.id,
      'id_categoria': 11,
      'data': campos.data,
      'id_tipo': campos.tipoId,
      'classificacao': campos.classificacao,
      'app_animais_lotes_id': campos.loteId,
    },
    13 => {
      'id': campos.id,
      'id_categoria': 13,
      'data': campos.data,
      'motivo': campos.motivo.trim(),
      'app_animais_lotes_id': campos.loteId,
    },
    14 => {
      'id': campos.id,
      'id_categoria': 14,
      'id_tipo': campos.tipoId,
      'app_potreiros_id': campos.piqueteId,
      'data': campos.data,
      if (obs.isNotEmpty) 'obs': obs,
      if (campos.usarProduto) 'id_estoque': campos.estoqueId,
      if (campos.usarProduto) 'tipo_dosagem': campos.tipoDosagem ?? 4,
      if (campos.usarProduto) 'quantidade': _numero(campos.quantidade).round(),
    },
    _ => base,
  };
}

num _numero(String raw) {
  final normal = raw.trim().replaceAll(',', '.');
  return num.tryParse(normal) ?? 0;
}
