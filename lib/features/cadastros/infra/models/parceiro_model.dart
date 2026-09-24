import 'package:costeira/features/cadastros/domain/entities/parceiro_entity.dart';

class ParceiroModel extends ParceiroEntity {
  const ParceiroModel({
    required super.id,
    required super.appFazendasId,
    required super.tipoPessoa,
    required super.nome,
    required super.email,
    required super.celular,
    required super.documento,
    required super.cnpj,
    required super.razaoSocial,
    required super.nomeFantasia,
    required super.endereco,
    required super.numero,
    required super.complemento,
  });

  factory ParceiroModel.fromJson(Map<String, dynamic> json) {
    return ParceiroModel(
      id: _toInt(json['id']),
      appFazendasId: _toInt(
        json['app_fazendas_id'] ?? json['id_fazenda'] ?? json['fazenda_id'],
      ),
      tipoPessoa: _toInt(json['tipo_pessoa'], fallback: 1),
      nome: json['nome']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      celular:
          json['celular']?.toString() ?? json['telefone']?.toString() ?? '',
      documento: json['documento']?.toString() ?? json['cpf']?.toString() ?? '',
      cnpj: json['cnpj']?.toString() ?? '',
      razaoSocial: json['razao_social']?.toString() ?? '',
      nomeFantasia: json['nome_fantasia']?.toString() ?? '',
      endereco: json['endereco']?.toString() ?? '',
      numero: json['numero']?.toString() ?? '',
      complemento: json['complemento']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
