import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/controllers/suplemento_form_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AddSuplemento extends StatefulWidget {
  const AddSuplemento({super.key, this.suplemento});

  final Suplemento? suplemento;

  @override
  State<AddSuplemento> createState() => _AddSuplementoState();
}

class _AddSuplementoState extends State<AddSuplemento> {
  late final SuplementoFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<SuplementoFormController>()..addListener(_sync);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _controller.init(suplemento: widget.suplemento),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    if (mounted) setState(() {});
  }

  Future<void> _submit() async {
    try {
      final result = await _controller.submit();
      if (!mounted || result == null) return;
      AppSnackBar.show(
        context: context,
        message: result.message,
        isError: false,
      );
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message: _controller.errorMessage ?? 'Erro ao salvar.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.suplemento != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          isEditing ? 'Editar Supl. e Consumo' : 'Adicionar Supl. e Consumo',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DropdownField<int>(
                    label: 'Potreiro',
                    value: _controller.selectedPotreiroId,
                    options: _controller.potreiros
                        .map(
                          (item) => AppSelectOption<int>(
                            value: item.id,
                            label: item.nome,
                          ),
                        )
                        .toList(),
                    onChanged: _controller.onPotreiroChanged,
                  ),
                  if (_controller.selectedPotreiroId != null)
                    _DropdownField<int>(
                      label: 'Lote',
                      value: _controller.selectedLoteId,
                      placeholder: _controller.lotesDisponiveis.isEmpty
                          ? 'Nenhum lote encontrado'
                          : 'Selecione',
                      options: _controller.lotesDisponiveis
                          .map(
                            (item) => AppSelectOption<int>(
                              value: item.id,
                              label: item.nome,
                            ),
                          )
                          .toList(),
                      onChanged: _controller.onLoteChanged,
                    ),
                  _DropdownField<int>(
                    label: 'Produto utilizado',
                    value: _controller.selectedProdutoId,
                    options: _controller.produtos
                        .map(
                          (item) => AppSelectOption<int>(
                            value: item.id,
                            label: _controller.produtoLabel(item),
                          ),
                        )
                        .toList(),
                    onChanged: _controller.onProdutoChanged,
                  ),
                  _TextField(
                    label: 'Data',
                    hint: '01/06/2026',
                    controller: _controller.dataController,
                    keyboardType: TextInputType.datetime,
                    readOnly: true,
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                    onTap: () => _pickDate(_controller.dataController),
                  ),
                  _QuantityField(
                    label: 'Quantidade',
                    controller: _controller.quantidadeController,
                    onMinus: _controller.decrementQuantidade,
                    onPlus: _controller.incrementQuantidade,
                  ),
                  if (_controller.errorMessage != null) ...[
                    const SizedBox(height: 4),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _controller.isFormValid ? _submit : null,
                      child: const Text(
                        'Salvar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final initialDate = _parseDate(controller.text) ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null) return;
    controller.text = _formatDate(selected);
  }

  DateTime? _parseDate(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.placeholder = 'Selecione',
  });

  final String label;
  final T? value;
  final List<AppSelectOption<T>> options;
  final ValueChanged<T?> onChanged;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      label: label,
      child: AppSelectOverlay<T>(
        value: options.any((item) => item.value == value) ? value : null,
        placeholder: placeholder,
        options: options,
        enabled: options.isNotEmpty,
        onChanged: onChanged,
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.readOnly = false,
    this.suffixIcon,
    this.onTap,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool readOnly;
  final Widget? suffixIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      label: label,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: _inputDecoration(hint).copyWith(suffixIcon: suffixIcon),
      ),
    );
  }
}

class _QuantityField extends StatelessWidget {
  const _QuantityField({
    required this.label,
    required this.controller,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      label: label,
      child: Row(
        children: [
          IconButton.filledTonal(
            onPressed: onMinus,
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
              decoration: _inputDecoration('00 kg').copyWith(suffixText: 'kg'),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: onPlus,
            style: IconButton.styleFrom(foregroundColor: Colors.black),
            icon: const Icon(Icons.add, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class _FieldShell extends StatelessWidget {
  const _FieldShell({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
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
