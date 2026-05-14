import 'package:costeira/core/common/get_list/domain/entities/list_category_entity.dart';
import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/features/animals/presentation/widgets/animal_lot_selector.dart';
import 'package:costeira/features/movimentacoes/domain/entities/troca_categoria_entity.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/presentation/page_controllers/troca_categoria_form_page_controller.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/presentation/pages/troca_categoria_animais_page.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/presentation/pages/troca_categoria_animais_vinculados_page.dart';
import 'package:costeira/features/potreiros/presentation/widgets/potreiro_selector.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TrocaCategoriaFormPage extends StatefulWidget {
  const TrocaCategoriaFormPage({super.key, this.troca});

  final TrocaCategoriaEntity? troca;

  @override
  State<TrocaCategoriaFormPage> createState() => _TrocaCategoriaFormPageState();
}

class _TrocaCategoriaFormPageState extends State<TrocaCategoriaFormPage> {
  final TrocaCategoriaFormPageController _pageController =
      Modular.get<TrocaCategoriaFormPageController>();

  @override
  void initState() {
    super.initState();
    _pageController.init(troca: widget.troca);
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
      Navigator.pop(context, {'success': true, 'message': result.message});
      return;
    }
    AppSnackBar.show(context: context, message: result.message, isError: true);
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null) {
      return;
    }
    _pageController.dataController.text =
        '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
  }

  Future<void> _selectPotreiro() async {
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
    if (result == null || result.shouldAddPotreiro) {
      return;
    }
    _pageController.onPotreiroChanged(result.selectedPotreiroId);
  }

  Future<void> _selectLote() async {
    final result = await showModalBottomSheet<AnimalLotSelectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AnimalLotSelectionSheet(
        lots: _pageController.lotes,
        initialSelectedLotId: _pageController.selectedLoteId,
        isLoading: _pageController.isLoading,
        errorMessage: _pageController.errorMessage,
      ),
    );
    if (result == null || result.shouldAddLot) {
      return;
    }
    _pageController.onLoteChanged(result.selectedLotId);
  }

  Future<void> _openAnimalsSelection() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TrocaCategoriaAnimaisPage(pageController: _pageController)),
    );
  }

  Future<void> _openLinkedAnimals() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TrocaCategoriaAnimaisVinculadosPage(animais: widget.troca?.animais ?? const []),
      ),
    );
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
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            title: Text(
              _pageController.isEdit ? 'Editar troca' : 'Adicionar troca',
              style: const TextStyle(
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
                _buildTextField(
                  controller: _pageController.dataController,
                  label: 'Data da troca',
                  hint: '00/00/0000',
                  readOnly: true,
                  onTap: _selectDate,
                ),
                PotreiroSelectorField(
                  label: 'Potreiro',
                  value: _pageController.selectedPotreiroLabel,
                  onTap: _selectPotreiro,
                  isLoading: _pageController.isLoading,
                ),
                AnimalLotSelectorField(
                  label: 'Lote',
                  value: _pageController.selectedLoteLabel,
                  onTap: _selectLote,
                  isLoading: _pageController.isLoading,
                ),
                _buildCategoriaDestinoSelect(),
                _buildTextField(
                  controller: _pageController.obsController,
                  label: 'Observações',
                  hint: 'Digite observações sobre a troca',
                  maxLines: 3,
                ),
                _buildAnimalsSummary(),
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
                  text: _pageController.isEdit ? 'Salvar' : 'Adicionar',
                  enabled: _pageController.isFormValid,
                  isLoading: _pageController.isLoading,
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriaDestinoSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoria destino',
          style: TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
        const SizedBox(height: 6),
        AppSelectOverlay<int>(
          value: _pageController.selectedCategoriaDestinoId,
          placeholder: _pageController.selectedCategoriaDestinoLabel,
          options: _pageController.categorias.map(_categoryOption).toList(growable: false),
          onChanged: _pageController.onCategoriaDestinoChanged,
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  AppSelectOption<int> _categoryOption(ListCategoryEntity category) {
    return AppSelectOption<int>(value: category.id, label: category.nome);
  }

  Widget _buildAnimalsSummary() {
    final count = _pageController.isEdit
        ? (widget.troca?.animais.length ?? 0)
        : _pageController.selectedAnimais.length;
    final label = count == 1 ? '1 animal' : '$count animais';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Animais',
          style: TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _pageController.isEdit
              ? count == 0
                    ? null
                    : _openLinkedAnimals
              : _openAnimalsSelection,
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _pageController.isEdit
                        ? '$label vinculados'
                        : count == 0
                        ? 'Selecionar animais'
                        : '$label selecionados',
                    style: const TextStyle(
                      color: Color(0xFF313131),
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (!_pageController.isEdit || count > 0)
                  const Icon(Icons.keyboard_arrow_right, color: Color(0xFF8C8C8C)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
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
    bool readOnly = false,
    VoidCallback? onTap,
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
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
            filled: true,
            fillColor: const Color(0xFFEBEBEB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
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
