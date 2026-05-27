import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_upsert_lote_entity.dart';

class TransferenciaUpsertRequestModel {
  const TransferenciaUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory TransferenciaUpsertRequestModel.create(
    TransferenciaUpsertEntity transferencia,
  ) {
    final data = _baseData(transferencia)..addAll({'tipo': transferencia.tipo});

    if (transferencia.tipo == 'animais') {
      data['animais'] = transferencia.animais
          .map(_animalToJson)
          .toList(growable: false);
    } else {
      data['lotes'] = transferencia.lotes
          .map(_loteToJson)
          .toList(growable: false);
    }

    return TransferenciaUpsertRequestModel._(data);
  }

  factory TransferenciaUpsertRequestModel.update(
    TransferenciaUpsertEntity transferencia,
  ) {
    return TransferenciaUpsertRequestModel._(
      _baseData(transferencia)..addAll({'id': transferencia.id}),
    );
  }

  static Map<String, dynamic> _baseData(
    TransferenciaUpsertEntity transferencia,
  ) {
    return {
      'token': WSConstantes.token,
      'app_users_id': transferencia.appUsersId,
      'data': transferencia.data,
      'potreiro_destino': transferencia.potreiroDestino,
      'lote_destino': transferencia.loteDestino,
      'obs': transferencia.obs,
    }..removeWhere((key, value) => value == null);
  }

  static Map<String, dynamic> _animalToJson(
    TransferenciaUpsertAnimalEntity animal,
  ) {
    return {'id': animal.id};
  }

  static Map<String, dynamic> _loteToJson(TransferenciaUpsertLoteEntity lote) {
    return {'id': lote.id};
  }
}
