import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class AnimalLotFilterSheetResult {
  const AnimalLotFilterSheetResult._({this.shouldClear = false, this.nome});

  const AnimalLotFilterSheetResult.apply({String? nome})
    : this._(nome: nome);

  const AnimalLotFilterSheetResult.clear() : this._(shouldClear: true);

  final bool shouldClear;
  final String? nome;
}

class AnimalLotFilterSheet extends StatefulWidget {
  const AnimalLotFilterSheet({super.key, this.initialNome});

  final String? initialNome;

  @override
  State<AnimalLotFilterSheet> createState() => _AnimalLotFilterSheetState();
}

class _AnimalLotFilterSheetState extends State<AnimalLotFilterSheet> {
  late final TextEditingController _nameController;

  bool get _hasAnyFilter => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialNome ?? '');
    _nameController.addListener(_handleFilterChanged);
    AppLogger.info('LOTES FILTER SHEET: INIT STATE');
  }

  @override
  void dispose() {
    AppLogger.info('LOTES FILTER SHEET: DISPOSE');
    _nameController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final nome = _nameController.text.trim();
    AppLogger.info('LOTES FILTER SHEET: APLICANDO FILTRO POR NOME');
    Navigator.of(context).pop(
      AnimalLotFilterSheetResult.apply(nome: nome.isEmpty ? null : nome),
    );
  }

  void _clearFilters() {
    AppLogger.warning('LOTES FILTER SHEET: LIMPANDO FILTROS');
    Navigator.of(context).pop(const AnimalLotFilterSheetResult.clear());
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
                    onPressed: () {
                      AppLogger.info('LOTES FILTER SHEET: FECHANDO MODAL');
                      Navigator.of(context).pop();
                    },
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
                    'Nome',
                    style: TextStyle(
                      color: Color(0xFF313131),
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(
                      color: Color(0xFF313131),
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Insira aqui...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF8C8C8C),
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
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
                ],
              ),
              const SizedBox(height: 32),
              CustomButton(
                onPressed: _applyFilters,
                text: 'Filtrar',
                enabled: _hasAnyFilter,
                height: 56,
                borderRadius: 16,
              ),
              const SizedBox(height: 16),
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
