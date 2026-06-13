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
import 'package:costeira/core/utils/app_logger.dart';

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
    final compras = _parseList(
      data['compras'],
      'compras',
      CompraModel.fromJson,
    );
    final vendas = _parseList(data['vendas'], 'vendas', VendaModel.fromJson);
    final mortes = _parseList(data['mortes'], 'mortes', MorteModel.fromJson);
    final nascimentos = _parseList(
      data['nascimentos'],
      'nascimentos',
      NascimentoModel.fromJson,
    );
    final trocaCategoria = _parseList(
      data['troca_categoria'],
      'troca_categoria',
      TrocaCategoriaModel.fromJson,
    );
    final abigeatos = _parseList(
      data['abigeatos'],
      'abigeatos',
      AbigeatoModel.fromJson,
    );
    final abortos = _parseList(
      data['abortos'],
      'abortos',
      AbortoModel.fromJson,
    );
    final consumos = _parseList(
      data['consumos'],
      'consumos',
      ConsumoModel.fromJson,
    );
    final transferencias = _parseList(
      data['transferencias'],
      'transferencias',
      TransferenciaModel.fromJson,
    );

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

  static List<T> _parseList<T>(
    dynamic raw,
    String field,
    T Function(Map<String, dynamic> json) parser,
  ) {
    if (raw is! List) {
      return <T>[];
    }

    final items = <T>[];
    for (final item in raw.whereType<Map>()) {
      try {
        items.add(parser(Map<String, dynamic>.from(item)));
      } catch (error, stackTrace) {
        AppLogger.error(
          'MOVIMENTACOES LIST RESPONSE: ERRO AO PARSEAR $field ITEM=$item ERROR=$error STACK=$stackTrace',
        );
      }
    }
    return items;
  }
}
