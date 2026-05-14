import 'package:costeira/features/movimentacoes/nascimento/domain/entities/nascimento_upsert_animal_entity.dart';

class NascimentoUpsertEntity {
  const NascimentoUpsertEntity({
    this.id,
    this.appUsersId,
    required this.appPotreirosId,
    required this.appAnimaisLotesId,
    required this.data,
    this.pesoTotal,
    this.obs,
    this.animais = const [],
  });

  final int? id;
  final int? appUsersId;
  final int appPotreirosId;
  final int appAnimaisLotesId;
  final String data;
  final String? pesoTotal;
  final String? obs;
  final List<NascimentoUpsertAnimalEntity> animais;

  NascimentoUpsertEntity copyWith({
    int? id,
    int? appUsersId,
    int? appPotreirosId,
    int? appAnimaisLotesId,
    String? data,
    String? pesoTotal,
    String? obs,
    List<NascimentoUpsertAnimalEntity>? animais,
  }) {
    return NascimentoUpsertEntity(
      id: id ?? this.id,
      appUsersId: appUsersId ?? this.appUsersId,
      appPotreirosId: appPotreirosId ?? this.appPotreirosId,
      appAnimaisLotesId: appAnimaisLotesId ?? this.appAnimaisLotesId,
      data: data ?? this.data,
      pesoTotal: pesoTotal ?? this.pesoTotal,
      obs: obs ?? this.obs,
      animais: animais ?? this.animais,
    );
  }
}
