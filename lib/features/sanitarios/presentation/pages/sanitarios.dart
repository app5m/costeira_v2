import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';
import 'package:costeira/features/sanitarios/presentation/controllers/list_sanitarios_controller.dart';
import 'package:costeira/features/sanitarios/presentation/pages/add_planejamento.dart';
import 'package:costeira/features/sanitarios/presentation/pages/execucao.dart';
import 'package:costeira/features/sanitarios/presentation/pages/graficos_execucoes.dart';
import 'package:costeira/features/sanitarios/presentation/pages/planejamento.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class Sanitarios extends StatefulWidget {
  const Sanitarios({super.key});

  @override
  State<Sanitarios> createState() => _SanitariosState();
}

class _SanitariosState extends State<Sanitarios>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ListSanitariosController _controller;
  _SanitarioFilterValue _filter = const _SanitarioFilterValue();
  List<SanitarioTipoManejoEntity> _tipoManejoOptions = const [];
  int index = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _controller = Modular.get<ListSanitariosController>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await _controller.load(
      tipoManejo: _filter.tipoManejo,
      dataIn: _filter.dataIn,
      dataOut: _filter.dataOut,
    );
    if (mounted && !_filter.hasFilters) {
      setState(() {
        _tipoManejoOptions = _controller.result.tiposManejos;
      });
    }
  }

  Future<void> _showFilterSheet() async {
    final result = await showModalBottomSheet<_SanitarioFilterValue>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SanitarioFilterSheet(
        initialFilter: _filter,
        tiposManejo: _tipoManejoOptions,
      ),
    );

    if (result == null || result == _filter) {
      return;
    }

    setState(() {
      _filter = result;
    });
    await _load();
  }

  String get _filterLabel {
    if (!_filter.hasFilters) {
      return 'Filtrar';
    }

    final tipoLabel = _tipoLabel(_filter.tipoManejo);
    final dates = [
      if ((_filter.dataIn ?? '').isNotEmpty) _filter.dataIn!,
      if ((_filter.dataOut ?? '').isNotEmpty) _filter.dataOut!,
    ];
    final values = [
      if ((tipoLabel ?? '').isNotEmpty) tipoLabel!,
      if (dates.isNotEmpty) dates.join(' - '),
    ];

    if (values.length == 1) {
      return values.first;
    }
    return '${values.length} filtros ativos';
  }

  String? _tipoLabel(String? id) {
    if (id == null) {
      return null;
    }
    for (final tipo in _tipoManejoOptions) {
      if (tipo.id == id) {
        return tipo.nome;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: index == 0
          ? FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(64),
              ),
              onPressed: () {
                Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPlanejamento()),
                ).then((saved) {
                  if (saved == true) {
                    _load();
                  }
                });
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Sanitários',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Planejamentos'),
                Tab(text: 'Execuções'),
                Tab(text: 'Gráficos'),
              ],
              onTap: (value) => setState(() => index = value),
              automaticIndicatorColorAdjustment: false,
              indicatorSize: TabBarIndicatorSize.tab,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
              ),
              dividerColor: Colors.grey,
              labelColor: Colors.black,
              indicatorColor: MyColors.colorPrimary2,
            ),
            if (index != 2) ...[
              const SizedBox(height: 16),
              _FilterSelector(
                label: _filterLabel,
                isActive: _filter.hasFilters,
                onTap: _showFilterSheet,
              ),
              const SizedBox(height: 16),
            ],
            if (index == 0)
              Expanded(
                child: SanitariosPlanejamentoList(controller: _controller),
              ),
            if (index == 1)
              Expanded(child: SanitariosExecucoesList(controller: _controller)),
            if (index == 2) const GraficosExcucao(),
          ],
        ),
      ),
    );
  }
}

class _SanitarioFilterValue {
  const _SanitarioFilterValue({this.tipoManejo, this.dataIn, this.dataOut});

  final String? tipoManejo;
  final String? dataIn;
  final String? dataOut;

  bool get hasFilters =>
      (tipoManejo?.trim().isNotEmpty ?? false) ||
      (dataIn?.trim().isNotEmpty ?? false) ||
      (dataOut?.trim().isNotEmpty ?? false);

  @override
  bool operator ==(Object other) {
    return other is _SanitarioFilterValue &&
        other.tipoManejo == tipoManejo &&
        other.dataIn == dataIn &&
        other.dataOut == dataOut;
  }

