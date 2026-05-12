import 'package:costeira/features/movimentacoes/domain/entities/compra_animal_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/compra_entity.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class DetailCompra extends StatelessWidget {
  const DetailCompra({super.key, required this.compra});

  final CompraEntity compra;

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
          'Detalhes da compra',
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
            _InfoField(label: 'Potreiro', value: compra.potreiro?.nome),
            _InfoField(label: 'Lote', value: compra.lote?.nome),
            _InfoField(label: 'Data da compra', value: compra.data),
            _InfoField(
              label: 'Tipo de compra',
              value: compra.tipoCompra == 'kg' ? 'KG' : 'Por cabeca',
            ),
            _InfoField(label: 'Valor unitário', value: compra.valorUnitario),
            _InfoField(label: 'Fornecedor', value: compra.fornecedor),
            _InfoField(label: 'Município', value: compra.municipio),
            _InfoField(label: 'Observações', value: compra.obs),
            const SizedBox(height: 8),
            const Text(
              'Animais',
              style: TextStyle(
                color: Color(0xFF313131),
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (compra.animais.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Nenhum animal vinculado.'),
              )
            else
              ...compra.animais.map(_AnimalCard.new),
          ],
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({required this.label, required this.value});

  final String label;
  final String? value;

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

class _AnimalCard extends StatelessWidget {
  const _AnimalCard(this.animal);

  final CompraAnimalEntity animal;

  @override
  Widget build(BuildContext context) {
    final brinco = animal.brinco?.trim().isNotEmpty == true
        ? animal.brinco!.trim()
        : 'Sem brinco';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEBEBEB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(brinco, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            [
              animal.categoria?.nome,
              animal.sexo == 1 ? 'Macho' : 'Fêmea',
              animal.pesoTotal == null ? null : '${animal.pesoTotal} kg',
            ].where((item) => item?.trim().isNotEmpty == true).join(' - '),
          ),
        ],
      ),
    );
  }
}
