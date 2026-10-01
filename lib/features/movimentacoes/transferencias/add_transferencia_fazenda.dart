import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_fazenda_list_item.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/pages/transferencia_fazenda_form_page.dart';
import 'package:flutter/material.dart';

class AddTransferenciaFazenda extends StatelessWidget {
  const AddTransferenciaFazenda({super.key, this.item});

  final TransferenciaFazendaListItem? item;

  @override
  Widget build(BuildContext context) {
    return TransferenciaFazendaFormPage(item: item);
  }
}
