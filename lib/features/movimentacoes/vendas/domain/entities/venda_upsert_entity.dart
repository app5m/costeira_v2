import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_destino_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_upsert_animal_entity.dart';

class VendaUpsertEntity {
  const VendaUpsertEntity({
    this.id,
    this.appUsersId,
    required this.data,
    required this.valorUnitario,
    this.comprador,
    this.municipio,
    this.obs,
    this.animais = const [],
    required this.destinos,
  });

  final int? id;
  final int? appUsersId;
  final String data;
  final String valorUnitario;
  final String? comprador;
  final String? municipio;
  final String? obs;
  final List<VendaUpsertAnimalEntity> animais;
  final List<VendaDestinoEntity> destinos;

  VendaUpsertEntity copyWith({
    int? id,
    int? appUsersId,
    String? data,
    String? valorUnitario,
    String? comprador,
    String? municipio,
    String? obs,
    List<VendaUpsertAnimalEntity>? animais,
    List<VendaDestinoEntity>? destinos,
  }) {
    return VendaUpsertEntity(
      id: id ?? this.id,
      appUsersId: appUsersId ?? this.appUsersId,
      data: data ?? this.data,
      valorUnitario: valorUnitario ?? this.valorUnitario,
      comprador: comprador ?? this.comprador,
      municipio: municipio ?? this.municipio,
      obs: obs ?? this.obs,
      animais: animais ?? this.animais,
      destinos: destinos ?? this.destinos,
    );
  }
}
