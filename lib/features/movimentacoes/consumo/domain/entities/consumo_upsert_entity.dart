import 'package:costeira/features/movimentacoes/consumo/domain/entities/consumo_upsert_animal_entity.dart';

class ConsumoUpsertEntity {
  const ConsumoUpsertEntity({
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
  final List<ConsumoUpsertAnimalEntity> animais;

  ConsumoUpsertEntity copyWith({
    int? id,
    int? appUsersId,
    int? appFazendasId,
    String? data,
    String? obs,
    List<ConsumoUpsertAnimalEntity>? animais,
  }) {
    return ConsumoUpsertEntity(
      id: id ?? this.id,
      appUsersId: appUsersId ?? this.appUsersId,
      appFazendasId: appFazendasId ?? this.appFazendasId,
      data: data ?? this.data,
      obs: obs ?? this.obs,
      animais: animais ?? this.animais,
    );
  }
}
