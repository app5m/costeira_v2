import 'package:costeira/features/cadastros/domain/entities/parceiro_kind.dart';

class DeleteParceiroEntity {
  const DeleteParceiroEntity({required this.kind, required this.id});

  final ParceiroKind kind;
  final int id;
}
