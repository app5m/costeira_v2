import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_animal_entity.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class VendaAnimaisVinculadosPage extends StatelessWidget {
  const VendaAnimaisVinculadosPage({super.key, required this.animais});

  final List<VendaAnimalEntity> animais;

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
      body: animais.isEmpty
          ? const Center(child: Text('Nenhum animal vinculado.'))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: animais.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final animal = animais[index];
                return _LinkedAnimalTile(index: index + 1, animal: animal);
              },
            ),
    );
  }
}

class _LinkedAnimalTile extends StatelessWidget {
  const _LinkedAnimalTile({required this.index, required this.animal});

  final int index;
  final VendaAnimalEntity animal;

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4EC),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: Color(0xFF00823A),
                    fontSize: 12,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  animal.brinco?.trim().isNotEmpty == true
                      ? animal.brinco!.trim()
                      : 'Animal ${animal.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF313131),
                    fontSize: 15,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Categoria', value: animal.categoria?.nome ?? '-'),
          _InfoRow(
            label: 'Peso',
            value: animal.pesoTotal == null
                ? '-'
                : '${animal.pesoTotal!.toStringAsFixed(2)} kg',
          ),
          _InfoRow(label: 'Lote', value: animal.lote?.nome ?? '-'),
          _InfoRow(label: 'Potreiro', value: animal.potreiro?.nome ?? '-'),
        ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8C8C8C),
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF313131),
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
