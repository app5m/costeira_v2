import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/page_controllers/transferencia_form_page_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class TransferenciaAnimaisPage extends StatelessWidget {
  const TransferenciaAnimaisPage({super.key, required this.pageController});

  final TransferenciaFormPageController pageController;

  @override
  Widget build(BuildContext context) {
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
            title: const Text(
              'Selecionar animais',
              style: TextStyle(
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
                            return _AnimalTile(
                              animal: animal,
                              isSelected: pageController.isAnimalSelected(
                                animal.id,
                              ),
                              onTap: () => pageController.toggleAnimal(animal),
                            );
                          },
                        ),
                      ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: pageController.selectedAnimais.isEmpty
                          ? null
                          : () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.colorPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        pageController.selectedAnimais.length == 1
                            ? 'Confirmar 1 animal'
                            : 'Confirmar ${pageController.selectedAnimais.length} animais',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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

class _AnimalTile extends StatelessWidget {
  const _AnimalTile({
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
            Checkbox(value: isSelected, onChanged: (_) => onTap()),
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
    final potreiro = animal.potreiro?.nome.trim();
    if (categoria != null && categoria.isNotEmpty) {
      parts.add(categoria);
    }
    if (lote != null && lote.isNotEmpty) {
      parts.add(lote);
    }
    if (potreiro != null && potreiro.isNotEmpty) {
      parts.add(potreiro);
    }
    return parts.isEmpty ? 'Animal ID ${animal.id}' : parts.join(' - ');
  }
}
