import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class PotreiroFilterSheetResult {
  const PotreiroFilterSheetResult._({
    this.shouldClear = false,
    this.statusAtual,
  });

  const PotreiroFilterSheetResult.apply({String? statusAtual})
    : this._(statusAtual: statusAtual);

  const PotreiroFilterSheetResult.clear() : this._(shouldClear: true);

  final bool shouldClear;
  final String? statusAtual;
}

class PotreiroFilterSheet extends StatefulWidget {
  const PotreiroFilterSheet({super.key, this.initialStatusAtual});

  final String? initialStatusAtual;

  @override
  State<PotreiroFilterSheet> createState() => _PotreiroFilterSheetState();
}

class _PotreiroFilterSheetState extends State<PotreiroFilterSheet> {
  static const List<String> _statusOptions = ['PECUARIA', 'LAVOURA'];

  String? _selectedStatus;

  bool get _hasAnyFilter => (_selectedStatus?.trim().isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatusAtual;
  }

  void _applyFilters() {
    Modular.to.pop(
      PotreiroFilterSheetResult.apply(statusAtual: _selectedStatus),
    );
  }

  void _clearFilters() {
    Modular.to.pop(const PotreiroFilterSheetResult.clear());
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
                  const Text(
                    'Status atual',
                    style: TextStyle(
                      color: Color(0xFF313131),
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AppSelectOverlay<String>(
                    value: _statusOptions.contains(_selectedStatus)
                        ? _selectedStatus
                        : null,
                    placeholder: 'Selecione',
                    options: _statusOptions
                        .map(
                          (item) =>
                              AppSelectOption<String>(value: item, label: item),
                        )
                        .toList(growable: false),
                    enabled: _statusOptions.isNotEmpty,
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              CustomButton(
                onPressed: _applyFilters,
                text: 'Filtrar',
                enabled: _hasAnyFilter,
              ),
              const SizedBox(height: 12),
              CustomButton(
                onPressed: _clearFilters,
                text: 'Limpar',
                enabled: _hasAnyFilter,
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
}
