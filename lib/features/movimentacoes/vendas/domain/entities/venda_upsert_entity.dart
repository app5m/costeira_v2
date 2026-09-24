import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_upsert_animal_entity.dart';

class VendaUpsertEntity {
  const VendaUpsertEntity({
    this.id,
    this.appUsersId,
    required this.appFazendasId,
    required this.data,
    required this.tipoCompra,
    required this.tipoCadastro,
    required this.valorUnitario,
    this.valorFrete,
    this.valorComissao,
    required this.idComprador,
    this.obs,
    this.animais = const [],
  });

  final int? id;
  final int? appUsersId;
  final int appFazendasId;
  final String data;
  final String tipoCompra;
  final String tipoCadastro;
  final String valorUnitario;
  final String? valorFrete;
  final String? valorComissao;
  final int idComprador;
  final String? obs;
  final List<VendaUpsertAnimalEntity> animais;

  bool get isIndividual => tipoCadastro == 'individual';

  VendaUpsertEntity copyWith({
    int? id,
    int? appUsersId,
    int? appFazendasId,
    String? data,
    String? tipoCompra,
    String? tipoCadastro,
    String? valorUnitario,
    String? valorFrete,
    String? valorComissao,
    int? idComprador,
    String? obs,
    List<VendaUpsertAnimalEntity>? animais,
  }) {
    return VendaUpsertEntity(
      id: id ?? this.id,
      appUsersId: appUsersId ?? this.appUsersId,
      appFazendasId: appFazendasId ?? this.appFazendasId,
      data: data ?? this.data,
      tipoCompra: tipoCompra ?? this.tipoCompra,
      tipoCadastro: tipoCadastro ?? this.tipoCadastro,
      valorUnitario: valorUnitario ?? this.valorUnitario,
      valorFrete: valorFrete ?? this.valorFrete,
      valorComissao: valorComissao ?? this.valorComissao,
      idComprador: idComprador ?? this.idComprador,
      obs: obs ?? this.obs,
      animais: animais ?? this.animais,
    );
  }
}
