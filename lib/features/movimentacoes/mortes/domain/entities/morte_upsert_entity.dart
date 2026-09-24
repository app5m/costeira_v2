import 'package:costeira/features/movimentacoes/mortes/domain/entities/morte_upsert_animal_entity.dart';

class MorteUpsertEntity {
  const MorteUpsertEntity({
    this.id,
    this.appUsersId,
    this.appFazendasId,
    required this.appPotreirosId,
    required this.data,
    this.animais = const [],
  });

  final int? id;
  final int? appUsersId;
  final int? appFazendasId;
  final int appPotreirosId;
  final String data;
  final List<MorteUpsertAnimalEntity> animais;

  MorteUpsertEntity copyWith({
    int? id,
    int? appUsersId,
    int? appFazendasId,
    int? appPotreirosId,
    String? data,
    List<MorteUpsertAnimalEntity>? animais,
  }) {
    return MorteUpsertEntity(
      id: id ?? this.id,
      appUsersId: appUsersId ?? this.appUsersId,
      appFazendasId: appFazendasId ?? this.appFazendasId,
      appPotreirosId: appPotreirosId ?? this.appPotreirosId,
      data: data ?? this.data,
      animais: animais ?? this.animais,
    );
  }
}
