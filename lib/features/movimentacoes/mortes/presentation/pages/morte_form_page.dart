import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/features/movimentacoes/domain/entities/morte_entity.dart';
import 'package:costeira/features/movimentacoes/mortes/presentation/page_controllers/morte_form_page_controller.dart';
import 'package:costeira/features/movimentacoes/mortes/presentation/pages/morte_animais_page.dart';
import 'package:costeira/features/movimentacoes/mortes/presentation/pages/morte_animais_vinculados_page.dart';
import 'package:costeira/features/potreiros/presentation/widgets/potreiro_selector.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class MorteFormPage extends StatefulWidget {
  const MorteFormPage({super.key, this.morte});

  final MorteEntity? morte;

  @override
  State<MorteFormPage> createState() => _MorteFormPageState();
}

class _MorteFormPageState extends State<MorteFormPage> {
  final MorteFormPageController _pageController =
      Modular.get<MorteFormPageController>();

  @override
  void initState() {
    super.initState();
    _pageController.init(morte: widget.morte);
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

  Future<void> _openAnimals() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MorteAnimaisPage(pageController: _pageController),
      ),
    );
  }

  Future<void> _openLinkedAnimals() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MorteAnimaisVinculadosPage(
          animais: widget.morte?.animais ?? const [],
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
              _pageController.isEdit ? 'Editar morte' : 'Adicionar morte',
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
                  _buildDateField(),
                  if (!_pageController.isEdit ||
                      widget.morte?.animais.isNotEmpty == true)
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
          ),
        );
      },
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data da morte',
          style: TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _pageController.dataController,
          readOnly: true,
          onTap: _selectDate,
          decoration: InputDecoration(
            hintText: '00/00/0000',
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

  Widget _buildAnimalsSummary() {
    final morte = widget.morte;
    final hasLinkedAnimals = morte?.animais.isNotEmpty == true;
    final count = _pageController.isEdit
        ? (morte?.qtdAnimais ?? morte?.animais.length ?? 0)
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
          onTap: _pageController.isEdit
              ? hasLinkedAnimals
                    ? _openLinkedAnimals
                    : null
              : _openAnimals,
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
                        ? 'Selecionar animais que morreram'
                        : '$count animais selecionados',
                    style: const TextStyle(
                      color: Color(0xFF313131),
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (!_pageController.isEdit || hasLinkedAnimals)
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
}
