class ManejoAnimalCategoria {
  const ManejoAnimalCategoria(this.id, this.nome);

  final int id;
  final String nome;

  static const lista = <ManejoAnimalCategoria>[
    ManejoAnimalCategoria(1, 'Pesagem'),
    ManejoAnimalCategoria(2, 'Sanitário'),
    ManejoAnimalCategoria(3, 'Nutrição'),
    ManejoAnimalCategoria(4, 'Veterinário'),
    ManejoAnimalCategoria(5, 'Identificação'),
    ManejoAnimalCategoria(6, 'Categoria'),
    ManejoAnimalCategoria(7, 'Piquete'),
  ];

  static const reprodutivo = <ManejoAnimalCategoria>[
    ManejoAnimalCategoria(8, 'Entrada'),
    ManejoAnimalCategoria(9, 'Retirada'),
    ManejoAnimalCategoria(10, 'IATF'),
    ManejoAnimalCategoria(11, 'Diagnóstico'),
    ManejoAnimalCategoria(13, 'Aborto'),
  ];

  static String nomeDe(int? id) {
    return [...lista, ...reprodutivo]
            .where((item) => item.id == id)
            .map((item) => item.nome)
            .firstOrNull ??
        'Manejo';
  }
}

class ManejoAnimalListaItem {
  const ManejoAnimalListaItem({
    required this.id,
    required this.idCategoria,
    required this.data,
    required this.detalhe,
    this.lote = '',
    this.duracao = '',
    this.brinco = '',
  });

  final int? id;
  final int? idCategoria;
  final String data;
  final String detalhe;
  final String lote;
  final String duracao;
  final String brinco;
}

class ManejoAnimalListaEntity {
  const ManejoAnimalListaEntity({required this.itens});

  final List<ManejoAnimalListaItem> itens;
}
