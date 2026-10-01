class TransferenciaFazendaRef {
  const TransferenciaFazendaRef({
    required this.id,
    required this.nome,
    required this.cnpj,
  });

  final int id;
  final String nome;
  final String cnpj;
}

class TransferenciaFazendaAnimal {
  const TransferenciaFazendaAnimal({
    required this.appAnimaisId,
    this.brinco,
    this.categoria,
    this.fase,
    this.lote,
    this.piquete,
    this.peso,
  });

  final int appAnimaisId;
  final String? brinco;
  final String? categoria;
  final String? fase;
  final String? lote;
  final String? piquete;
  final double? peso;
}

class TransferenciaFazendaListItem {
  const TransferenciaFazendaListItem({
    required this.id,
    required this.appFazendasId,
    required this.appFazendasIdDest,
    required this.data,
    required this.statusTransferencia,
    required this.statusString,
    required this.valorUnitario,
    required this.valorTotal,
    this.gtaDocumento,
    this.fazendaOrigem,
    this.fazendaDestino,
    this.animais = const [],
  });

  final int id;
  final int appFazendasId;
  final int appFazendasIdDest;
  final String data;
  final int statusTransferencia;
  final String statusString;
  final String valorUnitario;
  final String valorTotal;
  final String? gtaDocumento;
  final TransferenciaFazendaRef? fazendaOrigem;
  final TransferenciaFazendaRef? fazendaDestino;
  final List<TransferenciaFazendaAnimal> animais;

  bool get pendente => statusTransferencia == 2;

  int get qtdAnimais => animais.length;

  List<String> get brincos => animais
      .map((animal) => animal.brinco?.trim() ?? '')
      .where((brinco) => brinco.isNotEmpty)
      .toList(growable: false);
}
