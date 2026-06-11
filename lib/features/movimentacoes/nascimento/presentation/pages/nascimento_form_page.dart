import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/core/input_formatters/fixed_two_decimal_input_formatter.dart';
import 'package:costeira/features/animals/presentation/widgets/animal_lot_selector.dart';
import 'package:costeira/features/movimentacoes/domain/entities/nascimento_entity.dart';
import 'package:costeira/features/movimentacoes/nascimento/presentation/page_controllers/nascimento_form_page_controller.dart';
import 'package:costeira/features/movimentacoes/nascimento/presentation/pages/nascimento_animais_page.dart';
import 'package:costeira/features/movimentacoes/nascimento/presentation/pages/nascimento_animais_vinculados_page.dart';
import 'package:costeira/features/potreiros/presentation/widgets/potreiro_selector.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';

class NascimentoFormPage extends StatefulWidget {
  const NascimentoFormPage({super.key, this.nascimento});

  final NascimentoEntity? nascimento;

  @override
  State<NascimentoFormPage> createState() => _NascimentoFormPageState();
}

class _NascimentoFormPageState extends State<NascimentoFormPage> {
  static const _pesoFormatter = FixedTwoDecimalInputFormatter();

  final NascimentoFormPageController _pageController =
      Modular.get<NascimentoFormPageController>();

  @override
  void initState() {
    super.initState();
    _pageController.init(nascimento: widget.nascimento);
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

  Future<void> _openPotreiroSelection() async {
    final result = await showModalBottomSheet<PotreiroSelectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        top: false,
        child: PotreiroSelectionSheet(
          potreiros: _pageController.potreiros,
          initialSelectedPotreiroId: _pageController.selectedPotreiroId,
          isLoading: _pageController.isLoading,
          errorMessage: _pageController.errorMessage,
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    if (result.shouldAddPotreiro) {
      final created = await Modular.to.pushNamed<Map<String, dynamic>?>(
        AppRoutes.potreirosAdd,
      );
      if (created?['success'] == true) {
        await _pageController.reloadPotreiros();
        if (mounted) {
          await _openPotreiroSelection();
        }
      }
      return;
    }
    _pageController.onPotreiroChanged(result.selectedPotreiroId);
  }

  Future<void> _openLotSelection() async {
    final result = await showModalBottomSheet<AnimalLotSelectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        top: false,
        child: AnimalLotSelectionSheet(
          lots: _pageController.lots,
          initialSelectedLotId: _pageController.selectedLotId,
          isLoading: _pageController.isLoading,
          errorMessage: _pageController.errorMessage,
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    if (result.shouldAddLot) {
      final created = await Modular.to.pushNamed<Map<String, dynamic>?>(
        AppRoutes.animalLotsAdd,
      );
      if (created?['success'] == true) {
        await _pageController.reloadLots();
        if (mounted) {
          await _openLotSelection();
        }
      }
      return;
    }
    _pageController.onLotChanged(result.selectedLotId);
  }

  Future<void> _openAnimalSelection(NascimentoAnimalSelectionType type) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NascimentoAnimaisPage(pageController: _pageController, type: type),
      ),
    );
    _pageController.animalFilterController.clear();
  }

  Future<void> _openLinkedAnimals() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NascimentoAnimaisVinculadosPage(
          animais: widget.nascimento?.animais ?? const [],
        ),
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
              _pageController.isEdit
                  ? 'Editar nascimento'
                  : 'Adicionar nascimento',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PotreiroSelectorField(
                    label: 'Potreiro',
                    value: _pageController.selectedPotreiroLabel,
                    onTap: _openPotreiroSelection,
                    isLoading: _pageController.isLoading,
                    errorMessage: _pageController.errorMessage,
                  ),
                  AnimalLotSelectorField(
                    label: 'Lote',
                    value: _pageController.selectedLotLabel,
                    onTap: _openLotSelection,
                    isLoading: _pageController.isLoading,
                    errorMessage: _pageController.errorMessage,
                  ),
                  _buildTextField(
                    controller: _pageController.dataController,
                    label: 'Data do nascimento',
                    hint: '00/00/0000',
                    readOnly: true,
                    onTap: _selectDate,
                  ),
                  _buildTextField(
                    controller: _pageController.pesoController,
                    label: 'Peso do terneiro',
                    hint: '35,50',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: const [_pesoFormatter],
                  ),
                  _buildTextField(
                    controller: _pageController.obsController,
                    label: 'Observações',
                    hint: 'Digite observações sobre o nascimento',
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
                    enabled:
                        !_pageController.isLoading &&
                        _pageController.isFormValid,
                    isLoading: _pageController.isLoading,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimalsSummary() {
    if (_pageController.isEdit) {
      final count = widget.nascimento?.animais.length ?? 0;
      final label = count == 1
          ? '1 animal vinculado'
          : '$count animais vinculados';
      return _buildSelectionTile(
        label: 'Animais',
        value: label,
        enabled: count > 0,
        onTap: _openLinkedAnimals,
      );
    }

    return Column(
      children: [
        _buildSelectionTile(
          label: 'Matriz',
          value: _pageController.selectedMatrizLabel,
          enabled: _pageController.canSelectAnimals,
          onTap: () =>
              _openAnimalSelection(NascimentoAnimalSelectionType.matriz),
        ),
        _buildSelectionTile(
          label: 'Terneiro',
          value: _pageController.selectedTerneiroLabel,
          enabled: _pageController.canSelectAnimals,
          onTap: () =>
              _openAnimalSelection(NascimentoAnimalSelectionType.terneiro),
        ),
      ],
    );
  }

  Widget _buildSelectionTile({
    required String label,
    required String value,
    required VoidCallback onTap,
    bool enabled = true,
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
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled ? onTap : null,
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
                    value,
                    style: const TextStyle(
                      color: Color(0xFF313131),
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (enabled)
                  const Icon(
                    Icons.keyboard_arrow_right,
                    color: Color(0xFF8C8C8C),
                  ),
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
}
