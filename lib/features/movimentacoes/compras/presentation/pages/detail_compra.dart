import 'package:costeira/features/movimentacoes/compras/presentation/pages/compra_animais_lista_page.dart';
import 'package:costeira/features/movimentacoes/domain/entities/compra_entity.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class DetailCompra extends StatelessWidget {
  const DetailCompra({super.key, required this.compra});

  final CompraEntity compra;

  @override
  Widget build(BuildContext context) {
    final count = compra.qtdAnimais;
    final hasLinkedAnimals = compra.animais.isNotEmpty;
    final animaisLabel = count == 1
        ? '1 animal vinculado'
        : '$count animais vinculados';

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
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoField(label: 'Potreiro', value: compra.potreiro?.nome),
              _InfoField(label: 'Lote', value: compra.lote?.nome),
              _InfoField(label: 'Data da compra', value: compra.data),
              _InfoField(
                label: 'Tipo de compra',
                value: compra.tipoCompra == 'kg' ? 'KG' : 'Por cabeça',
              ),
              _InfoField(label: 'Valor unitário', value: compra.valorUnitario),
              _InfoField(label: 'Fornecedor', value: compra.fornecedor),
              _InfoField(label: 'Município', value: compra.municipio),
              _InfoField(label: 'Observações', value: compra.obs),
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
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: !hasLinkedAnimals
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CompraAnimaisListaPage.saved(
                            animais: compra.animais,
                          ),
                        ),
                      ),
                child: Ink(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEBEB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          count == 0 ? 'Nenhum animal vinculado' : animaisLabel,
                          style: const TextStyle(
                            color: Color(0xFF313131),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (hasLinkedAnimals)
                        const Icon(
                          Icons.keyboard_arrow_right,
                          color: Color(0xFF8C8C8C),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
