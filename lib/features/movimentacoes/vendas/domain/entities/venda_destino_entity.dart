import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_reference_entity.dart';

class VendaDestinoEntity {
  const VendaDestinoEntity({
    this.id,
    this.appMovimentacoesId,
    required this.destino,
    required this.tipo,
    this.data,
    this.destinoReference,
  });

  final int? id;
  final int? appMovimentacoesId;
  final int destino;
  final String tipo;
  final String? data;
  final MovimentacaoReferenceEntity? destinoReference;
}
