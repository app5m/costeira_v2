import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';
import 'package:flutter/material.dart';

import '../../../../../../theme/colors.dart';

class DetailSuplemento extends StatelessWidget {
  const DetailSuplemento({super.key, required this.suplemento});

  final Suplemento suplemento;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Detalhes do Supl. e Consumo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            children: [
              _ReadOnlyField(
                label: 'Potreiro',
                value: suplemento.potreiro?.nome ?? '-',
              ),
              _ReadOnlyField(
                label: 'Lote',
                value: suplemento.lote?.nome ?? '-',
              ),
              _ReadOnlyField(
                label: 'Produto utilizado',
                value: suplemento.produto?.nome ?? '-',
              ),
              _ReadOnlyField(
                label: 'Data',
                value: _emptyToDash(suplemento.dataPostagem),
              ),
              _ReadOnlyField(
                label: 'Quantidade atual',
                value: _kg(suplemento.quantidadeAtual),
              ),
              _ReadOnlyField(
                label: 'Peso medio do lote',
                value: _kg(suplemento.pesoMedio),
              ),
              _ReadOnlyField(
                label: 'Quantidade de animais',
                value: suplemento.quantidadeAnimais?.toString() ?? '-',
              ),
              _ReadOnlyField(
                label: 'Periodo entre abastecimentos',
                value:
                    '${suplemento.consumoReal?.intervaloDias?.toString() ?? '-'} dias',
              ),
              _ReadOnlyField(
                label: 'Quantidade consumida no periodo',
                value: _kg(suplemento.consumoReal?.quantidadeConsumidaPeriodo),
              ),
              _ReadOnlyField(
                label: 'Consumo real do lote',
                value: _consumo(suplemento.consumoReal?.consumoRealDiaLote),
              ),
              _ReadOnlyField(
                label: 'Consumo real por animal',
                value: _consumo(suplemento.consumoReal?.consumoRealAnimalDia),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
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
              value,
              style: const TextStyle(
                color: Color(0xFF313131),
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _kg(double? value) {
  if (value == null) return '-';
  return '${value.toStringAsFixed(2)} kg';
}

String _consumo(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return '-';
  return '$trimmed kg/animal/dia';
}

String _emptyToDash(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? '-' : trimmed;
}
