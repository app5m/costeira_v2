import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';

class SuplementosListEntity {
  const SuplementosListEntity({required this.rows, required this.data});

  final int rows;
  final List<Suplemento> data;
}
