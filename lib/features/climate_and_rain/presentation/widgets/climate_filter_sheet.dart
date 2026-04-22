import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ClimateFilterSheetResult {
  const ClimateFilterSheetResult({
    required this.dataIn,
    required this.dataOut,
    required this.shouldClear,
  });

  final String? dataIn;
  final String? dataOut;
  final bool shouldClear;
}

class ClimateFilterSheet extends StatefulWidget {
  const ClimateFilterSheet({super.key, this.initialDataIn, this.initialDataOut});

  final String? initialDataIn;
  final String? initialDataOut;

  @override
  State<ClimateFilterSheet> createState() => _ClimateFilterSheetState();
}

class _ClimateFilterSheetState extends State<ClimateFilterSheet> {
  late final TextEditingController _dataInController;
  late final TextEditingController _dataOutController;

  String? get _initialDataIn => _normalizedValue(widget.initialDataIn);
  String? get _initialDataOut => _normalizedValue(widget.initialDataOut);
  String? get _currentDataIn => _normalizedValue(_dataInController.text);
  String? get _currentDataOut => _normalizedValue(_dataOutController.text);

  bool get _hasCurrentFilters =>
      _currentDataIn != null || _currentDataOut != null;

  bool get _hadInitialFilters =>
      _initialDataIn != null || _initialDataOut != null;

  bool get _hasChanges =>
      _currentDataIn != _initialDataIn || _currentDataOut != _initialDataOut;

  bool get _canApply => _hasCurrentFilters && _hasChanges;

  bool get _canClear => _hasCurrentFilters && (_hasChanges || _hadInitialFilters);

  @override
  void initState() {
    super.initState();
    _dataInController = TextEditingController(text: widget.initialDataIn ?? '');
    _dataOutController = TextEditingController(text: widget.initialDataOut ?? '');
    _dataInController.addListener(_handleFilterChanged);
    _dataOutController.addListener(_handleFilterChanged);
  }

  @override
  void dispose() {
    _dataInController.removeListener(_handleFilterChanged);
    _dataOutController.removeListener(_handleFilterChanged);
    _dataInController.dispose();
    _dataOutController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required TextEditingController controller}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _tryParse(controller.text) ?? now,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 20),
    );

    if (picked == null) {
      return;
    }

    controller.text = _formatDate(picked);
    setState(() {});
  }

  void _handleFilterChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Modular.to.pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFF313131),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Filtrar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF313131),
                        fontSize: 20,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DateField(
                    label: 'Data inicial',
                    controller: _dataInController,
                    onTap: () => _pickDate(controller: _dataInController),
                  ),
                  const SizedBox(height: 24),
                  _DateField(
                    label: 'Data final',
                    controller: _dataOutController,
                    onTap: () => _pickDate(controller: _dataOutController),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              CustomButton(
                onPressed: () {
                  Modular.to.pop(
                    ClimateFilterSheetResult(
                      dataIn: _currentDataIn,
                      dataOut: _currentDataOut,
                      shouldClear: false,
                    ),
                  );
                },
                text: 'Filtrar',
                enabled: _canApply,
                height: 56,
                borderRadius: 16,
              ),
              const SizedBox(height: 12),
              CustomButton(
                onPressed: () {
                  Modular.to.pop(
                    const ClimateFilterSheetResult(
                      dataIn: null,
                      dataOut: null,
                      shouldClear: true,
                    ),
                  );
                },
                text: 'Limpar',
                enabled: _canClear,
                backgroundColor: Colors.white,
                disabledColor: Colors.white,
                textColor: MyColors.colorPrimary,
                disabledTextColor: MyColors.gray,
                borderColor: MyColors.colorPrimary,
                height: 56,
                borderRadius: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _normalizedValue(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.controller, required this.onTap});

  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;

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
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: '00/00/0000',
            filled: true,
            fillColor: const Color(0xFFF4F4F4),
            suffixIcon: const Icon(Icons.calendar_today_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

DateTime? _tryParse(String value) {
  final parts = value.split('/');
  if (parts.length != 3) {
    return null;
  }

  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) {
    return null;
  }

  return DateTime(year, month, day);
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  return '$day/$month/$year';
}
