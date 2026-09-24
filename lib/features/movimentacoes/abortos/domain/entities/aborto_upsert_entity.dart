import 'package:costeira/features/movimentacoes/abortos/domain/entities/aborto_upsert_animal_entity.dart';

class AbortoUpsertEntity {
  const AbortoUpsertEntity({
    this.id,
    this.appUsersId,
    this.appFazendasId,
    required this.appPotreirosId,
    required this.appAnimaisLotesId,
    required this.data,
    this.statusDestino = 'vazia',
    this.obs,
    this.animais = const [],
  });

  final int? id;
  final int? appUsersId;
  final int? appFazendasId;
  final int appPotreirosId;
  final int appAnimaisLotesId;
  final String data;
  final String statusDestino;
  final String? obs;
  final List<AbortoUpsertAnimalEntity> animais;

  AbortoUpsertEntity copyWith({
    int? id,
    int? appUsersId,
    int? appFazendasId,
    int? appPotreirosId,
    int? appAnimaisLotesId,
    String? data,
    String? statusDestino,
    String? obs,
    List<AbortoUpsertAnimalEntity>? animais,
  }) {
    return AbortoUpsertEntity(
      id: id ?? this.id,
      appUsersId: appUsersId ?? this.appUsersId,
      appFazendasId: appFazendasId ?? this.appFazendasId,
      appPotreirosId: appPotreirosId ?? this.appPotreirosId,
      appAnimaisLotesId: appAnimaisLotesId ?? this.appAnimaisLotesId,
      data: data ?? this.data,
      statusDestino: statusDestino ?? this.statusDestino,
      obs: obs ?? this.obs,
      animais: animais ?? this.animais,
    );
  }
}
