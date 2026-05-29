import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/movimentacoes/mortes/presentation/page_controllers/morte_form_page_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class MorteAnimaisPage extends StatelessWidget {
  const MorteAnimaisPage({super.key, required this.pageController});

  final MorteFormPageController pageController;

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
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: TextField(
                    controller: pageController.animalFilterController,
                    decoration: InputDecoration(
                      hintText: 'Filtrar por brinco ou peso',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xFFEBEBEB),
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
                                causa: pageController.animalCausa(animal.id),
                                onTap: () => _editCausa(context, animal),
                                onCheckboxChanged: () =>
                                    _toggleAnimal(context, animal),
                              );
                            },
                          ),
                        ),
                ),
                Padding(
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
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleAnimal(BuildContext context, AnimalEntity animal) async {
    final wasSelected = pageController.isAnimalSelected(animal.id);
    pageController.toggleAnimal(animal);
    if (wasSelected) {
      return;
    }
    await _editCausa(context, animal);
  }

  Future<void> _editCausa(BuildContext context, AnimalEntity animal) async {
    if (!pageController.isAnimalSelected(animal.id)) {
      return;
    }
    final previousCausa = pageController.animalCausa(animal.id);
    final causa = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) =>
          SafeArea(top: false, child: _CausaSheet(initialValue: previousCausa)),
    );
    if (causa != null) {
      pageController.setAnimalCausa(animal.id, causa);
    }
  }
}

class _CausaSheet extends StatefulWidget {
  const _CausaSheet({this.initialValue});

  final String? initialValue;

  @override
  State<_CausaSheet> createState() => _CausaSheetState();
}

class _CausaSheetState extends State<_CausaSheet> {
  late final TextEditingController _controller;

  bool get _hasChanges =>
      _controller.text.trim() != (widget.initialValue ?? '').trim();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E2E2),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Causa da morte',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Ex: Doença, acidente, etc.',
              filled: true,
              fillColor: const Color(0xFFEBEBEB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _hasChanges
                  ? () => Navigator.pop(context, _controller.text)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.colorPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Salvar causa',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          if ((widget.initialValue ?? '').trim().isNotEmpty)
            TextButton(
              onPressed: () => Navigator.pop(context, ''),
              child: const Text('Remover causa'),
            )
          else
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Ignorar'),
            ),
        ],
      ),
    );
  }
}

class _AnimalTile extends StatelessWidget {
  const _AnimalTile({
    required this.animal,
    required this.isSelected,
    required this.onTap,
    required this.onCheckboxChanged,
    this.causa,
  });

  final AnimalEntity animal;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onCheckboxChanged;
  final String? causa;

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
            Checkbox(value: isSelected, onChanged: (_) => onCheckboxChanged()),
            const SizedBox(width: 8),
            Expanded(
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
                    _subtitle,
                    style: const TextStyle(
                      color: Color(0xFF8C8C8C),
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if ((causa ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Causa: ${causa!.trim()}',
                      style: const TextStyle(
                        color: Color(0xFF313131),
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _subtitle {
    final parts = <String>[];
    final categoria = animal.categoria?.nome.trim();
    final peso = animal.peso;
    if (categoria != null && categoria.isNotEmpty) {
      parts.add(categoria);
    }
    if (peso != null) {
      parts.add('${peso.toStringAsFixed(2)} kg');
    }
    return parts.isEmpty ? 'Animal ID ${animal.id}' : parts.join(' - ');
  }
}
