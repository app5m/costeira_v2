import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../../theme/colors.dart';

class PoteiroDetail extends StatelessWidget {
  const PoteiroDetail({super.key, required this.potreiro});

  final PotreiroEntity potreiro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
          onTap: () => Modular.to.pop(),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Detalhes do potreiro',
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              _buildReadOnlyField('Nome', potreiro.nome),
              _buildReadOnlyField(
                'Área total',
                _formatMeasure(potreiro.areaTotal),
              ),
              _buildReadOnlyField(
                'Área utilizável',
                _formatMeasure(potreiro.areaUtil),
              ),
              _buildReadOnlyField(
                'Status atual',
                _displayOrDash(potreiro.statusAtual),
              ),
              _buildReadOnlyField(
                'Tipo forragem',
                _displayOrDash(potreiro.tipoForragem),
              ),
              _buildReadOnlyField(
                'Acesso a água',
                _displayOrDash(potreiro.acessoAgua),
              ),
              _buildReadOnlyField(
                'Acesso a sombra',
                _displayOrDash(potreiro.acessoSombra),
              ),
              _buildReadOnlyField(
                'Lotação média',
                _formatValue(potreiro.lotacaoMedia),
              ),
              _buildReadOnlyField('Observações', _displayOrDash(potreiro.obs)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
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
            letterSpacing: 0.10,
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
              letterSpacing: 0.10,
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  String _formatMeasure(double? value) {
    if (value == null) {
      return '-';
    }
    if (value == value.truncateToDouble()) {
      return '${value.toStringAsFixed(0)} ha';
    }
    return '${value.toStringAsFixed(2)} ha';
  }

  String _formatValue(double? value) {
    if (value == null) {
      return '-';
    }
    if (value == value.truncateToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  String _displayOrDash(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? '-' : trimmed;
  }
}
