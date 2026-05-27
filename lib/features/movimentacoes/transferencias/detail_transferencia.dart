import 'package:costeira/features/movimentacoes/domain/entities/transferencia_entity.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class DetailTransferencia extends StatelessWidget {
  const DetailTransferencia({super.key, required this.transferencia});

  final TransferenciaEntity transferencia;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Detalhes da transferencia',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoField(label: 'Data', value: transferencia.data),
            _InfoField(label: 'Tipo', value: _tipoLabel),
            _InfoField(label: 'Quantidade', value: _quantidadeLabel),
            _InfoField(label: 'Potreiro destino', value: transferencia.potreiroDestino?.nome),
            if (transferencia.loteDestino != null)
              _InfoField(label: 'Lote destino', value: transferencia.loteDestino?.nome),
            _InfoField(label: 'Peso médio', value: _pesoMedioLabel),
            _InfoField(label: 'Peso total', value: _pesoTotalLabel),
            _InfoField(label: 'Observações', value: transferencia.obs, maxLines: 3),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String get _tipoLabel {
    return transferencia.loteDestino == null ? 'Animais' : 'Lotes';
  }

  String get _quantidadeLabel {
    final count = transferencia.qtdAnimais;
    return count == 1 ? '1 animal' : '$count animais';
  }

  String get _pesoMedioLabel {
    final peso = transferencia.pesoMedio;
    return peso == null ? '-' : '${peso.toStringAsFixed(2)} kg';
  }

  String get _pesoTotalLabel {
    final peso = transferencia.pesoTotal;
    return peso == null ? '-' : '${peso.toStringAsFixed(2)} kg';
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({required this.label, required this.value, this.maxLines = 1});

  final String label;
  final String? value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final display = value?.trim().isNotEmpty == true ? value!.trim() : '-';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEBEBEB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            display,
            maxLines: maxLines,
            overflow: maxLines == 1 ? TextOverflow.ellipsis : null,
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
