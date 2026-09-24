import 'package:costeira/features/cadastros/domain/entities/parceiro_entity.dart';

class ParceiroListEntity {
  const ParceiroListEntity({required this.rows, required this.data});

  final int rows;
  final List<ParceiroEntity> data;
}
