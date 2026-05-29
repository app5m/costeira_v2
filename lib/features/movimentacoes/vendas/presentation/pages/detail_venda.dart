import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/presentation/pages/venda_animais_vinculados_page.dart';
import 'package:flutter/material.dart';

import '../../../../../../theme/colors.dart';

class DetailVenda extends StatelessWidget {
  const DetailVenda({super.key, required this.venda});

  final VendaEntity venda;

  @override
  Widget build(BuildContext context) {
    final hasLinkedAnimals = venda.animais.isNotEmpty;
    final linkedAnimalsLabel = venda.qtdAnimais == 1
        ? '1 animal vinculado'
        : '${venda.qtdAnimais} animais vinculados';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Detalhes da venda',
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
              _ReadOnlyField(label: 'Data', value: venda.data),
              _ReadOnlyField(
                label: 'Quantidade',
                value: venda.qtdAnimais == 1
                    ? '1 animal'
                    : '${venda.qtdAnimais} animais',
              ),
              _ReadOnlyField(
                label: 'Peso medio',
                value: venda.pesoMedio == null
                    ? '-'
                    : '${venda.pesoMedio!.toStringAsFixed(2)} kg',
              ),
              _ReadOnlyField(
                label: 'Peso total',
                value: venda.pesoTotal == null
                    ? '-'
                    : '${venda.pesoTotal!.toStringAsFixed(2)} kg',
              ),
              _ReadOnlyField(
                label: 'Valor unitário',
                value: venda.valorUnitario?.trim().isNotEmpty == true
                    ? venda.valorUnitario!.trim()
                    : '-',
              ),
              _ReadOnlyField(
                label: 'Valor total',
                value: venda.valorTotal?.trim().isNotEmpty == true
                    ? venda.valorTotal!.trim()
                    : '-',
              ),
              _ReadOnlyField(
                label: 'Comprador',
                value: venda.comprador?.trim().isNotEmpty == true
                    ? venda.comprador!.trim()
                    : '-',
              ),
              _ReadOnlyField(
                label: 'Municipio',
                value: venda.municipio?.trim().isNotEmpty == true
                    ? venda.municipio!.trim()
                    : '-',
              ),
              _ReadOnlyField(label: 'Destino', value: _destinosLabel),
              _ReadOnlyField(
                label: 'Observações',
                value: venda.obs?.trim().isNotEmpty == true
                    ? venda.obs!.trim()
                    : '-',
                maxLines: 3,
              ),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: !hasLinkedAnimals
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VendaAnimaisVinculadosPage(
                              animais: venda.animais,
                            ),
                          ),
                        );
                      },
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
                          venda.qtdAnimais == 0
                              ? 'Nenhum animal vinculado'
                              : linkedAnimalsLabel,
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
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String get _destinosLabel {
    if (venda.destinos.isEmpty) {
      return '-';
    }
    return venda.destinos
        .map((item) {
          final nome = item.destinoReference?.nome ?? 'Destino ${item.destino}';
          return '$nome - ${item.tipo}';
        })
        .join('\n');
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  final String label;
  final String value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
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
        TextField(
          controller: TextEditingController(text: value),
          readOnly: true,
          maxLines: maxLines,
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFEBEBEB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
