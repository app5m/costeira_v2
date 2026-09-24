import 'package:costeira/features/movimentacoes/abigeatos/domain/entities/abigeato_upsert_animal_entity.dart';

class AbigeatoUpsertEntity {
  const AbigeatoUpsertEntity({
    this.id,
    this.appUsersId,
    this.appFazendasId,
    required this.data,
    this.obs,
    this.animais = const [],
  });

  final int? id;
  final int? appUsersId;
  final int? appFazendasId;
  final String data;
  final String? obs;
  final List<AbigeatoUpsertAnimalEntity> animais;

  AbigeatoUpsertEntity copyWith({
    int? id,
    int? appUsersId,
    int? appFazendasId,
    String? data,
    String? obs,
    List<AbigeatoUpsertAnimalEntity>? animais,
  }) {
    return AbigeatoUpsertEntity(
      id: id ?? this.id,
      appUsersId: appUsersId ?? this.appUsersId,
      appFazendasId: appFazendasId ?? this.appFazendasId,
      data: data ?? this.data,
      obs: obs ?? this.obs,
      animais: animais ?? this.animais,
    );
  }
}
