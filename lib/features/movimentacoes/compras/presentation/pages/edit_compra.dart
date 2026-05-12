import 'package:costeira/features/movimentacoes/compras/presentation/pages/compra_form_page.dart';
import 'package:costeira/features/movimentacoes/domain/entities/compra_entity.dart';
import 'package:flutter/material.dart';

class EditCompra extends StatelessWidget {
  const EditCompra({super.key, required this.compra});

  final CompraEntity compra;

  @override
  Widget build(BuildContext context) {
    return CompraFormPage(compra: compra);
  }
}
