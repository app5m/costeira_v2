import 'package:costeira/features/movimentacoes/abigeatos/domain/entities/abigeato_upsert_animal_entity.dart';

class AbigeatoUpsertEntity {
  const AbigeatoUpsertEntity({
    this.id,
    this.appUsersId,
    required this.data,
    this.obs,
    this.animais = const [],
  });

  final int? id;
  final int? appUsersId;
  final String data;
  final String? obs;
  final List<AbigeatoUpsertAnimalEntity> animais;

  AbigeatoUpsertEntity copyWith({
    int? id,
    int? appUsersId,
    String? data,
    String? obs,
    List<AbigeatoUpsertAnimalEntity>? animais,
  }) {
    return AbigeatoUpsertEntity(
      id: id ?? this.id,
      appUsersId: appUsersId ?? this.appUsersId,
      data: data ?? this.data,
      obs: obs ?? this.obs,
      animais: animais ?? this.animais,
    );
  }
}
