import 'package:costeira/features/movimentacoes/domain/entities/morte_animal_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_reference_entity.dart';

class MorteEntity {
  const MorteEntity({
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
    required this.animais,
    this.appPotreirosId,
    this.potreiro,
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
  final List<MorteAnimalEntity> animais;
  final int? appPotreirosId;
  final MovimentacaoReferenceEntity? potreiro;
}
