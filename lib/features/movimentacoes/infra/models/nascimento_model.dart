import 'package:costeira/features/movimentacoes/domain/entities/nascimento_entity.dart';
import 'package:costeira/features/movimentacoes/infra/models/movimentacao_reference_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/nascimento_animal_model.dart';

class NascimentoModel extends NascimentoEntity {
  const NascimentoModel({
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
    super.municipio,
    super.obs,
    super.dataCadastro,
    super.updateAt,
    super.categoriaMovimentacao,
    required super.animais,
    super.appPotreirosId,
    super.appAnimaisLotesId,
    super.potreiro,
    super.lote,
  });

  factory NascimentoModel.fromJson(Map<String, dynamic> json) {
    final animais = (json['animais'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) =>
              NascimentoAnimalModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);

    return NascimentoModel(
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
      municipio: json['municipio']?.toString(),
      obs: json['obs']?.toString(),
      dataCadastro: json['data_cadastro']?.toString(),
      updateAt: json['update_at']?.toString(),
      categoriaMovimentacao: MovimentacaoReferenceModel.maybeFromJson(
        json['categoria_movimentacao'],
      ),
      animais: animais,
      appPotreirosId: int.tryParse(json['app_potreiros_id']?.toString() ?? ''),
      appAnimaisLotesId: int.tryParse(
        json['app_animais_lotes_id']?.toString() ?? '',
      ),
      potreiro: MovimentacaoReferenceModel.maybeFromJson(json['potreiro']),
      lote: MovimentacaoReferenceModel.maybeFromJson(json['lote']),
    );
  }

  static double? _toDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '');
  }
}
