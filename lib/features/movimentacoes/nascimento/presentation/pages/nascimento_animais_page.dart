import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/movimentacoes/nascimento/presentation/page_controllers/nascimento_form_page_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

enum NascimentoAnimalSelectionType { matriz, terneiro }

class NascimentoAnimaisPage extends StatelessWidget {
  const NascimentoAnimaisPage({
    super.key,
    required this.pageController,
    required this.type,
  });

  final NascimentoFormPageController pageController;
  final NascimentoAnimalSelectionType type;

  @override
  Widget build(BuildContext context) {
    final isMatriz = type == NascimentoAnimalSelectionType.matriz;

    return AnimatedBuilder(
      animation: pageController,
      builder: (context, _) {
        final animais = pageController.filteredAnimais;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: MyColors.colorPrimary,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            title: Text(
              isMatriz ? 'Selecionar matriz' : 'Selecionar terneiro',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: TextField(
                  controller: pageController.animalFilterController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'Filtrar por brinco',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFEBEBEB),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              if (pageController.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    pageController.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              Expanded(
                child: pageController.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : animais.isEmpty
                    ? const Center(child: Text('Nenhum animal encontrado.'))
                    : RefreshIndicator(
                        onRefresh: pageController.reloadAnimais,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                          itemCount: animais.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final animal = animais[index];
                            return _AnimalSelectableTile(
                              animal: animal,
                              isSelected: isMatriz
                                  ? pageController.isMatrizSelected(animal.id)
                                  : pageController.isTerneiroSelected(
                                      animal.id,
                                    ),
                              onTap: () {
                                if (isMatriz) {
                                  pageController.selectMatriz(animal);
                                } else {
                                  pageController.selectTerneiro(animal);
                                }
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimalSelectableTile extends StatelessWidget {
  const _AnimalSelectableTile({
    required this.animal,
    required this.isSelected,
    required this.onTap,
  });

  final AnimalEntity animal;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? MyColors.colorPrimary : const Color(0xFFEBEBEB),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animal.brinco?.trim().isNotEmpty == true
                        ? animal.brinco!.trim()
                        : 'Sem brinco',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF8C8C8C),
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _subtitle(AnimalEntity animal) {
    final parts = <String>[];
    final categoria = animal.categoria?.nome.trim();
    final lote = animal.lote?.nome.trim();
    final peso = animal.peso;
    if (categoria != null && categoria.isNotEmpty) {
      parts.add(categoria);
    }
    if (peso != null) {
      parts.add('${peso.toStringAsFixed(2)} kg');
    }
    if (lote != null && lote.isNotEmpty) {
      parts.add(lote);
    }
    return parts.isEmpty ? 'Animal ID ${animal.id}' : parts.join(' - ');
  }
}
