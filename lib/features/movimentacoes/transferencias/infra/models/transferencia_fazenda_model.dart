import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_fazenda_list_item.dart';

class TransferenciaFazendaModel extends TransferenciaFazendaListItem {
  const TransferenciaFazendaModel({
    required super.id,
    required super.appFazendasId,
    required super.appFazendasIdDest,
    required super.data,
    required super.statusTransferencia,
    required super.statusString,
    required super.valorUnitario,
    required super.valorTotal,
    super.gtaDocumento,
    super.fazendaOrigem,
    super.fazendaDestino,
    super.animais,
  });

  factory TransferenciaFazendaModel.fromJson(Map<String, dynamic> json) {
    final animais = <TransferenciaFazendaAnimal>[];
    final rawAnimais = json['animais'];
    if (rawAnimais is List) {
      for (final item in rawAnimais.whereType<Map>()) {
        final map = Map<String, dynamic>.from(item);
        final animalId = int.tryParse(
          (map['app_animais_id'] ?? map['id'])?.toString() ?? '',
        );
        if (animalId == null) {
          continue;
        }
        animais.add(
          TransferenciaFazendaAnimal(
            appAnimaisId: animalId,
            brinco: _emptyToNull(map['brinco']),
            categoria: _nestedNome(map['categoria']),
            fase: _nestedNome(map['subcategoria']),
            lote: _nestedNome(map['lote']),
            piquete: _nestedNome(map['potreiro']),
            peso: double.tryParse(map['peso_total']?.toString() ?? ''),
          ),
        );
      }
    }

    return TransferenciaFazendaModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      appFazendasId:
          int.tryParse(json['app_fazendas_id']?.toString() ?? '') ?? 0,
      appFazendasIdDest:
          int.tryParse(json['app_fazendas_id_dest']?.toString() ?? '') ?? 0,
      data: json['data']?.toString() ?? '',
      gtaDocumento: _emptyToNull(json['gta_documento']),
      statusTransferencia:
          int.tryParse(json['status_transferencia']?.toString() ?? '') ?? 0,
      statusString: json['status_string']?.toString().trim().isNotEmpty == true
          ? json['status_string'].toString().trim()
          : _statusFallback(
              int.tryParse(json['status_transferencia']?.toString() ?? ''),
            ),
      valorUnitario: _money(
        json['valor_unitario_string'] ?? json['valor_unitario'],
      ),
      valorTotal: _money(json['valor_total_string'] ?? json['valor_total']),
      fazendaOrigem: _farm(json['fazenda_origem']),
      fazendaDestino: _farm(json['fazenda_destino']),
      animais: animais,
    );
  }

  static TransferenciaFazendaRef? _farm(dynamic raw) {
    if (raw is! Map) {
      return null;
    }
    final map = Map<String, dynamic>.from(raw);
    final id = int.tryParse(map['id']?.toString() ?? '');
    if (id == null) {
      return null;
    }
    return TransferenciaFazendaRef(
      id: id,
      nome: map['nome']?.toString() ?? '',
      cnpj: map['cnpj']?.toString() ?? '',
    );
  }

  static String _money(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? 'R\$ 0,00' : text;
  }

  static String? _nestedNome(dynamic raw) {
    if (raw is! Map) {
      return null;
    }
    return _emptyToNull(raw['nome']);
  }

  static String? _emptyToNull(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  static String _statusFallback(int? status) {
    return switch (status) {
      1 => 'Aprovado',
      2 => 'Pendente',
      3 => 'Recusado',
      _ => 'Sem status',
    };
  }
}
