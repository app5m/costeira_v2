import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_upsert_lote_entity.dart';

class TransferenciaUpsertEntity {
  const TransferenciaUpsertEntity({
    this.id,
    this.appUsersId,
    this.appFazendasId,
    required this.data,
    required this.tipo,
    required this.potreiroDestino,
    this.loteDestino,
    this.obs,
    this.animais = const [],
    this.lotes = const [],
  });

  final int? id;
  final int? appUsersId;
  final int? appFazendasId;
  final String data;
  final String tipo;
  final int potreiroDestino;
  final int? loteDestino;
  final String? obs;
  final List<TransferenciaUpsertAnimalEntity> animais;
  final List<TransferenciaUpsertLoteEntity> lotes;

  TransferenciaUpsertEntity copyWith({
    int? id,
    int? appUsersId,
    int? appFazendasId,
    String? data,
    String? tipo,
    int? potreiroDestino,
    int? loteDestino,
    String? obs,
    List<TransferenciaUpsertAnimalEntity>? animais,
    List<TransferenciaUpsertLoteEntity>? lotes,
  }) {
    return TransferenciaUpsertEntity(
      id: id ?? this.id,
      appUsersId: appUsersId ?? this.appUsersId,
      appFazendasId: appFazendasId ?? this.appFazendasId,
      data: data ?? this.data,
      tipo: tipo ?? this.tipo,
      potreiroDestino: potreiroDestino ?? this.potreiroDestino,
      loteDestino: loteDestino ?? this.loteDestino,
      obs: obs ?? this.obs,
      animais: animais ?? this.animais,
      lotes: lotes ?? this.lotes,
    );
  }
}
