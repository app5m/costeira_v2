import 'package:costeira/features/cadastros/domain/entities/parceiro_kind.dart';

class ParceiroFilterEntity {
  const ParceiroFilterEntity({
    required this.kind,
    required this.appUsersId,
    required this.appFazendasId,
    this.id,
    this.nome,
  });

  final ParceiroKind kind;
  final int appUsersId;
  final int appFazendasId;
  final int? id;
  final String? nome;
}
