import 'package:costeira/features/movimentacoes/domain/entities/morte_animal_entity.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class MorteAnimaisVinculadosPage extends StatelessWidget {
  const MorteAnimaisVinculadosPage({super.key, required this.animais});

  final List<MorteAnimalEntity> animais;

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
        title: Text(
          animais.length == 1
              ? '1 animal vinculado'
              : '${animais.length} animais vinculados',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: animais.isEmpty
            ? const Center(child: Text('Nenhum animal vinculado.'))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                itemCount: animais.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final animal = animais[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFEBEBEB)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          animal.brinco?.trim().isNotEmpty == true
                              ? animal.brinco!.trim()
                              : 'Animal ${animal.id}',
                          style: const TextStyle(
                            color: Color(0xFF313131),
                            fontSize: 15,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: 'Categoria',
                          value: animal.categoria?.nome ?? '-',
                        ),
                        _InfoRow(
                          label: 'Peso',
                          value: animal.pesoTotal == null
                              ? '-'
                              : '${animal.pesoTotal!.toStringAsFixed(2)} kg',
                        ),
                        _InfoRow(
                          label: 'Causa',
                          value: animal.causa?.trim().isNotEmpty == true
                              ? animal.causa!.trim()
                              : '-',
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF8C8C8C), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF313131),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
