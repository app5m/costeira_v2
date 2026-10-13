import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';

class ManejoAnimalListaRequestModel {
  const ManejoAnimalListaRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory ManejoAnimalListaRequestModel.create({
    required int appUsersId,
    required int appFazendasId,
    required int idCategoria,
    bool? estacaoAtiva,
    String? dataReferencia,
  }) {
    return ManejoAnimalListaRequestModel._(
      withSubUser({
        'token': WSConstantes.token,
        'app_users_id': appUsersId,
        'app_fazendas_id': appFazendasId,
        'id_categoria': idCategoria,
        if (estacaoAtiva != null) 'estacao_ativa': estacaoAtiva,
        if (dataReferencia != null && dataReferencia.isNotEmpty)
          'data_referencia': dataReferencia,
      }),
    );
  }
}
