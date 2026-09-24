import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_animal_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_destino_entity.dart';

class VendaEntity {
  const VendaEntity({
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
    this.comprador,
    this.idComprador,
    this.municipio,
    this.obs,
    this.dataCadastro,
    this.updateAt,
    this.animais = const [],
    this.destinos = const [],
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
  final String? comprador;
  final int? idComprador;
  final String? municipio;
  final String? obs;
  final String? dataCadastro;
  final String? updateAt;
  final List<VendaAnimalEntity> animais;
  final List<VendaDestinoEntity> destinos;
}
