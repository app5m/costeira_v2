import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_upsert_entity.dart';

class FazendaUpsertRequestModel {
  const FazendaUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory FazendaUpsertRequestModel.create(FazendaUpsertEntity fazenda) {
    return FazendaUpsertRequestModel._(_baseData(fazenda));
  }

  factory FazendaUpsertRequestModel.update(FazendaUpsertEntity fazenda) {
    return FazendaUpsertRequestModel._(
      _baseData(fazenda)
        ..addAll({'id': fazenda.id, 'status': fazenda.status})
        ..removeWhere((key, value) => value == null),
    );
  }

  static Map<String, dynamic> _baseData(FazendaUpsertEntity fazenda) {
    final data = <String, dynamic>{
      'token': WSConstantes.token,
      'app_users_id': fazenda.appUsersId,
      'id_user': fazenda.appUsersId,
      'mesmo_cnpj': fazenda.mesmoCnpj,
      'nome': fazenda.nome,
      'email': fazenda.email,
      'celular': fazenda.celular,
    };

    if (fazenda.mesmoCnpj == WSConstantes.mesmoCnpjNao ||
        (fazenda.cnpj?.trim().isNotEmpty ?? false)) {
      data.addAll({
        'tipo_pessoa': fazenda.tipoPessoa ?? WSConstantes.tipoPessoaJuridica,
        'documento': fazenda.documento ?? '',
        'cnpj': fazenda.cnpj ?? '',
        'razao_social': fazenda.razaoSocial ?? '',
        'nome_fantasia': fazenda.nomeFantasia ?? '',
      });
    }

    return data..removeWhere((key, value) => value == null);
  }
}
