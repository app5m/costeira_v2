import 'package:costeira/features/movimentacoes/domain/entities/troca_categoria_entity.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/presentation/pages/troca_categoria_form_page.dart';
import 'package:flutter/material.dart';

class EditTroca extends StatelessWidget {
  const EditTroca({super.key, this.troca});

  final TrocaCategoriaEntity? troca;

  @override
  Widget build(BuildContext context) {
    return TrocaCategoriaFormPage(troca: troca);
  }
}
