import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/core/input_formatters/fixed_two_decimal_input_formatter.dart';
import 'package:costeira/features/movimentacoes/domain/entities/nascimento_entity.dart';
import 'package:costeira/features/movimentacoes/nascimento/presentation/page_controllers/nascimento_form_page_controller.dart';
import 'package:costeira/features/movimentacoes/nascimento/presentation/pages/nascimento_animais_vinculados_page.dart';
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
    final day = picked.day.toString().padLeft(2, '0');
    final month = picked.month.toString().padLeft(2, '0');
    _pageController.dataController.text = '$day/$month/${picked.year}';
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
                  : 'Registrar nascimento',
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
                  _buildPotreiroSelect(destination: false),
                  _buildLotSelect(destination: false),
                  if (!_pageController.isEdit) _buildLotHint(),
                  if (_pageController.showMaeSelect &&
                      !_pageController.hasMaes &&
                      !_pageController.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 18),
                      child: Text(
                        'Nenhuma fêmea prenhe neste piquete/lote.',
                        style: TextStyle(
                          color: Color(0xFF8C8C8C),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  if (_pageController.showBirthFields) ...[
                    if (!_pageController.isEdit) _buildMaeSelect(),
                    _buildTextField(
                      controller: _pageController.dataController,
                      label: 'Data de nascimento',
                      hint: '00/00/0000',
                      readOnly: true,
                      onTap: _selectDate,
                    ),
                    if (!_pageController.isEdit) _buildSexoCria(),
                    _buildTextField(
                      controller: _pageController.pesoController,
                      label: 'Peso ao nascer (kg)',
                      hint: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: const [_pesoFormatter],
                    ),
                    if (!_pageController.isEdit)
                      _buildTextField(
                        controller: _pageController.brincoCriaController,
                        label: 'Brinco da cria',
                        hint: 'Ex: 2001',
                      ),
                    if (!_pageController.isEdit) ...[
                      _buildPotreiroSelect(destination: true),
                      _buildLotSelect(destination: true),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 18),
                        child: Text(
                          'Destino só se a mãe e a cria já forem direto pra outro piquete/lote.',
                          style: TextStyle(
                            color: Color(0xFF8C8C8C),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    _buildTextField(
                      controller: _pageController.obsController,
                      label: 'Observações',
                      hint: 'Anotações gerais...',
                      maxLines: 3,
                    ),
                  ],
                  if (_pageController.isEdit) _buildLinkedAnimals(),
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
                    text: _pageController.isEdit
                        ? 'Salvar'
                        : 'Registrar nascimento',
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

  Widget _buildLotHint() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 18),
      child: Text(
        'Só aparecem lotes com pelo menos uma fêmea prenhe neste piquete.',
        style: TextStyle(color: Color(0xFF8C8C8C), fontSize: 12),
      ),
    );
  }

  Widget _buildPotreiroSelect({required bool destination}) {
    final value = destination
        ? (_pageController.destPotreiroId ?? -1)
        : _pageController.selectedPotreiroId;
    return _buildSelect<int>(
      label: destination ? 'Piquete de destino' : 'Piquete (origem)',
      value: value,
      enabled: destination || !_pageController.isLoading,
      placeholder: destination
          ? 'Mesma do piquete de origem'
          : 'Selecionar piquete',
      options: [
        if (destination)
          const AppSelectOption<int>(
            value: -1,
            label: 'Mesma do piquete de origem',
          ),
        ..._pageController.potreiros.map(
          (item) => AppSelectOption<int>(value: item.id, label: item.nome),
        ),
      ],
      onChanged: (selected) {
        final id = selected == null || selected < 0 ? null : selected;
        if (destination) {
          _pageController.onDestPotreiroChanged(id);
        } else {
          _pageController.onPotreiroChanged(id);
        }
      },
    );
  }

  Widget _buildLotSelect({required bool destination}) {
    final lots = destination
        ? _pageController.destinationLots
        : _pageController.isEdit
        ? _pageController.allLots
        : _pageController.eligibleLots;
    final enabled = destination
        ? true
        : _pageController.isEdit ||
              (_pageController.selectedPotreiroId != null && lots.isNotEmpty);
    final value = destination
        ? (_pageController.destLotId ?? -1)
        : _pageController.selectedLotId;
    return _buildSelect<int>(
      label: destination ? 'Lote de destino' : 'Lote (origem)',
      value: value,
      enabled: enabled,
      placeholder: destination
          ? 'Mesmo do lote de origem'
          : _pageController.selectedLotLabel,
      options: [
        if (destination)
          const AppSelectOption<int>(
            value: -1,
            label: 'Mesmo do lote de origem',
          ),
        ...lots.map(
          (item) => AppSelectOption<int>(value: item.id, label: item.nome),
        ),
      ],
      onChanged: (selected) {
        final id = selected == null || selected < 0 ? null : selected;
        if (destination) {
          _pageController.onDestLotChanged(id);
        } else {
          _pageController.onLotChanged(id);
        }
      },
    );
  }

  Widget _buildMaeSelect() {
    return _buildSelect<int>(
      label: 'Brinco da mãe',
      value: _pageController.selectedMaeId,
      placeholder: 'Selecionar brinco da mãe',
      options: _pageController.maes
          .map(
            (animal) => AppSelectOption<int>(
              value: animal.id,
              label: animal.brinco!.trim(),
            ),
          )
          .toList(growable: false),
      onChanged: _pageController.onMaeChanged,
    );
  }

  Widget _buildSexoCria() {
    return _buildSelect<int>(
      label: 'Sexo da cria',
      value: _pageController.selectedSexoCria,
      placeholder: 'Selecionar',
      options: const [
        AppSelectOption<int>(value: 1, label: 'Macho — Terneiro'),
        AppSelectOption<int>(value: 2, label: 'Fêmea — Terneira'),
      ],
      onChanged: _pageController.onSexoCriaChanged,
    );
  }

  Widget _buildLinkedAnimals() {
    final count = widget.nascimento?.animais.length ?? 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: count == 0 ? null : _openLinkedAnimals,
        child: Text(
          count == 1 ? '1 animal vinculado' : '$count animais vinculados',
          style: const TextStyle(
            color: MyColors.colorPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSelect<T>({
    required String label,
    required T? value,
    required String placeholder,
    required List<AppSelectOption<T>> options,
    required ValueChanged<T?> onChanged,
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
          ),
        ),
        const SizedBox(height: 6),
        AppSelectOverlay<T>(
          value: value,
          placeholder: placeholder,
          enabled: enabled && options.isNotEmpty,
          options: options,
          onChanged: onChanged,
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
