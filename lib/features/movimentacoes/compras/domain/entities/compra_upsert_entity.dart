import 'package:costeira/features/movimentacoes/compras/domain/entities/compra_upsert_animal_entity.dart';

class CompraUpsertEntity {
  const CompraUpsertEntity({
    this.id,
    this.appUsersId,
    required this.appPotreirosId,
    required this.appAnimaisLotesId,
    required this.data,
    required this.tipoCompra,
    required this.valorUnitario,
    this.fornecedor,
    this.municipio,
    this.obs,
    this.animais = const [],
  });

  final int? id;
  final int? appUsersId;
  final int appPotreirosId;
  final int appAnimaisLotesId;
  final String data;
  final String tipoCompra;
  final String valorUnitario;
  final String? fornecedor;
  final String? municipio;
  final String? obs;
  final List<CompraUpsertAnimalEntity> animais;

  CompraUpsertEntity copyWith({
    int? id,
    int? appUsersId,
    int? appPotreirosId,
    int? appAnimaisLotesId,
    String? data,
    String? tipoCompra,
    String? valorUnitario,
    String? fornecedor,
    String? municipio,
    String? obs,
    List<CompraUpsertAnimalEntity>? animais,
  }) {
    return CompraUpsertEntity(
      id: id ?? this.id,
      appUsersId: appUsersId ?? this.appUsersId,
      appPotreirosId: appPotreirosId ?? this.appPotreirosId,
      appAnimaisLotesId: appAnimaisLotesId ?? this.appAnimaisLotesId,
      data: data ?? this.data,
      tipoCompra: tipoCompra ?? this.tipoCompra,
      valorUnitario: valorUnitario ?? this.valorUnitario,
      fornecedor: fornecedor ?? this.fornecedor,
      municipio: municipio ?? this.municipio,
      obs: obs ?? this.obs,
      animais: animais ?? this.animais,
    );
  }
}
