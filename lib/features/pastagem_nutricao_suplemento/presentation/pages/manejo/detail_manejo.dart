import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo.dart';
import 'package:flutter/material.dart';

import '../../../../../../theme/colors.dart';

class DetailManejo extends StatelessWidget {
  const DetailManejo({super.key, required this.manejo});

  final Manejo manejo;

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
          'Detalhes do manejo',
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
                value: manejo.potreiro?.nome ?? '-',
              ),
              _ReadOnlyField(
                label: 'Data do manejo',
                value: _emptyToDash(manejo.dataManejo),
              ),
              _ReadOnlyField(
                label: 'Tipo de manejo',
                value: _emptyToDash(manejo.tipoManejo),
              ),
              _ReadOnlyField(
                label: 'Quantidade usada',
                value: _quantity(manejo.quantidade, manejo.unidade?.nome),
              ),
              _ReadOnlyField(
                label: 'Unidade',
                value: manejo.unidade?.nome ?? '-',
              ),
              _ReadOnlyField(
                label: 'Data de cadastro',
                value: _emptyToDash(manejo.dataCadastro),
              ),
              _ReadOnlyField(
                label: 'Ultima atualizacao',
                value: _emptyToDash(manejo.updateAt),
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

String _quantity(double? value, String? unidade) {
  if (value == null) return '-';
  final unit = unidade?.trim();
  final text = value % 1 == 0 ? value.toInt().toString() : value.toString();
  return unit == null || unit.isEmpty ? text : '$text $unit';
}

String _emptyToDash(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? '-' : trimmed;
}
