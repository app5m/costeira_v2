import 'package:costeira/features/movimentacoes/domain/entities/morte_entity.dart';
import 'package:costeira/features/movimentacoes/mortes/presentation/pages/morte_form_page.dart';
import 'package:flutter/material.dart';

class EditMorte extends StatelessWidget {
  const EditMorte({super.key, required this.morte});

  final MorteEntity morte;

  @override
  Widget build(BuildContext context) {
    return MorteFormPage(morte: morte);
  }
}
