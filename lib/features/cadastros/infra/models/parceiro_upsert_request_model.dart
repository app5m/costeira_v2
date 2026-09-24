import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_upsert_entity.dart';

class ParceiroUpsertRequestModel {
  const ParceiroUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory ParceiroUpsertRequestModel.create(ParceiroUpsertEntity parceiro) {
    return ParceiroUpsertRequestModel._(_baseData(parceiro));
  }

  factory ParceiroUpsertRequestModel.update(ParceiroUpsertEntity parceiro) {
    return ParceiroUpsertRequestModel._(
      _baseData(parceiro)..addAll({'id': parceiro.id}),
    );
  }

  static Map<String, dynamic> _baseData(ParceiroUpsertEntity parceiro) {
    final isPf = parceiro.tipoPessoa == WSConstantes.tipoPessoaFisica;
    return {
      'token': WSConstantes.token,
      'app_users_id': parceiro.appUsersId,
      'app_fazendas_id': parceiro.appFazendasId,
      'tipo_pessoa': parceiro.tipoPessoa,
      'nome': parceiro.nome,
      'email': parceiro.email,
      'celular': parceiro.celular,
      'endereco': parceiro.endereco,
      'numero': parceiro.numero,
      'complemento': parceiro.complemento ?? '',
      if (isPf) 'documento': parceiro.documento ?? '',
      if (!isPf) ...{
        'cnpj': parceiro.cnpj ?? '',
        'razao_social': parceiro.razaoSocial ?? '',
        'nome_fantasia': parceiro.nomeFantasia ?? '',
      },
    }..removeWhere((key, value) => value == null);
  }
}
