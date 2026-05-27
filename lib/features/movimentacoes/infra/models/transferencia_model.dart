import 'package:costeira/features/movimentacoes/domain/entities/transferencia_entity.dart';
import 'package:costeira/features/movimentacoes/infra/models/movimentacao_reference_model.dart';

class TransferenciaModel extends TransferenciaEntity {
  const TransferenciaModel({
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
    super.potreiroDestino,
    super.loteDestino,
  });

  factory TransferenciaModel.fromJson(Map<String, dynamic> json) {
    return TransferenciaModel(
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
      potreiroDestino: MovimentacaoReferenceModel.maybeFromJson(
        json['potreiro_destino'],
      ),
      loteDestino: MovimentacaoReferenceModel.maybeFromJson(
        json['lote_destino'],
      ),
    );
  }

  static double? _toDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '');
  }
}
