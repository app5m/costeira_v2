import 'package:costeira/features/movimentacoes/domain/entities/compra_animal_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_reference_entity.dart';

class CompraEntity {
  const CompraEntity({
    required this.id,
    required this.appUsersId,
    required this.appMovimentacoesCategoriasId,
    required this.data,
    required this.qtdAnimais,
    this.appFazendasId,
    this.pesoMedio,
    this.pesoTotal,
    this.valorTotal,
    this.valorTotalRaw,
    this.valorUnitario,
    this.valorUnitarioRaw,
    this.valorFrete,
    this.valorComissao,
    this.municipio,
    this.obs,
    this.dataCadastro,
    this.updateAt,
    this.categoriaMovimentacao,
    required this.animais,
    this.tipoCompra,
    this.fornecedor,
    this.idFornecedor,
    this.appPotreirosId,
    this.appAnimaisLotesId,
    this.potreiro,
    this.lote,
  });

  final int id;
  final int appUsersId;
  final int appMovimentacoesCategoriasId;
  final String data;
  final int qtdAnimais;
  final int? appFazendasId;
  final double? pesoMedio;
  final double? pesoTotal;
  final String? valorTotal;
  final double? valorTotalRaw;
  final String? valorUnitario;
  final double? valorUnitarioRaw;
  final String? valorFrete;
  final String? valorComissao;
  final String? municipio;
  final String? obs;
  final String? dataCadastro;
  final String? updateAt;
  final MovimentacaoReferenceEntity? categoriaMovimentacao;
  final List<CompraAnimalEntity> animais;
  final String? tipoCompra;
  final String? fornecedor;
  final int? idFornecedor;
  final int? appPotreirosId;
  final int? appAnimaisLotesId;
  final MovimentacaoReferenceEntity? potreiro;
  final MovimentacaoReferenceEntity? lote;
}
