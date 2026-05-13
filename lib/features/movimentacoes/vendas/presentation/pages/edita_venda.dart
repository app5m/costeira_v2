import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/presentation/pages/venda_form_page.dart';
import 'package:flutter/material.dart';

class EditVenda extends StatelessWidget {
  const EditVenda({super.key, this.venda});

  final VendaEntity? venda;

  @override
  Widget build(BuildContext context) {
    return VendaFormPage(venda: venda);
  }
}
