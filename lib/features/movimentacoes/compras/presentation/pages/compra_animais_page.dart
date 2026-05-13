import 'package:costeira/core/common/get_list/domain/entities/list_item_entity.dart';
import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/core/input_formatters/fixed_two_decimal_input_formatter.dart';
import 'package:costeira/features/movimentacoes/compras/domain/entities/compra_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/page_controllers/compra_form_page_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CompraAnimaisPage extends StatefulWidget {
  const CompraAnimaisPage({super.key, required this.pageController});

  final CompraFormPageController pageController;

  @override
  State<CompraAnimaisPage> createState() => _CompraAnimaisPageState();
}

class _CompraAnimaisPageState extends State<CompraAnimaisPage> {
  Future<void> _openAnimalForm({int? index}) async {
    final editing = index == null ? null : widget.pageController.animais[index];
    final result = await showModalBottomSheet<CompraUpsertAnimalEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CompraAnimalSheet(
        pageController: widget.pageController,
        initialAnimal: editing,
      ),
    );

    if (result == null) {
      return;
    }

    if (index == null) {
      final action = widget.pageController.addAnimalEntity(result);
      if (!mounted || action.isSuccess) {
        return;
      }
      AppSnackBar.show(
        context: context,
        message: action.message,
        isError: true,
      );
      return;
    }

    widget.pageController.updateAnimal(index, result);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.pageController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(64),
            ),
            onPressed: () => _openAnimalForm(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          appBar: AppBar(
            backgroundColor: MyColors.colorPrimary,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            title: const Text(
              'Animais da compra',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: widget.pageController.animais.isEmpty
              ? const Center(child: Text('Nenhum animal adicionado.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                  itemCount: widget.pageController.animais.length,
                  itemBuilder: (context, index) {
                    final animal = widget.pageController.animais[index];
                    return _DraftAnimalCard(
                      animal: animal,
                      onEdit: () => _openAnimalForm(index: index),
                      onRemove: () => widget.pageController.removeAnimal(index),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _CompraAnimalSheet extends StatefulWidget {
  const _CompraAnimalSheet({required this.pageController, this.initialAnimal});

  final CompraFormPageController pageController;
  final CompraUpsertAnimalEntity? initialAnimal;

  @override
  State<_CompraAnimalSheet> createState() => _CompraAnimalSheetState();
}

class _CompraAnimalSheetState extends State<_CompraAnimalSheet> {
  static const _pesoFormatter = FixedTwoDecimalInputFormatter();

  final _brincoController = TextEditingController();
  final _pesoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialAnimal;
    if (initial != null) {
      _brincoController.text = initial.brinco;
      _pesoController.text = initial.pesoTotal;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await widget.pageController.onAnimalSexoChanged(initial.sexo);
        widget.pageController.onAnimalCategoryChanged(
          initial.appAnimaisCategoriasId,
        );
        widget.pageController.onAnimalSubcategoryChanged(
          initial.appAnimaisSubcategoriasId,
        );
        widget.pageController.onAnimalBaseRacialChanged(
          initial.utBasesRaciaisId,
        );
      });
    }
  }

  @override
  void dispose() {
    _brincoController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  void _save() {
    final categoryId = widget.pageController.selectedAnimalCategoryId;
    if (categoryId == null ||
        _brincoController.text.trim().isEmpty ||
        _pesoController.text.trim().isEmpty) {
      AppSnackBar.show(
        context: context,
        message: 'Preencha os dados obrigatorios do animal.',
        isError: true,
      );
      return;
    }

    Navigator.pop(
      context,
      CompraUpsertAnimalEntity(
        appAnimaisCategoriasId: categoryId,
        appAnimaisSubcategoriasId:
            widget.pageController.shouldShowAnimalSubcategory
            ? widget.pageController.selectedAnimalSubcategoryId
            : null,
        utBasesRaciaisId: widget.pageController.selectedAnimalBaseRacialId,
        sexo: widget.pageController.selectedAnimalSexo,
        brinco: _brincoController.text.trim(),
        pesoTotal: _pesoController.text
            .trim()
            .replaceAll(',', '.')
            .replaceAll('kg', '')
            .trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.pageController,
      builder: (context, _) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.initialAnimal == null
                      ? 'Adicionar animal'
                      : 'Editar animal',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<int>(
                        value: 1,
                        groupValue: widget.pageController.selectedAnimalSexo,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Macho'),
                        onChanged: (value) {
                          if (value != null) {
                            widget.pageController.onAnimalSexoChanged(value);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<int>(
                        value: 2,
                        groupValue: widget.pageController.selectedAnimalSexo,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Fêmea'),
                        onChanged: (value) {
                          if (value != null) {
                            widget.pageController.onAnimalSexoChanged(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                _SheetDropdown<ListItemEntity>(
                  label: 'Categoria',
                  value: widget.pageController.selectedAnimalCategoryId,
                  items: widget.pageController.animalCategories,
                  onChanged: widget.pageController.onAnimalCategoryChanged,
                ),
                if (widget.pageController.shouldShowAnimalSubcategory)
                  _SheetDropdown<ListItemEntity>(
                    label: 'Subcategoria',
                    value: widget.pageController.selectedAnimalSubcategoryId,
                    items: widget.pageController.animalSubcategories,
                    onChanged: widget.pageController.onAnimalSubcategoryChanged,
                  ),
                _SheetDropdown<ListItemEntity>(
                  label: 'Base racial',
                  value: widget.pageController.selectedAnimalBaseRacialId,
                  items: widget.pageController.basesRaciais,
                  onChanged: widget.pageController.onAnimalBaseRacialChanged,
                ),
                _SheetTextField(
                  controller: _brincoController,
                  label: 'Brinco',
                  hint: 'C-001',
                ),
                _SheetTextField(
                  controller: _pesoController,
                  label: 'Peso total',
                  hint: '350.00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: const [_pesoFormatter],
                ),
                const SizedBox(height: 8),
                CustomButton(
                  onPressed: _save,
                  text: 'Salvar animal',
                  isLoading: widget.pageController.isLoading,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SheetDropdown<T extends ListItemEntity> extends StatelessWidget {
  const _SheetDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final int? value;
  final List<T> items;
  final void Function(int? value) onChanged;

  @override
  Widget build(BuildContext context) {
    final effectiveValue = items.any((item) => item.id == value) ? value : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        AppSelectOverlay<int>(
          value: effectiveValue,
          placeholder: 'Selecione',
          options: items
              .map(
                (item) => AppSelectOption<int>(
                  value: item.id,
                  label: item.nome.trim(),
                ),
              )
              .toList(growable: false),
          enabled: items.isNotEmpty,
          onChanged: onChanged,
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFEBEBEB),
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

class _DraftAnimalCard extends StatelessWidget {
  const _DraftAnimalCard({
    required this.animal,
    required this.onEdit,
    required this.onRemove,
  });

  final CompraUpsertAnimalEntity animal;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEBEBEB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal.brinco,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${animal.sexo == 1 ? 'Macho' : 'Fêmea'} - ${animal.pesoTotal} kg',
                ),
              ],
            ),
          ),
          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}
