import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/core/input_formatters/fixed_two_decimal_input_formatter.dart';
import 'package:costeira/features/animals/presentation/widgets/animal_lot_selector.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/page_controllers/compra_form_page_controller.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/pages/compra_animais_page.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/pages/compra_animais_lista_page.dart';
import 'package:costeira/features/movimentacoes/domain/entities/compra_entity.dart';
import 'package:costeira/features/potreiros/presentation/widgets/potreiro_selector.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';

class CompraFormPage extends StatefulWidget {
  const CompraFormPage({super.key, this.compra});

  final CompraEntity? compra;

  @override
  State<CompraFormPage> createState() => _CompraFormPageState();
}

class _CompraFormPageState extends State<CompraFormPage> {
  static const _moneyFormatter = FixedTwoDecimalInputFormatter();

  final CompraFormPageController _pageController =
      Modular.get<CompraFormPageController>();

  @override
  void initState() {
    super.initState();
    _pageController.init(compra: widget.compra);
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
    _pageController.onLotChanged(result.selectedLotId);
  }

  Future<void> _openAnimalsManager() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompraAnimaisPage(pageController: _pageController),
      ),
    );
  }

  Future<void> _openAnimalsList() async {
    final compra = widget.compra;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => compra == null
            ? CompraAnimaisListaPage.draft(pageController: _pageController)
            : CompraAnimaisListaPage.saved(animais: compra.animais),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(64),
                  ),
                  onPressed: _openAnimalsManager,
                  child: const Icon(Icons.pets, color: Colors.white),
                )
              : null,
          appBar: AppBar(
            backgroundColor: MyColors.colorPrimary,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            title: Text(
              _pageController.isEdit ? 'Editar compra' : 'Adicionar compra',
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
                  errorMessage: _pageController.errorMessage,
                ),
                _buildTextField(
                  controller: _pageController.dataController,
                  label: 'Data da compra',
                  hint: '00/00/0000',
                  readOnly: true,
                  onTap: _selectDate,
                ),
                _buildTipoCompra(),
                _buildTextField(
                  controller: _pageController.valorUnitarioController,
                  label: 'Valor unitario',
                  hint: '2500,00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: const [_moneyFormatter],
                ),
                _buildTextField(
                  controller: _pageController.fornecedorController,
                  label: 'Fornecedor',
                  hint: 'Digite o nome do fornecedor',
                ),
                _buildTextField(
                  controller: _pageController.municipioController,
                  label: 'Municipio',
                  hint: 'Digite o municipio da compra',
                ),
                _buildTextField(
                  controller: _pageController.obsController,
                  label: 'Observações',
                  hint: 'Digite observações sobre a compra',
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

  Widget _buildTipoCompra() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de compra',
          style: TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
        const SizedBox(height: 6),
        AppSelectOverlay<String>(
          value: _pageController.selectedTipoCompra,
          placeholder: 'Selecione',
          options: CompraFormPageController.tiposCompra
              .map(
                (tipo) => AppSelectOption<String>(
                  value: tipo,
                  label: tipo == 'kg' ? 'KG' : 'Por cabeça',
                ),
              )
              .toList(growable: false),
          onChanged: _pageController.onTipoCompraChanged,
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildAnimalsSummary() {
    final count = _pageController.isEdit
        ? (widget.compra?.animais.length ?? 0)
        : _pageController.animais.length;
    final label = count == 1 ? '1 animal' : '$count animais';
    final statusLabel = count == 1 ? 'adicionado' : 'adicionados';
    final linkedLabel = count == 1 ? 'vinculado' : 'vinculados';

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
                    : _openAnimalsList
              : count == 0
              ? _openAnimalsManager
              : _openAnimalsManager,
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
                        ? '$label $linkedLabel'
                        : count == 0
                        ? 'Gerenciar animais da compra'
                        : '$label $statusLabel',
                    style: const TextStyle(
                      color: Color(0xFF313131),
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (!_pageController.isEdit || count > 0)
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
