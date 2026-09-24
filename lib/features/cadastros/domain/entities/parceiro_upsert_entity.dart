import 'package:costeira/features/cadastros/domain/entities/parceiro_kind.dart';

class ParceiroUpsertEntity {
  const ParceiroUpsertEntity({
    required this.kind,
    this.id,
    this.appUsersId,
    required this.appFazendasId,
    required this.tipoPessoa,
    required this.nome,
    required this.email,
    required this.celular,
    this.documento,
    this.cnpj,
    this.razaoSocial,
    this.nomeFantasia,
    required this.endereco,
    required this.numero,
    this.complemento,
  });

  final ParceiroKind kind;
  final int? id;
  final int? appUsersId;
  final int appFazendasId;
  final int tipoPessoa;
  final String nome;
  final String email;
  final String celular;
  final String? documento;
  final String? cnpj;
  final String? razaoSocial;
  final String? nomeFantasia;
  final String endereco;
  final String numero;
  final String? complemento;

  ParceiroUpsertEntity copyWith({int? appUsersId}) {
    return ParceiroUpsertEntity(
      kind: kind,
      id: id,
      appUsersId: appUsersId ?? this.appUsersId,
      appFazendasId: appFazendasId,
      tipoPessoa: tipoPessoa,
      nome: nome,
      email: email,
      celular: celular,
      documento: documento,
      cnpj: cnpj,
      razaoSocial: razaoSocial,
      nomeFantasia: nomeFantasia,
      endereco: endereco,
      numero: numero,
      complemento: complemento,
    );
  }
}