  @override
  int get hashCode => Object.hash(tipoManejo, dataIn, dataOut);
}

class _SanitarioFilterSheet extends StatefulWidget {
  const _SanitarioFilterSheet({
    required this.initialFilter,
    required this.tiposManejo,
  });

  final _SanitarioFilterValue initialFilter;
  final List<SanitarioTipoManejoEntity> tiposManejo;

  @override
  State<_SanitarioFilterSheet> createState() => _SanitarioFilterSheetState();
}

class _SanitarioFilterSheetState extends State<_SanitarioFilterSheet> {
  String? _tipoManejo;
  DateTime? _dataIn;
  DateTime? _dataOut;

  bool get _hasAnyFilter =>
      (_tipoManejo?.trim().isNotEmpty ?? false) ||
      _dataIn != null ||
      _dataOut != null;

  @override
  void initState() {
    super.initState();
    _tipoManejo = widget.initialFilter.tipoManejo;
    _dataIn = _parseDate(widget.initialFilter.dataIn);
    _dataOut = _parseDate(widget.initialFilter.dataOut);
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
                    onPressed: () => Navigator.of(context).pop(),
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
              _FilterFieldShell(
                label: 'Tipo de manejo',
                child: AppSelectOverlay<String>(
                  value:
                      widget.tiposManejo.any((item) => item.id == _tipoManejo)
                      ? _tipoManejo
                      : null,
                  placeholder: 'Selecione',
                  options: widget.tiposManejo
                      .map(
                        (item) => AppSelectOption<String>(
                          value: item.id,
                          label: item.nome,
                        ),
                      )
                      .toList(growable: false),
                  enabled: widget.tiposManejo.isNotEmpty,
                  onChanged: (value) => setState(() => _tipoManejo = value),
                ),
              ),
              _DateFilterField(
                label: 'Data inicial',
                value: _dataIn == null ? 'Selecione' : _formatDate(_dataIn!),
                onTap: () => _pickDate(isStart: true),
              ),
              _DateFilterField(
                label: 'Data final',
                value: _dataOut == null ? 'Selecione' : _formatDate(_dataOut!),
                onTap: () => _pickDate(isStart: false),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _hasAnyFilter ? _apply : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.colorPrimary,
                    disabledBackgroundColor: MyColors.gray,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Filtrar',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _hasAnyFilter ? _clear : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MyColors.colorPrimary,
                    disabledForegroundColor: MyColors.gray,
                    side: BorderSide(
                      color: _hasAnyFilter
                          ? MyColors.colorPrimary
                          : MyColors.gray,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Limpar',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = (isStart ? _dataIn : _dataOut) ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null) {
      return;
    }
    setState(() {
      if (isStart) {
        _dataIn = selected;
        if (_dataOut != null && _dataOut!.isBefore(selected)) {
          _dataOut = selected;
        }
      } else {
        _dataOut = selected;
        if (_dataIn != null && _dataIn!.isAfter(selected)) {
          _dataIn = selected;
        }
      }
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      _SanitarioFilterValue(
        tipoManejo: _tipoManejo,
        dataIn: _dataIn == null ? null : _formatDate(_dataIn!),
        dataOut: _dataOut == null ? null : _formatDate(_dataOut!),
      ),
    );
  }

  void _clear() {
    Navigator.of(context).pop(const _SanitarioFilterValue());
  }
}

class _FilterFieldShell extends StatelessWidget {
  const _FilterFieldShell({required this.label, required this.child});

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

class _DateFilterField extends StatelessWidget {
  const _DateFilterField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _FilterFieldShell(
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEBEBEB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEBEBEB)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: value == 'Selecione'
                        ? const Color(0xFF8C8C8C)
                        : const Color(0xFF313131),
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFF8C8C8C),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSelector extends StatelessWidget {
  const _FilterSelector({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: isActive ? const Color(0x14128977) : Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: isActive ? MyColors.colorPrimary : const Color(0xFFEBEBEB),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 24,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive
                      ? MyColors.colorPrimary
                      : const Color(0xFF8C8C8C),
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.tune_rounded,
              color: isActive ? MyColors.colorPrimary : const Color(0xFF8C8C8C),
            ),
          ],
        ),
      ),
    );
  }
}

DateTime? _parseDate(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
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

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
