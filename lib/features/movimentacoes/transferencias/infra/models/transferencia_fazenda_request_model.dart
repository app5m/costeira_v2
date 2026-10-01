import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_fazenda_upsert_entity.dart';

class TransferenciaFazendaRequestModel {
  const TransferenciaFazendaRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory TransferenciaFazendaRequestModel.create(
    TransferenciaFazendaUpsertEntity transferencia,
  ) {
    return TransferenciaFazendaRequestModel._(
      withSubUser(
        {
          'token': WSConstantes.token,
          'app_users_id': transferencia.appUsersId,
          'app_fazendas_id': transferencia.appFazendasId,
          'id_categoria': transferencia.idCategoria,
          'id_fazenda_destino': transferencia.idFazendaDestino,
          'valor_unitario': transferencia.valorUnitario,
          'valor_total': transferencia.valorTotal,
          'gta_documento': transferencia.gtaDocumento,
          'data': transferencia.data,
          'animais': transferencia.animais
              .map((animal) => {'id': animal.id})
              .toList(growable: false),
        }..removeWhere((key, value) => value == null),
      ),
    );
  }

  factory TransferenciaFazendaRequestModel.update(
    TransferenciaFazendaUpsertEntity transferencia,
  ) {
    return TransferenciaFazendaRequestModel._(
      withSubUser(
        {
          'token': WSConstantes.token,
          'app_users_id': transferencia.appUsersId,
          'app_fazendas_id': transferencia.appFazendasId,
          'id_categoria': transferencia.idCategoria,
          'id': transferencia.id,
          'id_fazenda_origem': transferencia.idFazendaOrigem,
          'id_fazenda_destino': transferencia.idFazendaDestino,
          'valor_unitario': transferencia.valorUnitario,
          'valor_total': transferencia.valorTotal,
          'gta_documento': transferencia.gtaDocumento,
          'data': transferencia.data,
        }..removeWhere((key, value) => value == null),
      ),
    );
  }

  factory TransferenciaFazendaRequestModel.aceitar({
    required int id,
    required int statusTransferencia,
  }) {
    return TransferenciaFazendaRequestModel._({
      'token': WSConstantes.token,
      'id': id,
      'status_transferencia': statusTransferencia,
    });
  }
}
