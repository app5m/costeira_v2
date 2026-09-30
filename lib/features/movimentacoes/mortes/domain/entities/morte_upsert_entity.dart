import 'package:costeira/features/movimentacoes/mortes/domain/entities/morte_upsert_animal_entity.dart';

class MorteUpsertEntity {
  const MorteUpsertEntity({
    this.id,
    this.appUsersId,
    this.appFazendasId,
    this.idCategoria,
    required this.data,
    this.obs,
    this.animais = const [],
  });

  final int? id;
  final int? appUsersId;
  final int? appFazendasId;
  final int? idCategoria;
  final String data;
  final String? obs;
  final List<MorteUpsertAnimalEntity> animais;

  MorteUpsertEntity copyWith({
    int? id,
    int? appUsersId,
    int? appFazendasId,
    int? idCategoria,
    String? data,
    String? obs,
    List<MorteUpsertAnimalEntity>? animais,
  }) {
    return MorteUpsertEntity(
      id: id ?? this.id,
      appUsersId: appUsersId ?? this.appUsersId,
      appFazendasId: appFazendasId ?? this.appFazendasId,
      idCategoria: idCategoria ?? this.idCategoria,
      data: data ?? this.data,
      obs: obs ?? this.obs,
      animais: animais ?? this.animais,
    );
  }
}
