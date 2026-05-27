import 'package:costeira/features/movimentacoes/abortos/presentation/pages/aborto_form_page.dart';
import 'package:costeira/features/movimentacoes/domain/entities/aborto_entity.dart';
import 'package:flutter/material.dart';

class EditAborto extends StatelessWidget {
  const EditAborto({super.key, this.aborto});

  final AbortoEntity? aborto;

  @override
  Widget build(BuildContext context) {
    return AbortoFormPage(aborto: aborto);
  }
}
