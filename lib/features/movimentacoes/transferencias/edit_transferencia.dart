import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/pages/transferencia_form_page.dart';
import 'package:flutter/material.dart';

class Editransferencia extends StatelessWidget {
  const Editransferencia({super.key, this.transferencia});

  final TransferenciaUpsertEntity? transferencia;

  @override
  Widget build(BuildContext context) {
    return TransferenciaFormPage(transferencia: transferencia);
  }
}
