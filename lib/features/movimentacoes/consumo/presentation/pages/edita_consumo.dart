import 'package:costeira/features/movimentacoes/consumo/domain/entities/consumo_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/consumo/presentation/pages/consumo_form_page.dart';
import 'package:flutter/material.dart';

class EditConsumoPage extends StatelessWidget {
  const EditConsumoPage({super.key, this.consumo});

  final ConsumoUpsertEntity? consumo;

  @override
  Widget build(BuildContext context) {
    return ConsumoFormPage(consumo: consumo);
  }
}
