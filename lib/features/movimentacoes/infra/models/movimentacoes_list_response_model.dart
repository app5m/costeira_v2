import 'package:costeira/features/movimentacoes/domain/entities/movimentacoes_list_entity.dart';
import 'package:costeira/features/movimentacoes/infra/models/compra_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/morte_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/nascimento_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/troca_categoria_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/venda_model.dart';

class MovimentacoesListResponseModel extends MovimentacoesListEntity {
  const MovimentacoesListResponseModel({
    required super.rows,
    required super.compras,
    super.vendas,
    super.mortes,
    super.nascimentos,
    super.trocaCategoria,
  });

  factory MovimentacoesListResponseModel.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    final compras = (data['compras'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => CompraModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
    final vendas = (data['vendas'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => VendaModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
    final mortes = (data['mortes'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => MorteModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
    final nascimentos = (data['nascimentos'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) => NascimentoModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
    final trocaCategoria =
        (data['troca_categoria'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map(
              (item) =>
                  TrocaCategoriaModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(growable: false);

    return MovimentacoesListResponseModel(
      rows:
          int.tryParse(json['rows']?.toString() ?? '') ?? trocaCategoria.length,
      compras: compras,
      vendas: vendas,
      mortes: mortes,
      nascimentos: nascimentos,
      trocaCategoria: trocaCategoria,
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
}
