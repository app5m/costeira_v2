import 'package:costeira/features/movimentacoes/domain/entities/troca_categoria_animal_entity.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class TrocaCategoriaAnimaisVinculadosPage extends StatelessWidget {
  const TrocaCategoriaAnimaisVinculadosPage({super.key, required this.animais});

  final List<TrocaCategoriaAnimalEntity> animais;

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
          'Animais vinculados',
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
        child: animais.isEmpty
            ? const Center(child: Text('Nenhum animal vinculado.'))
            : ListView.separated(
                padding: const EdgeInsets.all(20),
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
                              : 'Sem brinco',
                          style: const TextStyle(
                            color: Color(0xFF313131),
                            fontSize: 15,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _subtitle(animal),
                          style: const TextStyle(
                            color: Color(0xFF8C8C8C),
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _subtitle(TrocaCategoriaAnimalEntity animal) {
    final origem = animal.catgOrigem?.nome.trim();
    final destino = animal.catgDestino?.nome.trim();
    if (origem?.isNotEmpty == true && destino?.isNotEmpty == true) {
      return '$origem - $destino';
    }
    return 'Animal ID ${animal.id}';
  }
}
