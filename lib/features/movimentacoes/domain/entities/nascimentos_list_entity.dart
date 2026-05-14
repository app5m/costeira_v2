import 'package:costeira/features/movimentacoes/domain/entities/nascimento_entity.dart';

class NascimentosListEntity {
  const NascimentosListEntity({required this.rows, required this.data});

  final int rows;
  final List<NascimentoEntity> data;
}
