import 'package:costeira/features/movimentacoes/nascimento/domain/entities/nascimento_upsert_animal_entity.dart';

class NascimentoUpsertEntity {
  const NascimentoUpsertEntity({
    this.id,
    this.appUsersId,
    this.appFazendasId,
    this.appPotreirosId,
    this.appAnimaisLotesId,
    required this.data,
    this.pesoTotal,
    this.obs,
    this.sexo,
    this.idAnimalMae,
    this.brincoCria,
    this.animais = const [],
  });

  final int? id;
  final int? appUsersId;
  final int? appFazendasId;
  final int? appPotreirosId;
  final int? appAnimaisLotesId;
  final String data;
  final String? pesoTotal;
  final String? obs;
  final int? sexo;
  final int? idAnimalMae;
  final String? brincoCria;
  final List<NascimentoUpsertAnimalEntity> animais;

  NascimentoUpsertEntity copyWith({
    int? id,
    int? appUsersId,
    int? appFazendasId,
    int? appPotreirosId,
    int? appAnimaisLotesId,
    String? data,
    String? pesoTotal,
    String? obs,
    int? sexo,
    int? idAnimalMae,
    String? brincoCria,
    List<NascimentoUpsertAnimalEntity>? animais,
  }) {
    return NascimentoUpsertEntity(
      id: id ?? this.id,
      appUsersId: appUsersId ?? this.appUsersId,
      appFazendasId: appFazendasId ?? this.appFazendasId,
      appPotreirosId: appPotreirosId ?? this.appPotreirosId,
      appAnimaisLotesId: appAnimaisLotesId ?? this.appAnimaisLotesId,
      data: data ?? this.data,
      pesoTotal: pesoTotal ?? this.pesoTotal,
      obs: obs ?? this.obs,
      sexo: sexo ?? this.sexo,
      idAnimalMae: idAnimalMae ?? this.idAnimalMae,
      brincoCria: brincoCria ?? this.brincoCria,
      animais: animais ?? this.animais,
    );
  }
}
