import 'package:costeira/features/movimentacoes/consumo/domain/entities/consumo_upsert_animal_entity.dart';

class ConsumoUpsertEntity {
  const ConsumoUpsertEntity({
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
  final List<ConsumoUpsertAnimalEntity> animais;

  ConsumoUpsertEntity copyWith({
    int? id,
    int? appUsersId,
    String? data,
    String? obs,
    List<ConsumoUpsertAnimalEntity>? animais,
  }) {
    return ConsumoUpsertEntity(
      id: id ?? this.id,
      appUsersId: appUsersId ?? this.appUsersId,
      data: data ?? this.data,
      obs: obs ?? this.obs,
      animais: animais ?? this.animais,
    );
  }
}
