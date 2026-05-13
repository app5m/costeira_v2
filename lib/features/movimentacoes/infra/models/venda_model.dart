import 'package:costeira/features/movimentacoes/infra/models/venda_animal_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/venda_destino_model.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_entity.dart';

class VendaModel extends VendaEntity {
  const VendaModel({
    required super.id,
    required super.appUsersId,
    required super.appMovimentacoesCategoriasId,
    required super.data,
    required super.qtdAnimais,
    super.pesoMedio,
    super.pesoTotal,
    super.valorTotal,
    super.valorTotalRaw,
    super.valorUnitario,
    super.valorUnitarioRaw,
    super.comprador,
    super.municipio,
    super.obs,
    super.dataCadastro,
    super.updateAt,
    super.animais,
    super.destinos,
  });

  factory VendaModel.fromJson(Map<String, dynamic> json) {
    final animais = (json['animais'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) => VendaAnimalModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
    final destinos = (json['destinos'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) => VendaDestinoModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);

    return VendaModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      appUsersId: int.tryParse(json['app_users_id']?.toString() ?? '') ?? 0,
      appMovimentacoesCategoriasId:
          int.tryParse(
            json['app_movimentacoes_categorias_id']?.toString() ?? '',
          ) ??
          0,
      data: json['data']?.toString() ?? '',
      qtdAnimais: int.tryParse(json['qtd_animais']?.toString() ?? '') ?? 0,
      pesoMedio: _toDouble(json['peso_medio']),
      pesoTotal: _toDouble(json['peso_total']),
      valorTotal: json['valor_total']?.toString(),
      valorTotalRaw: _toDouble(json['valor_total_raw']),
      valorUnitario: json['valor_unitario']?.toString(),
      valorUnitarioRaw: _toDouble(json['valor_unitario_raw']),
      comprador: json['comprador']?.toString(),
      municipio: json['municipio']?.toString(),
      obs: json['obs']?.toString(),
      dataCadastro: json['data_cadastro']?.toString(),
      updateAt: json['update_at']?.toString(),
      animais: animais,
      destinos: destinos,
    );
  }

  static double? _toDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '');
  }
}
