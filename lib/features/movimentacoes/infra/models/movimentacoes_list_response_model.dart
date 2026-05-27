import 'package:costeira/features/movimentacoes/domain/entities/movimentacoes_list_entity.dart';
import 'package:costeira/features/movimentacoes/infra/models/aborto_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/abigeato_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/compra_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/consumo_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/morte_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/nascimento_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/troca_categoria_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/transferencia_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/venda_model.dart';

class MovimentacoesListResponseModel extends MovimentacoesListEntity {
  const MovimentacoesListResponseModel({
    required super.rows,
    required super.compras,
    super.vendas,
    super.mortes,
    super.nascimentos,
    super.trocaCategoria,
    super.abigeatos,
    super.abortos,
    super.consumos,
    super.transferencias,
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
    final abigeatos = (data['abigeatos'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => AbigeatoModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
    final abortos = (data['abortos'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => AbortoModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
    final consumos = (data['consumos'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => ConsumoModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
    final transferencias =
        (data['transferencias'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map(
              (item) =>
                  TransferenciaModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(growable: false);

    return MovimentacoesListResponseModel(
      rows:
          int.tryParse(json['rows']?.toString() ?? '') ?? transferencias.length,
      compras: compras,
      vendas: vendas,
      mortes: mortes,
      nascimentos: nascimentos,
      trocaCategoria: trocaCategoria,
      abigeatos: abigeatos,
      abortos: abortos,
      consumos: consumos,
      transferencias: transferencias,
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
