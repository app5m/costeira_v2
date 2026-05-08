import 'dart:math' as math;

import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/presentation/controllers/add_insumo_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AddInsumo extends StatefulWidget {
  const AddInsumo({super.key});

  @override
  State<AddInsumo> createState() => _AddInsumoState();
}

class _AddInsumoState extends State<AddInsumo> {
  final AddInsumoController _controller = Modular.get<AddInsumoController>();

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    try {
      final result = await _controller.submit();
      if (!mounted) return;

      if (result?.isSuccess == true) {
        Modular.to.pop({'success': true, 'message': result!.message});
        return;
      }

      AppSnackBar.show(
        context: context,
        message: _controller.errorMessage ?? 'Preencha os campos obrigatorios.',
        isError: true,
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message:
            _controller.errorMessage ?? 'Nao foi possivel salvar o insumo.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
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
              'Adicionar insumo',
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
                if (_controller.isLoading &&
                    _controller.tipoInsumos.isEmpty &&
                    _controller.unidades.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  _buildTipoDropdown(),
                  if (_controller.shouldShowSuplemento)
                    _buildIntReferenceDropdown(
                      label: 'Tipo de suplemento',
                      value: _controller.selectedSuplementoId,
                      items: _controller.suplementos,
                      onChanged: _controller.onSuplementoChanged,
                      isRequired: false,
                    ),
                  _buildTextField(
                    controller: _controller.nomeController,
                    label: 'Nome',
                    hint: 'Ex: Medicamento 1',
                  ),
                  _buildIntReferenceDropdown(
                    label: 'Unidade de medida',
                    value: _controller.selectedUnidadeId,
                    items: _controller.unidades,
                    onChanged: _controller.onUnidadeChanged,
                  ),
                  _buildTextField(
                    controller: _controller.valorUnidadeController,
                    label: 'Valor por unidade',
                    hint: '10,50',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                    ],
                  ),
                  _buildQuantityField(
                    controller: _controller.qtdTotalController,
                    label: 'Quantidade',
                    hint: '5',
                  ),
                  _buildTextField(
                    controller: _controller.dataValidadeController,
                    label: 'Data de validade',
                    hint: '30/12/2026',
                    keyboardType: TextInputType.datetime,
                  ),
                  _buildTextField(
                    controller: _controller.obsController,
                    label: 'Observacoes',
                    hint: 'Estoque inicial',
                    maxLines: 3,
                  ),
                  if (_controller.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _controller.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.colorPrimary,
                        disabledBackgroundColor: const Color(0xFFBDBDBD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed:
                          _controller.isLoading || !_controller.isFormValid
                          ? null
                          : _submit,
                      child: _controller.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Adicionar',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                                height: 1.29,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTipoDropdown() {
    final value =
        _controller.tipoInsumos.any(
          (item) => item.id?.toString() == _controller.selectedTipoInsumo,
        )
        ? _controller.selectedTipoInsumo
        : null;

    return _buildFieldShell(
      label: 'Tipo de insumo',
      child: AppSelectOverlay<String>(
        value: value,
        placeholder: 'Selecione',
        options: _controller.tipoInsumos
            .where((item) => item.id?.toString().isNotEmpty ?? false)
            .map(
              (item) => AppSelectOption<String>(
                value: item.id.toString(),
                label: item.nome,
              ),
            )
            .toList(growable: false),
        enabled: _controller.tipoInsumos.isNotEmpty,
        onChanged: _controller.onTipoChanged,
      ),
    );
  }

  Widget _buildIntReferenceDropdown({
    required String label,
    required int? value,
    required List<InsumoReferenceEntity> items,
    required void Function(int? value) onChanged,
    bool isRequired = true,
  }) {
    final typedItems = items
        .where((item) => int.tryParse(item.id?.toString() ?? '') != null)
        .toList(growable: false);
    final effectiveValue =
        typedItems.any((item) => int.tryParse(item.id.toString()) == value)
        ? value
        : null;

    return _buildFieldShell(
      label: isRequired ? label : '$label (opcional)',
      child: AppSelectOverlay<int>(
        value: effectiveValue,
        placeholder: 'Selecione',
        options: typedItems
            .map(
              (item) => AppSelectOption<int>(
                value: int.parse(item.id.toString()),
                label: item.nome,
              ),
            )
            .toList(growable: false),
        enabled: typedItems.isNotEmpty,
        onChanged: onChanged,
      ),
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
    return _buildFieldShell(
      label: label,
      child: TextField(
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
        decoration: _inputDecoration(hint),
      ),
    );
  }

  Widget _buildQuantityField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return _buildFieldShell(
      label: label,
      child: Row(
        children: [
          IconButton.filledTonal(
            onPressed: () => _changeQuantity(controller, -1),
            style: IconButton.styleFrom(foregroundColor: Colors.black),
            icon: const Icon(Icons.remove, color: Colors.black),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
              ],
              style: const TextStyle(
                color: Color(0xFF313131),
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                height: 1.50,
                letterSpacing: 0.10,
              ),
              decoration: _inputDecoration(hint),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: () => _changeQuantity(controller, 1),
            style: IconButton.styleFrom(foregroundColor: Colors.black),
            icon: const Icon(Icons.add, color: Colors.black),
          ),
        ],
      ),
    );
  }

  void _changeQuantity(TextEditingController controller, double delta) {
    final current =
        double.tryParse(controller.text.trim().replaceAll(',', '.')) ?? 0;
    final next = math.max(0, current + delta);
    controller.text = next % 1 == 0
        ? next.toInt().toString()
        : next.toStringAsFixed(2).replaceAll('.', ',');
  }

  Widget _buildFieldShell({required String label, required Widget child}) {
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
        child,
        const SizedBox(height: 18),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }
}
