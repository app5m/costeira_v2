import 'package:costeira/features/movimentacoes/domain/entities/transferencia_entity.dart';

class TransferenciasListEntity {
  const TransferenciasListEntity({required this.rows, required this.data});

  final int rows;
  final List<TransferenciaEntity> data;
}
