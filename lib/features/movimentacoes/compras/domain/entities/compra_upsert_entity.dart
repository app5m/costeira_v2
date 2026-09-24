import 'package:costeira/features/movimentacoes/compras/domain/entities/compra_upsert_animal_entity.dart';

class CompraUpsertEntity {
  const CompraUpsertEntity({
    this.id,
    this.appUsersId,
    required this.appFazendasId,
    required this.appPotreirosId,
    required this.appAnimaisLotesId,
    required this.data,
    required this.sexo,
    required this.appAnimaisCategoriasId,
    this.appAnimaisSubcategoriasId,
    this.utBasesRaciaisId,
    required this.tipoCompra,
    required this.tipoCadastro,
    required this.valorUnitario,
    this.valorFrete,
    this.valorComissao,
    required this.idFornecedor,
    this.obs,
    this.qtdAnimais,
    this.pesoTotal,
    this.pesoMedio,
    this.animais = const [],
  });

  final int? id;
  final int? appUsersId;
  final int appFazendasId;
  final int appPotreirosId;
  final int appAnimaisLotesId;
  final String data;
  final int sexo;
  final int appAnimaisCategoriasId;
  final int? appAnimaisSubcategoriasId;
  final int? utBasesRaciaisId;
  final String tipoCompra;
  final String tipoCadastro;
  final String valorUnitario;
  final String? valorFrete;
  final String? valorComissao;
  final int idFornecedor;
  final String? obs;
  final int? qtdAnimais;
  final String? pesoTotal;
  final String? pesoMedio;
  final List<CompraUpsertAnimalEntity> animais;

  bool get isIndividual => tipoCadastro == 'individual';

  CompraUpsertEntity copyWith({
    int? id,
    int? appUsersId,
    int? appFazendasId,
    int? appPotreirosId,
    int? appAnimaisLotesId,
    String? data,
    int? sexo,
    int? appAnimaisCategoriasId,
    int? appAnimaisSubcategoriasId,
    int? utBasesRaciaisId,
    String? tipoCompra,
    String? tipoCadastro,
    String? valorUnitario,
    String? valorFrete,
    String? valorComissao,
    int? idFornecedor,
    String? obs,
    int? qtdAnimais,
    String? pesoTotal,
    String? pesoMedio,
    List<CompraUpsertAnimalEntity>? animais,
  }) {
    return CompraUpsertEntity(
      id: id ?? this.id,
      appUsersId: appUsersId ?? this.appUsersId,
      appFazendasId: appFazendasId ?? this.appFazendasId,
      appPotreirosId: appPotreirosId ?? this.appPotreirosId,
      appAnimaisLotesId: appAnimaisLotesId ?? this.appAnimaisLotesId,
      data: data ?? this.data,
      sexo: sexo ?? this.sexo,
      appAnimaisCategoriasId:
          appAnimaisCategoriasId ?? this.appAnimaisCategoriasId,
      appAnimaisSubcategoriasId:
          appAnimaisSubcategoriasId ?? this.appAnimaisSubcategoriasId,
      utBasesRaciaisId: utBasesRaciaisId ?? this.utBasesRaciaisId,
      tipoCompra: tipoCompra ?? this.tipoCompra,
      tipoCadastro: tipoCadastro ?? this.tipoCadastro,
      valorUnitario: valorUnitario ?? this.valorUnitario,
      valorFrete: valorFrete ?? this.valorFrete,
      valorComissao: valorComissao ?? this.valorComissao,
      idFornecedor: idFornecedor ?? this.idFornecedor,
      obs: obs ?? this.obs,
      qtdAnimais: qtdAnimais ?? this.qtdAnimais,
      pesoTotal: pesoTotal ?? this.pesoTotal,
      pesoMedio: pesoMedio ?? this.pesoMedio,
      animais: animais ?? this.animais,
    );
  }
}
