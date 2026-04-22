import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_category_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_item_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_subcategory_entity.dart';
import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/core/input_formatters/fixed_two_decimal_input_formatter.dart';
import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/animals/presentation/page_controllers/animal_edit_page_controller.dart';
import 'package:costeira/features/animals/presentation/widgets/animal_lot_selector.dart';
import 'package:costeira/features/potreiros/presentation/widgets/potreiro_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../../theme/colors.dart';

class EditAnimal extends StatefulWidget {
  const EditAnimal({super.key, this.animal});

  final AnimalEntity? animal;

  @override
  State<EditAnimal> createState() => _EditAnimalState();
}

class _EditAnimalState extends State<EditAnimal> {
  static const _pesoFormatter = FixedTwoDecimalInputFormatter();

  final AnimalEditPageController _pageController =
      Modular.get<AnimalEditPageController>();

  @override
  void initState() {
    super.initState();
    final animal = widget.animal;
    if (animal != null) {
      _pageController.init(animal);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final result = await _pageController.submit();
    if (!mounted) {
      return;
    }

    if (result.isSuccess) {
      Modular.to.pop({'success': true, 'message': result.message});
      return;
    }

    AppSnackBar.show(context: context, message: result.message, isError: true);
  }

  Future<void> _openLotSelection() async {
    if (!_pageController.isLoading &&
        _pageController.lots.isEmpty &&
        (_pageController.errorMessage ?? '').isEmpty) {
      try {
        await _pageController.reloadLots();
      } catch (_) {}
    }

    if (!mounted) {
      return;
    }

    final result = await showModalBottomSheet<AnimalLotSelectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AnimalLotSelectionSheet(
        lots: _pageController.lots,
        initialSelectedLotId: _pageController.selectedLotId,
        isLoading: _pageController.isLoading,
        errorMessage: _pageController.errorMessage,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    if (result.shouldAddLot) {
      final created = await Modular.to.pushNamed<Map<String, dynamic>?>(
        AppRoutes.animalLotsAdd,
      );

      if (!mounted) {
        return;
      }

      if (created?['success'] == true) {
        AppSnackBar.show(
          context: context,
          message:
              created?['message']?.toString() ?? 'Lote adicionado com sucesso.',
          isError: false,
        );

        try {
          await _pageController.reloadLots();
          if (!mounted) {
            return;
          }
          await _openLotSelection();
        } catch (_) {
          if (!mounted) {
            return;
          }
          AppSnackBar.show(
            context: context,
            message:
                _pageController.errorMessage ??
                'Nao foi possivel recarregar os lotes.',
            isError: true,
          );
        }
      }
      return;
    }

    _pageController.onLotChanged(result.selectedLotId);
  }

  Future<void> _openPotreiroSelection() async {
    if (!_pageController.isLoading &&
        _pageController.potreiros.isEmpty &&
        (_pageController.errorMessage ?? '').isEmpty) {
      try {
        await _pageController.reloadPotreiros();
      } catch (_) {}
    }

    if (!mounted) {
      return;
    }

    final result = await showModalBottomSheet<PotreiroSelectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PotreiroSelectionSheet(
        potreiros: _pageController.potreiros,
        initialSelectedPotreiroId: _pageController.selectedPotreiroId,
        isLoading: _pageController.isLoading,
        errorMessage: _pageController.errorMessage,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    if (result.shouldAddPotreiro) {
      final created = await Modular.to.pushNamed<Map<String, dynamic>?>(
        AppRoutes.potreirosAdd,
      );

      if (!mounted) {
        return;
      }

      if (created?['success'] == true) {
        AppSnackBar.show(
          context: context,
          message:
              created?['message']?.toString() ??
              'Potreiro adicionado com sucesso.',
          isError: false,
        );

        try {
          await _pageController.reloadPotreiros();
          if (!mounted) {
            return;
          }
          await _openPotreiroSelection();
        } catch (_) {
          if (!mounted) {
            return;
          }
          AppSnackBar.show(
            context: context,
            message:
                _pageController.errorMessage ??
                'Nao foi possivel recarregar os potreiros.',
            isError: true,
          );
        }
      }
      return;
    }

    _pageController.onPotreiroChanged(result.selectedPotreiroId);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: MyColors.colorPrimary,
            leading: GestureDetector(
              onTap: () => Modular.to.pop(),
              child: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            title: const Text(
              'Editar animal',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSexoSelector(),
                const SizedBox(height: 18),
                _buildTextField(
                  controller: _pageController.brincoController,
                  label: 'Brinco',
                  hint: 'Ex: BR-005',
                ),
                _buildDropdown<ListCategoryEntity>(
                  label: 'Categoria',
                  value: _pageController.selectedCategoryId,
                  items: _pageController.categories,
                  itemLabel: (item) => item.nome.trim(),
                  onChanged: _pageController.onCategoryChanged,
                ),
                if (_pageController.requiresSubcategory)
                  _buildDropdown<ListSubcategoryEntity>(
                    label: 'Subcategoria obrigatoria',
                    value: _pageController.selectedSubcategoryId,
                    items: _pageController.subcategories,
                    itemLabel: (item) => item.nome.trim(),
                    onChanged: _pageController.onSubcategoryChanged,
                  ),
                _buildTextField(
                  controller: _pageController.pesoController,
                  label: 'Peso',
                  hint: '700.50',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: const [_pesoFormatter],
                ),
                _buildDropdown<ListItemEntity>(
                  label: 'Base racial',
                  value: _pageController.selectedBaseRacialId,
                  items: _pageController.basesRaciais,
                  itemLabel: (item) => item.nome.trim(),
                  onChanged: _pageController.onBaseRacialChanged,
                ),
                AnimalLotSelectorField(
                  label: 'Lote',
                  value: _pageController.selectedLotLabel,
                  onTap: _openLotSelection,
                  isLoading: _pageController.isLoading,
                  errorMessage: _pageController.errorMessage,
                ),
                PotreiroSelectorField(
                  label: 'Potreiro',
                  value: _pageController.selectedPotreiroLabel,
                  onTap: _openPotreiroSelection,
                  isLoading: _pageController.isLoading,
                  errorMessage: _pageController.errorMessage,
                ),
                if (_pageController.shouldShowStatusField)
                  _buildStatusDropdown(
                    value: _pageController.selectedStatus,
                    onChanged: _pageController.onStatusChanged,
                  ),
                _buildTextField(
                  controller: _pageController.obsController,
                  label: 'Observacoes gerais',
                  hint: 'Animal em observacao',
                  maxLines: 3,
                ),
                if (_pageController.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _pageController.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 20),
                CustomButton(
                  onPressed: _submit,
                  text: 'Salvar',
                  enabled:
                      _pageController.isFormValid && _pageController.hasChanges,
                  isLoading: _pageController.isLoading,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSexoSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sexo',
          style: TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
            letterSpacing: 0.10,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile<int>(
                value: 1,
                groupValue: _pageController.selectedSexo,
                contentPadding: EdgeInsets.zero,
                title: const Text('Macho'),
                onChanged: (value) {
                  if (value != null) {
                    _pageController.onSexoChanged(value);
                  }
                },
              ),
            ),
            Expanded(
              child: RadioListTile<int>(
                value: 2,
                groupValue: _pageController.selectedSexo,
                contentPadding: EdgeInsets.zero,
                title: const Text('Femea'),
                onChanged: (value) {
                  if (value != null) {
                    _pageController.onSexoChanged(value);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
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
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
            letterSpacing: 0.10,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              height: 1.50,
              letterSpacing: 0.10,
            ),
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

  Widget _buildDropdown<T extends ListItemEntity>({
    required String label,
    required int? value,
    required List<T> items,
    required String Function(T item) itemLabel,
    required void Function(int? value) onChanged,
  }) {
    final effectiveValue = items.any((item) => item.id == value) ? value : null;

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
        AppSelectOverlay<int>(
          value: effectiveValue,
          placeholder: 'Selecione',
          options: items
              .map(
                (item) => AppSelectOption<int>(
                  value: item.id,
                  label: itemLabel(item),
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

  Widget _buildStatusDropdown({
    required String? value,
    required void Function(String? value) onChanged,
  }) {
    final effectiveValue =
        AnimalEditPageController.animalStatuses.contains(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
            letterSpacing: 0.10,
          ),
        ),
        const SizedBox(height: 6),
        AppSelectOverlay<String>(
          value: effectiveValue,
          placeholder: 'Selecione o status',
          options: AnimalEditPageController.animalStatuses
              .map(
                (status) =>
                    AppSelectOption<String>(value: status, label: status),
              )
              .toList(growable: false),
          enabled: AnimalEditPageController.animalStatuses.isNotEmpty,
          onChanged: onChanged,
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
