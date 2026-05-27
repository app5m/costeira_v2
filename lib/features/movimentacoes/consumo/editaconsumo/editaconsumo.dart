import 'package:costeira/features/movimentacoes/consumo/domain/entities/consumo_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/consumo/presentation/pages/edita_consumo.dart';
import 'package:flutter/material.dart';

class EditConsumo extends StatelessWidget {
  const EditConsumo({super.key, this.consumo});

  final ConsumoUpsertEntity? consumo;

  @override
  Widget build(BuildContext context) {
    return EditConsumoPage(consumo: consumo);
  }
}
