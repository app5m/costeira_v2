import 'package:costeira/features/movimentacoes/domain/entities/morte_entity.dart';
import 'package:costeira/features/movimentacoes/mortes/presentation/pages/morte_animais_vinculados_page.dart';
import 'package:flutter/material.dart';

import '../../../../../../theme/colors.dart';

class DetailMorte extends StatelessWidget {
  const DetailMorte({super.key, required this.morte});

  final MorteEntity morte;

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
          'Detalhes da morte',
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
            _ReadOnlyField(label: 'Data', value: morte.data),
            _ReadOnlyField(
              label: 'Potreiro',
              value: morte.potreiro?.nome ?? '-',
            ),
            _ReadOnlyField(
              label: 'Quantidade',
              value: morte.qtdAnimais == 1
                  ? '1 animal'
                  : '${morte.qtdAnimais} animais',
            ),
            _ReadOnlyField(
              label: 'Observacoes',
              value: morte.obs?.trim().isNotEmpty == true
                  ? morte.obs!.trim()
                  : '-',
              maxLines: 3,
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: morte.animais.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MorteAnimaisVinculadosPage(
                            animais: morte.animais,
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
                        morte.animais.length == 1
                            ? '1 animal vinculado'
                            : '${morte.animais.length} animais vinculados',
                        style: const TextStyle(
                          color: Color(0xFF313131),
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (morte.animais.isNotEmpty)
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
    );
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
