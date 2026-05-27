import 'package:costeira/features/movimentacoes/abigeatos/domain/entities/abigeato_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/abigeatos/presentation/pages/abigeato_form_page.dart';
import 'package:flutter/material.dart';

class EditAbigeato extends StatelessWidget {
  const EditAbigeato({super.key, required this.abigeato});

  final AbigeatoUpsertEntity abigeato;

  @override
  Widget build(BuildContext context) {
    return AbigeatoFormPage(abigeato: abigeato);
  }
}
