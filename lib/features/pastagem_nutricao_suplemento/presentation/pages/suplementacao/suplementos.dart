import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/controllers/delete_suplemento_controller.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/controllers/list_suplementos_controller.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/pages/suplementacao/add_suplemento.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/pages/suplementacao/add_suplemento_registro.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/pages/suplementacao/detail_suplemento.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'edit_suplemento.dart';
import 'graficos_suplemento.dart';

class Suplementos extends StatefulWidget {
  const Suplementos({super.key});

  @override
  State<Suplementos> createState() => _SuplementosState();
}

class _SuplementosState extends State<Suplementos>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ListSuplementosController _controller;
  late final DeleteSuplementoController _deleteController;
  _SuplementoFilterValue _filter = const _SuplementoFilterValue();
  _SuplementoFilterOptions _filterOptions = const _SuplementoFilterOptions();
  int index = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _controller = Modular.get<ListSuplementosController>()..addListener(_sync);
    _deleteController = Modular.get<DeleteSuplementoController>()
      ..addListener(_sync);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _controller.removeListener(_sync);
    _deleteController.removeListener(_sync);
    _tabController.dispose();
    super.dispose();
  }

  void _sync() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    try {
      await _controller.load(
        idPotreiro: _filter.idPotreiro,
        idLote: _filter.idLote,
        idProduto: _filter.idProduto,
      );
      if (!_filter.hasFilters) {
        _filterOptions = _SuplementoFilterOptions.fromSuplementos(
          _controller.suplementos,
        );
      }
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message: _controller.errorMessage ?? 'Erro ao listar suplementos.',
      );
    }
  }

  Future<void> _showFilterSheet() async {
    final result = await showModalBottomSheet<_SuplementoFilterValue>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SuplementoFilterSheet(
        initialFilter: _filter,
        options: _filterOptions,
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

    final values = [
      _labelFor(_filterOptions.potreiros, _filter.idPotreiro),
      _labelFor(_filterOptions.lotes, _filter.idLote),
      _labelFor(_filterOptions.produtos, _filter.idProduto),
    ].where((item) => item.isNotEmpty).toList(growable: false);

    if (values.isEmpty) {
      return 'Filtros ativos';
    }
    if (values.length == 1) {
      return values.first;
    }
    return '${values.length} filtros ativos';
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
              onPressed: () async {
                final changed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const AddSuplemento()),
                );
                if (changed == true) {
                  await _load();
                }
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Suplementação e Consumo',
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
                Tab(text: 'Dados'),
                Tab(text: 'Registros'),
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
            const SizedBox(height: 16),
            if (index == 0)
              _FilterSelector(
                label: _filterLabel,
                isActive: _filter.hasFilters,
                onTap: _showFilterSheet,
              ),
            if (index == 0) const SizedBox(height: 16),
            if (index == 0)
              Expanded(
                child: _DadosTab(
                  controller: _controller,
                  onChanged: _load,
                  onDelete: _deleteSuplemento,
                  onShowRegistros: () {
                    _tabController.animateTo(1);
                    setState(() => index = 1);
                  },
                ),
              ),
            if (index == 1)
              Expanded(
                child: _RegistrosTab(
                  registros: _controller.registros,
                  onChanged: _load,
                  onDelete: _deleteRegistro,
                ),
              ),
            if (index == 2) const Expanded(child: GraficosSuplemento()),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSuplemento(Suplemento suplemento) async {
    final confirmed = await _showDeleteSheet(
      context,
      title: 'Excluir suplementacao e consumo',
      description:
          'Tem certeza que deseja excluir essa suplementacao e consumo permanentemente?',
    );
    if (confirmed != true) return;

    try {
      final result = await _deleteController.deleteSuplemento(suplemento.id);
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message: result.message,
        isError: false,
      );
      await _load();
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message:
            _deleteController.errorMessage ?? 'Erro ao excluir suplementacao.',
      );
    }
  }

  Future<void> _deleteRegistro(SuplementoRegistro registro) async {
    final confirmed = await _showDeleteSheet(
      context,
      title: 'Excluir registro',
      description: 'Tem certeza que deseja excluir esse registro?',
    );
    if (confirmed != true) return;

    try {
      final result = await _deleteController.deleteRegistro(registro.id);
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message: result.message,
        isError: false,
      );
      await _load();
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message: _deleteController.errorMessage ?? 'Erro ao excluir registro.',
      );
    }
  }

  Future<bool?> _showDeleteSheet(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    return showModalBottomSheet<bool>(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 72, height: 2, color: const Color(0xFFE2E2E2)),
                const SizedBox(height: 24),
                SvgPicture.asset(
                  'icon/danger-linear.svg',
                  width: 80,
                  height: 80,
                  colorFilter: const ColorFilter.mode(
                    Colors.red,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF8692A8),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(sheetContext).pop(true),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Colors.red),
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                    ),
                    child: const Text(
                      'Excluir',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 16,
                      color: MyColors.colorOnPrimary,
                      decoration: TextDecoration.underline,
                      decorationColor: MyColors.colorOnPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
        clipBehavior: Clip.antiAlias,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

class _SuplementoFilterValue {
  const _SuplementoFilterValue({this.idPotreiro, this.idLote, this.idProduto});

  final int? idPotreiro;
  final int? idLote;
  final int? idProduto;

  bool get hasFilters =>
      idPotreiro != null || idLote != null || idProduto != null;

  @override
  bool operator ==(Object other) {
    return other is _SuplementoFilterValue &&
        other.idPotreiro == idPotreiro &&
        other.idLote == idLote &&
        other.idProduto == idProduto;
  }

  @override
  int get hashCode => Object.hash(idPotreiro, idLote, idProduto);
}

class _SuplementoFilterOptions {
  const _SuplementoFilterOptions({
    this.potreiros = const [],
    this.lotes = const [],
    this.produtos = const [],
    this.lotePotreiroIds = const {},
  });

  final List<SuplementoReference> potreiros;
  final List<SuplementoReference> lotes;
  final List<SuplementoReference> produtos;
  final Map<int, int> lotePotreiroIds;

  factory _SuplementoFilterOptions.fromSuplementos(
    List<Suplemento> suplementos,
  ) {
    final lotePotreiroIds = <int, int>{};
    for (final item in suplementos) {
      final loteId = item.lote?.id;
      final potreiroId = item.potreiro?.id;
      if (loteId != null && potreiroId != null) {
        lotePotreiroIds[loteId] = potreiroId;
      }
    }

    return _SuplementoFilterOptions(
      potreiros: _uniqueReferences(
        suplementos
            .map((item) => item.potreiro)
            .whereType<SuplementoReference>(),
      ),
      lotes: _uniqueReferences(
        suplementos.map((item) => item.lote).whereType<SuplementoReference>(),
      ),
      produtos: _uniqueReferences(
        suplementos
            .map((item) => item.produto)
            .whereType<SuplementoReference>(),
      ),
      lotePotreiroIds: lotePotreiroIds,
    );
  }
}

class _SuplementoFilterSheet extends StatefulWidget {
  const _SuplementoFilterSheet({
    required this.initialFilter,
    required this.options,
  });

  final _SuplementoFilterValue initialFilter;
  final _SuplementoFilterOptions options;

  @override
  State<_SuplementoFilterSheet> createState() => _SuplementoFilterSheetState();
}

class _SuplementoFilterSheetState extends State<_SuplementoFilterSheet> {
  late int? _idPotreiro;
  late int? _idLote;
  late int? _idProduto;

  bool get _hasAnyFilter =>
      _idPotreiro != null || _idLote != null || _idProduto != null;

  List<SuplementoReference> get _lotesDisponiveis {
    if (_idPotreiro == null) {
      return widget.options.lotes;
    }

    final vinculados = widget.options.lotes
        .where((lote) => widget.options.lotePotreiroIds[lote.id] == _idPotreiro)
        .toList(growable: false);

    return vinculados.isEmpty ? widget.options.lotes : vinculados;
  }

  @override
  void initState() {
    super.initState();
    _idPotreiro = widget.initialFilter.idPotreiro;
    _idLote = widget.initialFilter.idLote;
    _idProduto = widget.initialFilter.idProduto;
  }

  void _applyFilters() {
    Navigator.of(context).pop(
      _SuplementoFilterValue(
        idPotreiro: _idPotreiro,
        idLote: _idLote,
        idProduto: _idProduto,
      ),
    );
  }

  void _clearFilters() {
    Navigator.of(context).pop(const _SuplementoFilterValue());
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
              _FilterSelectField(
                label: 'Potreiro',
                value: _idPotreiro,
                options: widget.options.potreiros,
                placeholder: 'Selecione',
                onChanged: (value) {
                  setState(() {
                    _idPotreiro = value;
                    if (!_lotesDisponiveis.any((lote) => lote.id == _idLote)) {
                      _idLote = null;
                    }
                  });
                },
              ),
              _FilterSelectField(
                label: 'Lote',
                value: _idLote,
                options: _lotesDisponiveis,
                placeholder: widget.options.lotes.isEmpty
                    ? 'Nenhum lote encontrado'
                    : 'Selecione',
                onChanged: (value) {
                  setState(() {
                    _idLote = value;
                  });
                },
              ),
              _FilterSelectField(
                label: 'Produto',
                value: _idProduto,
                options: widget.options.produtos,
                placeholder: 'Selecione',
                onChanged: (value) {
                  setState(() {
                    _idProduto = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _hasAnyFilter ? _applyFilters : null,
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
                  onPressed: _hasAnyFilter ? _clearFilters : null,
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
}

class _FilterSelectField extends StatelessWidget {
  const _FilterSelectField({
    required this.label,
    required this.value,
    required this.options,
    required this.placeholder,
    required this.onChanged,
  });

  final String label;
  final int? value;
  final List<SuplementoReference> options;
  final String placeholder;
  final ValueChanged<int?> onChanged;

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
          AppSelectOverlay<int>(
            value: options.any((item) => item.id == value) ? value : null,
            placeholder: placeholder,
            options: options
                .map(
                  (item) =>
                      AppSelectOption<int>(value: item.id, label: item.nome),
                )
                .toList(growable: false),
            enabled: options.isNotEmpty,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

List<SuplementoReference> _uniqueReferences(
  Iterable<SuplementoReference> references,
) {
  final items = <int, SuplementoReference>{};
  for (final reference in references) {
    items.putIfAbsent(reference.id, () => reference);
  }
  final result = items.values.toList(growable: false);
  result.sort((a, b) => a.nome.compareTo(b.nome));
  return result;
}

String _labelFor(List<SuplementoReference> options, int? id) {
  if (id == null) {
    return '';
  }
  for (final option in options) {
    if (option.id == id) {
      return option.nome;
    }
  }
  return '';
}

class _DadosTab extends StatelessWidget {
  const _DadosTab({
    required this.controller,
    required this.onChanged,
    required this.onDelete,
    required this.onShowRegistros,
  });

  final ListSuplementosController controller;
  final Future<void> Function() onChanged;
  final Future<void> Function(Suplemento suplemento) onDelete;
  final VoidCallback onShowRegistros;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.suplementos.isEmpty) {
      return const Center(child: Text('Nenhum suplemento encontrado.'));
    }

    return RefreshIndicator(
      onRefresh: onChanged,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 88),
        children: [
          _ResumoCard(suplementos: controller.suplementos),
          const SizedBox(height: 16),
          ...controller.suplementos.map(
            (suplemento) => _SuplementoCard(
              suplemento: suplemento,
              onChanged: onChanged,
              onDelete: onDelete,
              onShowRegistros: onShowRegistros,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumoCard extends StatelessWidget {
  const _ResumoCard({required this.suplementos});

  final List<Suplemento> suplementos;

  @override
  Widget build(BuildContext context) {
    final consumos = suplementos
        .map((item) => _parseBrDouble(item.consumoReal?.consumoRealAnimalDia))
        .whereType<double>()
        .toList();
    final media = consumos.isEmpty
        ? null
        : consumos.reduce((a, b) => a + b) / consumos.length;

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Consumo real',
            style: TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            media == null ? '-' : '${media.toStringAsFixed(2)} kg/animal/dia',
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuplementoCard extends StatelessWidget {
  const _SuplementoCard({
    required this.suplemento,
    required this.onChanged,
    required this.onDelete,
    required this.onShowRegistros,
  });

  final Suplemento suplemento;
  final Future<void> Function() onChanged;
  final Future<void> Function(Suplemento suplemento) onDelete;
  final VoidCallback onShowRegistros;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailSuplemento(suplemento: suplemento),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _SurfaceCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBadge(asset: 'icon/diamond.svg'),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suplemento.potreiro?.nome ?? 'Potreiro nao informado',
                      style: const TextStyle(
                        color: Color(0xFF313131),
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${suplemento.lote?.nome ?? 'Lote nao informado'} - ${suplemento.produto?.nome ?? 'Produto nao informado'}',
                      style: const TextStyle(
                        color: Color(0xFF313131),
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetricChip(
                          label: 'Peso medio',
                          value: _kg(suplemento.pesoMedio),
                        ),
                        _MetricChip(
                          label: 'Qtd animais',
                          value:
                              suplemento.quantidadeAnimais?.toString() ?? '-',
                        ),
                        _MetricChip(
                          label: 'Qtd atual',
                          value: _kg(suplemento.quantidadeAtual),
                        ),
                        _MetricChip(
                          label: 'Consumo animal',
                          value: _consumoAnimal(suplemento),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Data: ${suplemento.dataPostagem ?? '-'}',
                      style: const TextStyle(
                        color: Color(0xFF8C8C8C),
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'edit') {
                    final changed = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditSuplemento(suplemento: suplemento),
                      ),
                    );
                    if (changed == true) await onChanged();
                    return;
                  }
                  if (value == 'delete') {
                    await onDelete(suplemento);
                    return;
                  }
                  if (value == 'registros') {
                    onShowRegistros();
                    return;
                  }
                  if (value == 'add_registro') {
                    final changed = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddSuplementoRegistro(suplemento: suplemento),
                      ),
                    );
                    if (changed == true) await onChanged();
                    return;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'delete', child: Text('Excluir')),
                  PopupMenuItem(
                    value: 'add_registro',
                    child: Text('Adicionar registro'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegistrosTab extends StatelessWidget {
  const _RegistrosTab({
    required this.registros,
    required this.onChanged,
    required this.onDelete,
  });

  final List<SuplementoRegistro> registros;
  final Future<void> Function() onChanged;
  final Future<void> Function(SuplementoRegistro registro) onDelete;

  @override
  Widget build(BuildContext context) {
    if (registros.isEmpty) {
      return const Center(child: Text('Nenhum registro encontrado.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: registros.length,
      itemBuilder: (context, index) {
        final registro = registros[index];
        final suplemento = registro.suplemento;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _SurfaceCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconBadge(
                  icon: registro.tipo.id == 1 ? Icons.add : Icons.remove,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        registro.tipo.nome.isEmpty
                            ? 'Registro'
                            : registro.tipo.nome,
                        style: const TextStyle(
                          color: Color(0xFF313131),
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${suplemento?.potreiro?.nome ?? 'Potreiro nao informado'} - ${suplemento?.produto?.nome ?? 'Produto nao informado'}',
                        style: const TextStyle(
                          color: Color(0xFF313131),
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_kg(registro.quantidade)} em ${registro.dataRestabastecimento ?? '-'}',
                        style: const TextStyle(
                          color: Color(0xFF8C8C8C),
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == 'edit' && suplemento != null) {
                      final changed = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddSuplementoRegistro(
                            suplemento: suplemento,
                            registro: registro,
                          ),
                        ),
                      );
                      if (changed == true) await onChanged();
                      return;
                    }
                    if (value == 'delete') {
                      await onDelete(registro);
                      return;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(value: 'delete', child: Text('Excluir')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({this.asset, this.icon});

  final String? asset;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: const Color(0x198C8C8C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(42)),
      ),
      child: asset != null
          ? SvgPicture.asset(
              asset!,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                Color(0xFF8C8C8C),
                BlendMode.srcIn,
              ),
            )
          : Icon(icon, size: 16, color: const Color(0xFF8C8C8C)),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 10,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String _kg(double? value) =>
    value == null ? '-' : '${value.toStringAsFixed(2)} kg';

String _consumoAnimal(Suplemento suplemento) {
  final value = suplemento.consumoReal?.consumoRealAnimalDia;
  if (value == null || value.isEmpty) return '-';
  return '$value kg/dia';
}

double? _parseBrDouble(String? value) {
  if (value == null || value.isEmpty) return null;
  return double.tryParse(value.replaceAll(',', '.'));
}
