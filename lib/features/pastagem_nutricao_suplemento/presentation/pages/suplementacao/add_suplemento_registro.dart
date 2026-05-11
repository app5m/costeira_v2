import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/controllers/suplemento_registro_form_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AddSuplementoRegistro extends StatefulWidget {
  const AddSuplementoRegistro({
    super.key,
    required this.suplemento,
    this.registro,
  });

  final Suplemento suplemento;
  final SuplementoRegistro? registro;

  @override
  State<AddSuplementoRegistro> createState() => _AddSuplementoRegistroState();
}

class _AddSuplementoRegistroState extends State<AddSuplementoRegistro> {
  late final SuplementoRegistroFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<SuplementoRegistroFormController>()
      ..addListener(_sync);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _controller.init(
        suplemento: widget.suplemento,
        registro: widget.registro,
      ),
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
        message: _controller.errorMessage ?? 'Erro ao salvar registro.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.registro != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          isEditing ? 'Editar Registro' : 'Adicionar Registro',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldShell(
              label: 'Tipo',
              child: AppSelectOverlay<int>(
                value: _controller.selectedTipo,
                placeholder: 'Selecione',
                options: const [
                  AppSelectOption(value: 1, label: 'Reabastecimento'),
                  AppSelectOption(value: 2, label: 'Utilização'),
                ],
                onChanged: _controller.onTipoChanged,
              ),
            ),
            _FieldShell(
              label: 'Data',
              child: TextField(
                controller: _controller.dataController,
                keyboardType: TextInputType.datetime,
                readOnly: true,
                onTap: () => _pickDate(_controller.dataController),
                decoration: _inputDecoration('10/06/2026').copyWith(
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                ),
              ),
            ),
            _FieldShell(
              label: 'Quantidade',
              child: Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: _controller.decrementQuantidade,
                    style: IconButton.styleFrom(foregroundColor: Colors.black),
                    icon: const Icon(Icons.remove, color: Colors.black),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller.quantidadeController,
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                      ],
                      decoration: _inputDecoration(
                        '00 kg',
                      ).copyWith(suffixText: 'kg'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: _controller.incrementQuantidade,
                    style: IconButton.styleFrom(foregroundColor: Colors.black),
                    icon: const Icon(Icons.add, color: Colors.black),
                  ),
                ],
              ),
            ),
            if (_controller.errorMessage != null) ...[
              Text(
                _controller.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
              const SizedBox(height: 8),
            ],
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
                onPressed: _controller.isFormValid && !_controller.isLoading
                    ? _submit
                    : null,
                child: _controller.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
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
