import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_reference_entity.dart';

class TransferenciaEntity {
  const TransferenciaEntity({
    required this.id,
    required this.appUsersId,
    required this.appMovimentacoesCategoriasId,
    required this.data,
    required this.qtdAnimais,
    this.pesoMedio,
    this.pesoTotal,
    this.valorTotal,
    this.valorTotalRaw,
    this.valorUnitario,
    this.valorUnitarioRaw,
    this.municipio,
    this.obs,
    this.dataCadastro,
    this.updateAt,
    this.categoriaMovimentacao,
    this.potreiroDestino,
    this.loteDestino,
  });

  final int id;
  final int appUsersId;
  final int appMovimentacoesCategoriasId;
  final String data;
  final int qtdAnimais;
  final double? pesoMedio;
  final double? pesoTotal;
  final String? valorTotal;
  final double? valorTotalRaw;
  final String? valorUnitario;
  final double? valorUnitarioRaw;
  final String? municipio;
  final String? obs;
  final String? dataCadastro;
  final String? updateAt;
  final MovimentacaoReferenceEntity? categoriaMovimentacao;
  final MovimentacaoReferenceEntity? potreiroDestino;
  final MovimentacaoReferenceEntity? loteDestino;
}
