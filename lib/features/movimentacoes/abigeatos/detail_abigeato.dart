import 'package:costeira/features/movimentacoes/domain/entities/abigeato_entity.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class DetailAbigeato extends StatelessWidget {
  const DetailAbigeato({super.key, required this.abigeato});

  final AbigeatoEntity abigeato;

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
          'Detalhes do abigeato',
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
            _InfoField(label: 'Data', value: abigeato.data),
            _InfoField(label: 'Quantidade', value: _quantidadeLabel),
            _InfoField(label: 'Peso médio', value: _pesoMedioLabel),
            _InfoField(label: 'Peso total', value: _pesoTotalLabel),
            _InfoField(label: 'Observações', value: abigeato.obs, maxLines: 3),
            _InfoField(label: 'Animais vinculados', value: _animaisLabel),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String get _quantidadeLabel {
    final count = abigeato.qtdAnimais;
    return count == 1 ? '1 animal' : '$count animais';
  }

  String get _pesoMedioLabel {
    final peso = abigeato.pesoMedio;
    return peso == null ? '-' : '${peso.toStringAsFixed(2)} kg';
  }

  String get _pesoTotalLabel {
    final peso = abigeato.pesoTotal;
    return peso == null ? '-' : '${peso.toStringAsFixed(2)} kg';
  }

  String get _animaisLabel {
    if (abigeato.animais.isEmpty) {
      return abigeato.qtdAnimais == 1 ? '1 animal' : '${abigeato.qtdAnimais} animais';
    }
    return abigeato.animais
        .map(
          (animal) => animal.brinco?.trim().isNotEmpty == true
              ? animal.brinco!.trim()
              : 'Animal ID ${animal.id}',
        )
        .join('\n');
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
