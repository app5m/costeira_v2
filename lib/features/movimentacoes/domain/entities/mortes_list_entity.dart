import 'package:costeira/features/movimentacoes/domain/entities/morte_entity.dart';

class MortesListEntity {
  const MortesListEntity({required this.rows, required this.data});

  final int rows;
  final List<MorteEntity> data;
}
