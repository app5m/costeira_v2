import 'package:costeira/features/movimentacoes/domain/entities/consumo_entity.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class DetailConsumo extends StatelessWidget {
  const DetailConsumo({super.key, required this.consumo});

  final ConsumoEntity consumo;

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
          'Detalhes consumo',
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
          children: [
            _InfoField(label: 'Data', value: consumo.data),
            _InfoField(label: 'Animais', value: _animalsLabel),
            _InfoField(label: 'Peso medio', value: _formatKg(consumo.pesoMedio)),
            _InfoField(label: 'Peso total', value: _formatKg(consumo.pesoTotal)),
            _InfoField(label: 'Observações', value: consumo.obs, maxLines: 4),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String get _animalsLabel {
    final count = consumo.qtdAnimais;
    return count == 1 ? '1 animal' : '$count animais';
  }

  String? _formatKg(double? value) {
    if (value == null) {
      return null;
    }
    return '${value.toStringAsFixed(2)} kg';
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({required this.label, this.value, this.maxLines = 1});

  final String label;
  final String? value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final text = value?.trim().isNotEmpty == true ? value!.trim() : '-';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
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
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
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
