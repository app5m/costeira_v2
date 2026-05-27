import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/page_controllers/transferencia_form_page_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class TransferenciaLotesPage extends StatelessWidget {
  const TransferenciaLotesPage({super.key, required this.pageController});

  final TransferenciaFormPageController pageController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, _) {
        final lotes = pageController.filteredLotes;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: MyColors.colorPrimary,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            title: const Text(
              'Selecionar lotes',
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
                  controller: pageController.lotFilterController,
                  decoration: InputDecoration(
                    hintText: 'Filtrar por nome',
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
                    : lotes.isEmpty
                    ? const Center(child: Text('Nenhum lote encontrado.'))
                    : RefreshIndicator(
                        onRefresh: pageController.reloadLotes,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                          itemCount: lotes.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final lote = lotes[index];
                            return _LoteTile(
                              lote: lote,
                              isSelected: pageController.isLoteSelected(
                                lote.id,
                              ),
                              onTap: () => pageController.toggleLote(lote),
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
                      onPressed: pageController.selectedLotes.isEmpty
                          ? null
                          : () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.colorPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        pageController.selectedLotes.length == 1
                            ? 'Confirmar 1 lote'
                            : 'Confirmar ${pageController.selectedLotes.length} lotes',
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

class _LoteTile extends StatelessWidget {
  const _LoteTile({
    required this.lote,
    required this.isSelected,
    required this.onTap,
  });

  final AnimalLotEntity lote;
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
              child: Text(
                lote.nome,
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
            Text(
              lote.animalsCount == 1
                  ? '1 animal'
                  : '${lote.animalsCount} animais',
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
    );
  }
}
