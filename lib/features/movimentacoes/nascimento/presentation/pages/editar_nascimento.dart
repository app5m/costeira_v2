import 'package:costeira/features/movimentacoes/domain/entities/nascimento_entity.dart';
import 'package:costeira/features/movimentacoes/nascimento/presentation/pages/nascimento_form_page.dart';
import 'package:flutter/material.dart';

class EditNascimento extends StatelessWidget {
  const EditNascimento({super.key, required this.nascimento});

  final NascimentoEntity nascimento;

  @override
  Widget build(BuildContext context) {
    return NascimentoFormPage(nascimento: nascimento);
  }
}
