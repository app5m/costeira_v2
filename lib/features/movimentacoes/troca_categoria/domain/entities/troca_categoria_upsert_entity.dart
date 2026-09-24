import 'package:costeira/features/movimentacoes/troca_categoria/domain/entities/troca_categoria_upsert_animal_entity.dart';

class TrocaCategoriaUpsertEntity {
  const TrocaCategoriaUpsertEntity({
    this.id,
    this.appUsersId,
    this.appFazendasId,
    required this.data,
    required this.catgDestino,
    required this.appPotreirosId,
    required this.appAnimaisLotesId,
    this.obs,
    this.animais = const [],
  });

  final int? id;
  final int? appUsersId;
  final int? appFazendasId;
  final String data;
  final int catgDestino;
  final int appPotreirosId;
  final int appAnimaisLotesId;
  final String? obs;
  final List<TrocaCategoriaUpsertAnimalEntity> animais;

  TrocaCategoriaUpsertEntity copyWith({
    int? id,
    int? appUsersId,
    int? appFazendasId,
    String? data,
    int? catgDestino,
    int? appPotreirosId,
    int? appAnimaisLotesId,
    String? obs,
    List<TrocaCategoriaUpsertAnimalEntity>? animais,
  }) {
    return TrocaCategoriaUpsertEntity(
      id: id ?? this.id,
      appUsersId: appUsersId ?? this.appUsersId,
      appFazendasId: appFazendasId ?? this.appFazendasId,
      data: data ?? this.data,
      catgDestino: catgDestino ?? this.catgDestino,
      appPotreirosId: appPotreirosId ?? this.appPotreirosId,
      appAnimaisLotesId: appAnimaisLotesId ?? this.appAnimaisLotesId,
      obs: obs ?? this.obs,
      animais: animais ?? this.animais,
    );
  }
}
