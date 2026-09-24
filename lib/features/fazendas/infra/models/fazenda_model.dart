import 'package:costeira/features/fazendas/domain/entities/fazenda_entity.dart';

class FazendaModel extends FazendaEntity {
  const FazendaModel({
    required super.id,
    required super.nome,
    required super.email,
    required super.celular,
    required super.mesmoCnpj,
    required super.tipoPessoa,
    required super.documento,
    required super.cnpj,
    required super.razaoSocial,
    required super.nomeFantasia,
    required super.status,
  });

  factory FazendaModel.fromJson(Map<String, dynamic> json) {
    return FazendaModel(
      id: _toInt(json['id'] ?? json['app_fazendas_id']),
      nome: json['nome']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      celular:
          json['celular']?.toString() ?? json['telefone']?.toString() ?? '',
      mesmoCnpj: _toInt(json['mesmo_cnpj'] ?? json['mesmoCnpj'], fallback: 2),
      tipoPessoa: _toInt(json['tipo_pessoa'], fallback: 2),
      documento: json['documento']?.toString() ?? json['cpf']?.toString() ?? '',
      cnpj: json['cnpj']?.toString() ?? '',
      razaoSocial: json['razao_social']?.toString() ?? '',
      nomeFantasia: json['nome_fantasia']?.toString() ?? '',
      status: _toInt(json['status'], fallback: 1),
    );
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
