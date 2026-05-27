import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/features/animals/presentation/widgets/animal_lot_selector.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/page_controllers/transferencia_form_page_controller.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/pages/transferencia_animais_page.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/pages/transferencia_lotes_page.dart';
import 'package:costeira/features/potreiros/presentation/widgets/potreiro_selector.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TransferenciaFormPage extends StatefulWidget {
  const TransferenciaFormPage({super.key, this.transferencia});

  final TransferenciaUpsertEntity? transferencia;

  @override
  State<TransferenciaFormPage> createState() => _TransferenciaFormPageState();
}

class _TransferenciaFormPageState extends State<TransferenciaFormPage> {
  final TransferenciaFormPageController _pageController =
      Modular.get<TransferenciaFormPageController>();

  @override
  void initState() {
    super.initState();
    _pageController.init(transferencia: widget.transferencia);
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

  Future<void> _openPotreiroDestinoSelection() async {
    final result = await showModalBottomSheet<PotreiroSelectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PotreiroSelectionSheet(
        potreiros: _pageController.potreiros,
        initialSelectedPotreiroId: _pageController.selectedPotreiroDestinoId,
        isLoading: _pageController.isLoading,
        errorMessage: _pageController.errorMessage,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    if (result.shouldAddPotreiro) {
      final created = await Modular.to.pushNamed<Map<String, dynamic>?>(AppRoutes.potreirosAdd);
      if (created?['success'] == true) {
        await _pageController.reloadPotreiros();
        if (mounted) {
          await _openPotreiroDestinoSelection();
        }
      }
      return;
    }
    _pageController.onPotreiroDestinoChanged(result.selectedPotreiroId);
  }

  Future<void> _openLoteDestinoSelection() async {
    final result = await showModalBottomSheet<AnimalLotSelectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AnimalLotSelectionSheet(
        lots: _pageController.lots,
        initialSelectedLotId: _pageController.selectedLoteDestinoId,
        isLoading: _pageController.isLoading,
        errorMessage: _pageController.errorMessage,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    if (result.shouldAddLot) {
      final created = await Modular.to.pushNamed<Map<String, dynamic>?>(AppRoutes.animalLotsAdd);
      if (created?['success'] == true) {
        await _pageController.reloadLotes();
        if (mounted) {
          await _openLoteDestinoSelection();
        }
      }
      return;
    }
    _pageController.onLoteDestinoChanged(result.selectedLotId);
  }

  Future<void> _openSelectionPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _pageController.isTipoAnimais
            ? TransferenciaAnimaisPage(pageController: _pageController)
            : TransferenciaLotesPage(pageController: _pageController),
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
          floatingActionButton: !_pageController.isEdit
              ? FloatingActionButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(64)),
                  onPressed: _openSelectionPage,
                  child: Icon(
                    _pageController.isTipoAnimais ? Icons.pets : Icons.inventory_2_outlined,
                    color: Colors.white,
                  ),
                )
              : null,
          appBar: AppBar(
            backgroundColor: MyColors.colorPrimary,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            title: Text(
              _pageController.isEdit ? 'Editar transferencia' : 'Adicionar transferencia',
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
                  label: 'Data da transferencia',
                  hint: '00/00/0000',
                  readOnly: true,
                  onTap: _selectDate,
                ),
                _buildTipo(),
                PotreiroSelectorField(
                  label: 'Potreiro destino',
                  value: _pageController.selectedPotreiroDestinoLabel,
                  onTap: _openPotreiroDestinoSelection,
                  isLoading: _pageController.isLoading,
                  errorMessage: _pageController.errorMessage,
                ),
                if (_pageController.isTipoLotes)
                  AnimalLotSelectorField(
                    label: 'Lote destino',
                    value: _pageController.selectedLoteDestinoLabel,
                    onTap: _openLoteDestinoSelection,
                    isLoading: _pageController.isLoading,
                    errorMessage: _pageController.errorMessage,
                  ),
                _buildTextField(
                  controller: _pageController.obsController,
                  label: 'Observações',
                  hint: 'Digite observações sobre a transferência',
                  maxLines: 3,
                ),
                if (!_pageController.isEdit) _buildSelectionSummary(),
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

  Widget _buildTipo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo',
          style: TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
        const SizedBox(height: 6),
        IgnorePointer(
          ignoring: _pageController.isEdit,
          child: Opacity(
            opacity: _pageController.isEdit ? 0.65 : 1,
            child: AppSelectOverlay<String>(
              value: _pageController.selectedTipo,
              placeholder: 'Selecione',
              options: TransferenciaFormPageController.tipos
                  .map(
                    (tipo) => AppSelectOption<String>(
                      value: tipo,
                      label: tipo == TransferenciaFormPageController.tipoAnimais
                          ? 'Animais'
                          : 'Lotes',
                    ),
                  )
                  .toList(growable: false),
              onChanged: _pageController.onTipoChanged,
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildSelectionSummary() {
    final count = _pageController.isTipoAnimais
        ? _pageController.selectedAnimais.length
        : _pageController.selectedLotes.length;
    final singular = _pageController.isTipoAnimais ? 'animal' : 'lote';
    final plural = _pageController.isTipoAnimais ? 'animais' : 'lotes';
    final label = count == 1 ? '1 $singular selecionado' : '$count $plural selecionados';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _pageController.isTipoAnimais ? 'Animais' : 'Lotes',
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
          onTap: _openSelectionPage,
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
                    count == 0
                        ? (_pageController.isTipoAnimais
                              ? 'Selecionar animais por brinco'
                              : 'Selecionar lotes por nome')
                        : label,
                    style: const TextStyle(
                      color: Color(0xFF313131),
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
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
