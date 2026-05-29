import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../../theme/colors.dart';

class DetailAnimal extends StatelessWidget {
  const DetailAnimal({super.key, this.animal});

  final AnimalEntity? animal;

  @override
  Widget build(BuildContext context) {
    final item = animal;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
          onTap: () => Modular.to.pop(),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Detalhes do animal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReadOnlyField('Sexo', item?.sexo == 1 ? 'Macho' : 'Fêmea'),
              _buildReadOnlyField('Brinco', item?.brinco ?? '-'),
              _buildReadOnlyField(
                'Categoria',
                item?.categoria?.nome.trim() ?? '-',
              ),
              _buildReadOnlyField(
                'Subcategoria',
                item?.subcategoria?.nome.trim() ?? '-',
              ),
              _buildReadOnlyField(
                'Peso',
                item?.peso != null ? '${item!.peso} kg' : '-',
              ),
              _buildReadOnlyField(
                'Base racial',
                item?.baseRacial?.nome.trim() ?? '-',
              ),
              _buildReadOnlyField('Lote', item?.lote?.nome.trim() ?? '-'),
              _buildReadOnlyField(
                'Potreiro',
                item?.potreiro?.nome.trim() ?? '-',
              ),
              _buildReadOnlyField('Status', item?.status ?? '-'),
              _buildReadOnlyField('Observações gerais', item?.obs ?? '-'),
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
}
