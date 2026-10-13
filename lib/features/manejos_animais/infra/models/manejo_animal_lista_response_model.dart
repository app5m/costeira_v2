import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/features/manejos_animais/domain/entities/manejo_animal_lista.dart';

class ManejoAnimalListaResponseModel extends ManejoAnimalListaEntity {
  const ManejoAnimalListaResponseModel({required super.itens});

  factory ManejoAnimalListaResponseModel.fromResponse(dynamic response) {
    final envelopes = responseAsList(response);
    if (envelopes.isEmpty) {
      return const ManejoAnimalListaResponseModel(itens: []);
    }
    final first = envelopes.first;
    final status = first['status']?.toString();
    if (status == '02') {
      throw ApiException(first['msg']?.toString() ?? 'Nao foi possivel listar os manejos.');
    }
    return ManejoAnimalListaResponseModel(
      itens: [
        for (final item in _itens(first)) ManejoAnimalListaItemModel.fromJson(item),
      ],
    );
  }
}

class ManejoAnimalListaItemModel extends ManejoAnimalListaItem {
  const ManejoAnimalListaItemModel({
    required super.id,
    required super.idCategoria,
    required super.data,
    required super.detalhe,
    super.lote,
    super.duracao,
    super.brinco,
  });

  factory ManejoAnimalListaItemModel.fromJson(Map<String, dynamic> json) {
    return ManejoAnimalListaItemModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      idCategoria: int.tryParse(json['id_categoria']?.toString() ?? ''),
      data: _data(json),
      detalhe: _detalhe(json),
      lote: _lote(json),
      duracao: _duracao(json),
      brinco: _brinco(json),
    );
  }
}

List<Map<String, dynamic>> _itens(Map<String, dynamic> envelope) {
  final data = envelope['data'];
  if (data is List) {
    final maps = data.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    if (maps.length == 1 && maps.first['lista'] is List) {
      return _maps(maps.first['lista']);
    }
    return maps;
  }
  if (data is Map) {
    final map = Map<String, dynamic>.from(data);
    if (map['lista'] is List) {
      return _maps(map['lista']);
    }
  }
  if (envelope.containsKey('id_categoria') || envelope.containsKey('id')) {
    return [envelope];
  }
  return const [];
}

List<Map<String, dynamic>> _maps(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
}

String _data(Map<String, dynamic> json) {
  final data = json['data']?.toString().trim() ?? '';
  if (data.isNotEmpty) {
    return data;
  }
  return json['create_at']?.toString().trim() ?? '';
}

String _detalhe(Map<String, dynamic> json) {
  final partes = <String>[];
  final animais = json['animais'];
  if (animais is List && animais.isNotEmpty) {
    partes.add('${animais.length} animal(is)');
  }
  final novoBrinco = json['novo_brinco']?.toString().trim() ?? '';
  if (novoBrinco.isNotEmpty) {
    partes.add('Brinco $novoBrinco');
  }
  final dosagem = json['dosagem']?.toString().trim() ?? '';
  if (dosagem.isNotEmpty && dosagem != 'null') {
    partes.add('Dosagem $dosagem');
  }
  final lote = _lote(json);
  if (lote.isNotEmpty) {
    partes.add(lote);
  }
  final duracao = _duracao(json);
  if (duracao.isNotEmpty) {
    partes.add('$duracao dias');
  }
  final brincoAnimal = _brinco(json);
  if (brincoAnimal.isNotEmpty && brincoAnimal != novoBrinco) {
    partes.add('Brinco $brincoAnimal');
  }
  final motivo = json['motivo']?.toString().trim() ?? '';
  if (motivo.isNotEmpty && motivo != 'null') {
    partes.add(motivo);
  }
  final obs = json['obs']?.toString().trim() ?? '';
  if (obs.isNotEmpty && obs != 'null') {
    partes.add(obs);
  }
  return partes.join(' · ');
}

String _lote(Map<String, dynamic> json) {
  final direto = _texto(json, ['lote_nome', 'nome_lote', 'app_animais_lotes_nome']);
  if (direto.isNotEmpty) {
    return direto;
  }
  final lote = json['lote'];
  if (lote is Map) {
    return lote['nome']?.toString().trim() ?? '';
  }
  if (lote is String) {
    final nome = lote.trim();
    return nome == 'null' ? '' : nome;
  }
  return '';
}

String _duracao(Map<String, dynamic> json) {
  return _texto(json, ['duracao_estacao', 'duracao']);
}

String _brinco(Map<String, dynamic> json) {
  final direto = _texto(json, ['brinco', 'brinco_touro', 'touro_brinco']);
  if (direto.isNotEmpty) {
    return direto;
  }
  final animais = json['animais'];
  if (animais is! List) {
    return '';
  }
  for (final item in animais.whereType<Map>()) {
    final brinco = item['brinco']?.toString().trim() ?? '';
    if (brinco.isNotEmpty && brinco != 'null') {
      return brinco;
    }
  }
  return '';
}

String _texto(Map<String, dynamic> json, List<String> chaves) {
  for (final chave in chaves) {
    final valor = json[chave]?.toString().trim() ?? '';
    if (valor.isNotEmpty && valor != 'null') {
      return valor;
    }
  }
  return '';
}
