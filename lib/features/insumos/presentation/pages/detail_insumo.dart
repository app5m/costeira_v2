import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:flutter/material.dart';

import '../../../../theme/colors.dart';

class DetailInsumo extends StatelessWidget {
  const DetailInsumo({
    super.key,
    required this.insumo,
    required this.tipoLabel,
  });

  final InsumoEntity insumo;
  final String tipoLabel;

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
          'Detalhes do insumo',
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
              _ReadOnlyField(label: 'Tipo de insumo', value: tipoLabel),
              _ReadOnlyField(label: 'Nome comercial', value: insumo.nome),
              if (insumo.suplemento != null)
                _ReadOnlyField(
                  label: 'Suplemento',
                  value: insumo.suplemento!.nome,
                ),
              _ReadOnlyField(
                label: 'Quantidade',
                value: _quantity(insumo.qtdTotal, insumo.unidade?.nome),
              ),
              _ReadOnlyField(
                label: 'Preco por unidade',
                value: _money(insumo.valorUnidade, insumo.unidade?.nome),
              ),
              _ReadOnlyField(
                label: 'Valor total',
                value: _emptyToDash(insumo.valorTotal),
              ),
              _ReadOnlyField(
                label: 'Validade',
                value: _emptyToDash(insumo.dataValidade),
              ),
              _ReadOnlyField(
                label: 'Observacoes',
                value: _emptyToDash(insumo.obs),
                minHeight: 92,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
    this.minHeight,
  });

  final String label;
  final String value;
  final double? minHeight;

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
            constraints: BoxConstraints(minHeight: minHeight ?? 0),
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

String _money(String? value, String? unidade) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return '-';
  final unit = unidade?.trim();
  return unit == null || unit.isEmpty ? trimmed : '$trimmed/$unit';
}

String _emptyToDash(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? '-' : trimmed;
}
