import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_upsert_entity.dart';

class PotreiroUpsertRequestModel {
  const PotreiroUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory PotreiroUpsertRequestModel.create(PotreiroUpsertEntity potreiro) {
    return PotreiroUpsertRequestModel._(
      {
        'token': WSConstantes.token,
        'app_users_id': potreiro.appUsersId,
        'app_fazendas_id': potreiro.appFazendasId,
        'nome': potreiro.nome,
        'area_total': potreiro.areaTotal,
        'area_util': potreiro.areaUtil,
        'status_atual': potreiro.statusAtual,
        'tipo_forragem': potreiro.tipoForragem,
        'acesso_agua': potreiro.acessoAgua,
        'acesso_sombra': potreiro.acessoSombra,
        'lotacao_media': potreiro.lotacaoMedia,
        'obs': potreiro.obs,
      }..removeWhere((key, value) => value == null),
    );
  }

  factory PotreiroUpsertRequestModel.update(PotreiroUpsertEntity potreiro) {
    return PotreiroUpsertRequestModel._(
      {
        'token': WSConstantes.token,
        'id': potreiro.id,
        'app_users_id': potreiro.appUsersId,
        'app_fazendas_id': potreiro.appFazendasId,
        'nome': potreiro.nome,
        'area_total': potreiro.areaTotal,
        'area_util': potreiro.areaUtil,
        'status_atual': potreiro.statusAtual,
        'tipo_forragem': potreiro.tipoForragem,
        'acesso_agua': potreiro.acessoAgua,
        'acesso_sombra': potreiro.acessoSombra,
        'lotacao_media': potreiro.lotacaoMedia,
        'obs': potreiro.obs,
      }..removeWhere((key, value) => value == null),
    );
  }
}
