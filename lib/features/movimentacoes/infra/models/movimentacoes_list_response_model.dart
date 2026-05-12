import 'package:costeira/features/movimentacoes/domain/entities/movimentacoes_list_entity.dart';
import 'package:costeira/features/movimentacoes/infra/models/compra_model.dart';

class MovimentacoesListResponseModel extends MovimentacoesListEntity {
  const MovimentacoesListResponseModel({
    required super.rows,
    required super.compras,
    super.vendas,
    super.mortes,
  });

  factory MovimentacoesListResponseModel.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    final compras = (data['compras'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => CompraModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);

    return MovimentacoesListResponseModel(
      rows: int.tryParse(json['rows']?.toString() ?? '') ?? compras.length,
      compras: compras,
      vendas: _asList(data['vendas']),
      mortes: _asList(data['mortes']),
    );
  }

  static Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return <String, dynamic>{};
  }

  static List<dynamic> _asList(dynamic raw) {
    if (raw is List) {
      return raw;
    }
    return const [];
  }
}
