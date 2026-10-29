import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';

class AnimalLotModel extends AnimalLotEntity {
  const AnimalLotModel({
    required super.id,
    required super.appUsersId,
    required super.nome,
    super.appPotreirosId,
    super.createAt,
    super.updateAt,
    super.animalsCount,
    super.sexo,
    super.categoriaNome,
    super.animalIds,
    super.temBrinco,
    super.idLocal,
    super.syncStatus,
    super.pendingAction,
    super.isLocalOnly = false,
  });

  factory AnimalLotModel.fromJson(Map<String, dynamic> json) {
    final mapas = _mapasDeAnimais(json['animais']);
    final sexos = <int>{};
    final categorias = <String>{};
    final ids = <int>[];
    for (final item in mapas) {
      final sexo = _sexoDeAnimal(item);
      if (sexo != null) {
        sexos.add(sexo);
      }
      final nome = _categoriaNomeDeAnimal(item);
      if (nome != null) {
        categorias.add(nome);
      }
      final id = int.tryParse(item['id']?.toString() ?? '');
      if (id != null) {
        ids.add(id);
      }
    }

    final categoriaNome = categorias.length == 1 ? categorias.first : null;
    final sexoDireto = _sexoValor(json['sexo']);
    // Só marca sexo exclusivo quando todos os animais têm o mesmo sexo.
    final sexoAnimais = sexos.length == 1 ? sexos.first : null;
    final sexoInferido = sexos.isEmpty
        ? (_sexoPorNomeCategoria(categoriaNome) ??
            _sexoPorNomeCategoria(json['nome']?.toString()))
        : null;
    final sexo = sexoDireto ?? sexoAnimais ?? sexoInferido;

    return AnimalLotModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      appUsersId: int.tryParse(json['app_users_id']?.toString() ?? '') ?? 0,
      nome: json['nome']?.toString() ?? '',
      appPotreirosId:
          int.tryParse(json['app_potreiros_id']?.toString() ?? '') ??
          int.tryParse(json['id_potreiro']?.toString() ?? ''),
      createAt: json['create_at']?.toString(),
      updateAt: json['update_at']?.toString(),
      animalsCount: mapas.length,
      sexo: sexo,
      categoriaNome: categoriaNome,
      animalIds: ids,
      temBrinco: mapas.any((item) {
        final brinco = item['brinco']?.toString().trim() ?? '';
        return brinco.isNotEmpty && brinco != 'null';
      }),
      idLocal: json['idLocal']?.toString(),
      syncStatus: json['syncStatus']?.toString(),
      pendingAction: json['pendingAction']?.toString(),
      isLocalOnly: json['isLocalOnly'] == true,
    );
  }
}

List<Map<String, dynamic>> _mapasDeAnimais(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return [
    for (final item in raw)
      if (item is Map) Map<String, dynamic>.from(item),
  ];
}

int? _sexoValor(dynamic raw) {
  if (raw is num) {
    final valor = raw.toInt();
    if (valor == 1 || valor == 2) {
      return valor;
    }
  }
  final textoBruto = raw?.toString().trim() ?? '';
  final valor = int.tryParse(textoBruto);
  if (valor == 1 || valor == 2) {
    return valor;
  }
  final texto = textoBruto.toLowerCase();
  if (texto.contains('fêmea') || texto.contains('femea') || texto == 'f') {
    return 2;
  }
  if (texto.contains('macho') || texto == 'm') {
    return 1;
  }
  return null;
}

int? _sexoDeAnimal(Map item) {
  final direto = _sexoValor(item['sexo']);
  if (direto != null) {
    return direto;
  }
  final categoria = item['categoria'];
  if (categoria is Map) {
    final daCategoria = _sexoValor(categoria['sexo']);
    if (daCategoria != null) {
      return daCategoria;
    }
    return _sexoPorNomeCategoria(categoria['nome']?.toString());
  }
  return _sexoPorNomeCategoria(_categoriaNomeDeAnimal(item));
}

String? _categoriaNomeDeAnimal(Map item) {
  final direto = item['categoria_nome']?.toString().trim() ?? '';
  if (direto.isNotEmpty && direto != 'null') {
    return direto;
  }
  final categoria = item['categoria'];
  if (categoria is Map) {
    final nome = categoria['nome']?.toString().trim() ?? '';
    if (nome.isNotEmpty && nome != 'null') {
      return nome;
    }
  }
  return null;
}

int? _sexoPorNomeCategoria(String? nome) {
  final texto = nome?.trim().toLowerCase() ?? '';
  if (texto.isEmpty) {
    return null;
  }
  const femeas = [
    'vaca',
    'vacas',
    'novilha',
    'novilhas',
    'terneira',
    'terneiras',
    'matriz',
    'matrizes',
    'fêmea',
    'femea',
    'fêmeas',
    'femeas',
  ];
  const machos = [
    'touro',
    'touros',
    'boi',
    'bois',
    'garrote',
    'garrotes',
    'bezerro',
    'bezerros',
    'macho',
    'machos',
  ];
  if (femeas.any(texto.contains)) {
    return 2;
  }
  if (machos.any(texto.contains)) {
    return 1;
  }
  return null;
}
