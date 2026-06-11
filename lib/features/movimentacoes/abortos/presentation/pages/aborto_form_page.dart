import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/features/animals/presentation/widgets/animal_lot_selector.dart';
import 'package:costeira/features/movimentacoes/abortos/presentation/page_controllers/aborto_form_page_controller.dart';
import 'package:costeira/features/movimentacoes/abortos/presentation/pages/aborto_animais_page.dart';
import 'package:costeira/features/movimentacoes/domain/entities/aborto_entity.dart';
import 'package:costeira/features/potreiros/presentation/widgets/potreiro_selector.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AbortoFormPage extends StatefulWidget {
  const AbortoFormPage({super.key, this.aborto});

  final AbortoEntity? aborto;

  @override
  State<AbortoFormPage> createState() => _AbortoFormPageState();
}

class _AbortoFormPageState extends State<AbortoFormPage> {
  final AbortoFormPageController _pageController =
      Modular.get<AbortoFormPageController>();

  @override
  void initState() {
    super.initState();
    _pageController.init(aborto: widget.aborto);
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
      if (created?['success'] == true) {
        await _pageController.reloadLots();
        if (mounted) {
          await _openLotSelection();
        }
      }
      return;
    }
    await _pageController.onLotChanged(result.selectedLotId);
  }

  Future<void> _openAnimals() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AbortoAnimaisPage(pageController: _pageController),
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
              _pageController.isEdit ? 'Editar aborto' : 'Adicionar aborto',
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
                  errorMessage: null,
                ),
                _buildDateField(),
                _buildAnimalsSummary(),
                _buildObsField(),
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
                  enabled: !_pageController.isLoading,
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

  Widget _buildDateField() {
    return _FieldContainer(
      label: 'Data do aborto',
      child: TextField(
        controller: _pageController.dataController,
        readOnly: true,
        onTap: _selectDate,
        decoration: _inputDecoration('00/00/0000'),
      ),
    );
  }

  Widget _buildObsField() {
    return _FieldContainer(
      label: 'Observações',
      child: TextField(
        controller: _pageController.obsController,
        minLines: 3,
        maxLines: 5,
        decoration: _inputDecoration('Ex: Registro de aborto'),
      ),
    );
  }

  Widget _buildAnimalsSummary() {
    final count = _pageController.isEdit
        ? (widget.aborto?.animais.length ?? 0)
        : _pageController.selectedAnimais.length;

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
          onTap: _pageController.isEdit ? null : _openAnimals,
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
                        ? '$count animais vinculados'
                        : count == 0
                        ? 'Selecionar animais'
                        : '$count animais selecionados',
                    style: const TextStyle(
                      color: Color(0xFF313131),
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFEBEBEB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _FieldContainer extends StatelessWidget {
  const _FieldContainer({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
        child,
        const SizedBox(height: 18),
      ],
    );
  }
}
