import 'package:costeira/features/fazendas/domain/entities/fazenda_entity.dart';

class FazendaListEntity {
  const FazendaListEntity({required this.rows, required this.data});

  final int rows;
  final List<FazendaEntity> data;
}
