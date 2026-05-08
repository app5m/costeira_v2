import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo.dart';

class ManejosListEntity {
  const ManejosListEntity({
    required this.rows,
    required this.manejos,
    required this.tiposManejo,
  });

  final int rows;
  final List<Manejo> manejos;
  final List<TipoManejo> tiposManejo;
}
