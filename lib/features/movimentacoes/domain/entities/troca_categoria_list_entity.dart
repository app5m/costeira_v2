import 'package:costeira/features/movimentacoes/domain/entities/troca_categoria_entity.dart';

class TrocaCategoriaListEntity {
  const TrocaCategoriaListEntity({required this.rows, required this.data});

  final int rows;
  final List<TrocaCategoriaEntity> data;
}
