import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:costeira/core/components/web_empty_state.dart';
import 'package:costeira/core/components/web_page_dialog.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_charts_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_entity.dart';
import 'package:costeira/features/climate_and_rain/presentation/controllers/get_climate_charts_controller.dart';
import 'package:costeira/features/climate_and_rain/presentation/page_controllers/climate_list_page_controller.dart';
import 'package:costeira/features/climate_and_rain/presentation/page_controllers/climate_page_controller.dart';
import 'package:costeira/features/climate_and_rain/presentation/pages/climate_add.dart';
import 'package:costeira/features/climate_and_rain/presentation/pages/climate_edit.dart';
import 'package:costeira/features/climate_and_rain/presentation/web/climate_charts_web_body.dart';
import 'package:costeira/features/climate_and_rain/presentation/widgets/climate_filter_sheet.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ClimateWebPage extends StatefulWidget {
  const ClimateWebPage({super.key});

  @override
  State<ClimateWebPage> createState() => _ClimateWebPageState();
}

class _ClimateWebPageState extends State<ClimateWebPage>
    with SingleTickerProviderStateMixin {
  late final ClimatePageController _pageController;
  late final ClimateListPageController _listController;
  late final GetClimateChartsController _chartsController;
  final ValueNotifier<int> _listRevision = ValueNotifier(0);
  final ValueNotifier<int> _chartsRevision = ValueNotifier(0);
  int? _deletingClimateId;
  bool _listInitialized = false;
  bool _chartsInitialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = Modular.get<ClimatePageController>();
    _listController = Modular.get<ClimateListPageController>();
    _chartsController = Modular.get<GetClimateChartsController>();
    _pageController.init(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadList();
      _loadCharts();
    });
  }

  @override
  void dispose() {
    _listRevision.dispose();
    _chartsRevision.dispose();
    _pageController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<void> _loadList() async {
    final result = await _listController.loadInitialData();
    if (mounted) {
      _listInitialized = true;
      _listRevision.value++;
    }
    if (!mounted || result == null) return;
    AppSnackBar.show(
      context: context,
      message: result.message,
      isError: !result.isSuccess,
    );
  }

  Future<void> _loadCharts() async {
    try {
      await _chartsController.load();
    } catch (_) {
    } finally {
      if (mounted) {
        _chartsInitialized = true;
        _chartsRevision.value++;
      }
    }
  }

  Future<void> _openAdd() async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const WebPageDialog(
        title: 'Adicionar chuva',
        width: 640,
        maxHeight: 720,
        child: ClimateAdd(),
      ),
    );
    if (!mounted || result?['success'] != true) return;
    await _loadList();
    await _loadCharts();
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: result?['message']?.toString() ?? 'Clima salvo com sucesso.',
      isError: false,
    );
  }

  Future<void> _openEdit(ClimateEntity climate) async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WebPageDialog(
        title: 'Editar chuva',
        width: 640,
        maxHeight: 720,
        child: ClimateEdit(climate: climate),
      ),
    );
    if (!mounted) return;
    final action = await _listController.handleEditResult(result);
    if (mounted) {
      _listInitialized = true;
      _listRevision.value++;
    }
    if (!mounted || action == null) return;
    if (action.isSuccess) {
      await _loadCharts();
    }
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: action.message,
      isError: !action.isSuccess,
    );
  }

  Future<void> _openDetails(ClimateEntity climate) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ClimateDetailsWebDialog(climate: climate),
    );
  }

  Future<void> _openFilter() async {
    final result = await showDialog<ClimateFilterSheetResult>(
      context: context,
      builder: (_) => _ClimateDateFilterWebDialog(
        initialDataIn: _listController.currentDataInFilter,
        initialDataOut: _listController.currentDataOutFilter,
      ),
    );
    if (!mounted || result == null) return;
    final action = await _listController.applyFilters(result);
    if (mounted) {
      _listInitialized = true;
      _listRevision.value++;
    }
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: action.message,
      isError: !action.isSuccess,
    );
  }

  Future<void> _confirmDelete(ClimateEntity climate) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Excluir chuva',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Tem certeza que deseja excluir este registro de chuva?',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            height: 1.45,
            color: Color(0xFF666666),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFC4473A),
              side: const BorderSide(color: Color(0xFFC4473A)),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    _deletingClimateId = climate.id;
    _listRevision.value++;
    final action = await _listController.deleteClimate(climate);
    if (mounted) {
      _deletingClimateId = null;
      _listRevision.value++;
    }
    if (!mounted) return;
    if (action.isSuccess) {
      await _loadCharts();
    }
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: action.message,
      isError: !action.isSuccess,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, _) {
        return ColoredBox(
          color: Colors.white,
          child: Column(
            children: [
              _tabs(),
              const Divider(height: 1, color: Color(0xFFE7E4DD)),
              _toolbar(),
              const Divider(height: 1, color: Color(0xFFE7E4DD)),
              Expanded(child: _stableTabBody()),
            ],
          ),
        );
      },
    );
  }

  Widget _tabs() {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 320,
        child: TabBar(
          controller: _pageController.tabController,
          onTap: _pageController.setTabIndex,
          tabs: const [
            Tab(text: 'Lista'),
            Tab(text: 'Dados'),
          ],
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: const Color(0xFF313131),
          unselectedLabelColor: const Color(0xFF8C8C8C),
          indicatorColor: MyColors.colorPrimary2,
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _toolbar() {
    final isList = _pageController.shouldShowFab;
    return AnimatedBuilder(
      animation: isList ? _listController : _chartsController,
      builder: (context, _) => _toolbarContent(),
    );
  }

  Widget _toolbarContent() {
    final isList = _pageController.shouldShowFab;
    final loading =
        isList ? _listController.isLoading : _chartsController.isLoading;
    final count = _listController.climates.length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            compact ? 16 : 28,
            16,
            compact ? 16 : 28,
            16,
          ),
          child: Row(
            children: [
              if (!compact)
                Expanded(
                  child: Text(
                    isList
                        ? count == 1
                              ? '1 registro de chuva'
                              : '$count registros de chuva'
                        : 'Indicadores de clima e chuvas',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF777777),
                    ),
                  ),
                )
              else
                const Spacer(),
              if (isList) ...[
                _FilterButton(
                  active: _listController.hasActiveFilters(),
                  onPressed: loading ? null : _openFilter,
                ),
                const SizedBox(width: 8),
              ],
              _ToolbarIconButton(
                tooltip: isList ? 'Atualizar lista' : 'Atualizar dados',
                icon: LucideIcons.refreshCw,
                isLoading: loading,
                onPressed: loading
                    ? null
                    : isList
                    ? _loadList
                    : _loadCharts,
              ),
              if (isList) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: compact ? 126 : 170,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: loading ? null : _openAdd,
                    icon: const Icon(Icons.add_rounded, size: 19),
                    label: Text(compact ? 'Adicionar' : 'Adicionar chuva'),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      backgroundColor: MyColors.colorPrimary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFBFC9C5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _stableTabBody() {
    final isList = _pageController.tabIndex == 0;
    final revision = isList ? _listRevision : _chartsRevision;
    final Listenable loadingAnimation =
        isList ? _listController : _chartsController;
    bool isLoading() =>
        isList ? _listController.isLoading : _chartsController.isLoading;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: ValueListenableBuilder<int>(
            valueListenable: revision,
            builder: (context, _, __) => isList ? _listTab() : _dadosTab(),
          ),
        ),
        AnimatedBuilder(
          animation: loadingAnimation,
          builder: (context, _) => isLoading()
              ? const Align(
                  alignment: Alignment.topCenter,
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    color: MyColors.colorPrimary,
                    backgroundColor: Color(0xFFE6EEE8),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _listTab() {
    if (!_listInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_listController.isLoading && _listController.climates.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_listController.errorMessage != null &&
        _listController.climates.isEmpty) {
      return _WebStateMessage(
        message: _listController.errorMessage!,
        actionLabel: 'Tentar novamente',
        onAction: _loadList,
      );
    }
    if (_listController.climates.isEmpty) {
      return WebEmptyState(
        icon: LucideIcons.cloudRain,
        title: 'Nenhum registro de chuva cadastrado.',
        description:
            'Use o botão Adicionar chuva para registrar a primeira ocorrência.',
        actionLabel: 'Adicionar chuva',
        onAction: _openAdd,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 820;
        return Scrollbar(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              constraints.maxWidth < 720 ? 16 : 28,
              18,
              constraints.maxWidth < 720 ? 16 : 28,
              32,
            ),
            children: [
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE7E4DD)),
                ),
                child: Column(
                  children: [
                    if (wide) const _ClimateTableHeader(),
                    for (
                      var index = 0;
                      index < _listController.climates.length;
                      index++
                    ) ...[
                      if (index > 0)
                        const Divider(height: 1, color: Color(0xFFE7E4DD)),
                      if (wide)
                        _ClimateTableRow(
                          climate: _listController.climates[index],
                          deleting:
                              _deletingClimateId ==
                              _listController.climates[index].id,
                          onOpen: () =>
                              _openDetails(_listController.climates[index]),
                          onEdit: () =>
                              _openEdit(_listController.climates[index]),
                          onDelete: () =>
                              _confirmDelete(_listController.climates[index]),
                        )
                      else
                        _ClimateStackedRow(
                          climate: _listController.climates[index],
                          deleting:
                              _deletingClimateId ==
                              _listController.climates[index].id,
                          onOpen: () =>
                              _openDetails(_listController.climates[index]),
                          onEdit: () =>
                              _openEdit(_listController.climates[index]),
                          onDelete: () =>
                              _confirmDelete(_listController.climates[index]),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dadosTab() {
    if (!_chartsInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    final charts = _chartsController.charts;
    if (_chartsController.isLoading && charts == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_chartsController.errorMessage != null && charts == null) {
      return _WebStateMessage(
        message: _chartsController.errorMessage!,
        actionLabel: 'Tentar novamente',
        onAction: _loadCharts,
      );
    }
    final data =
        charts ??
        const ClimateChartsEntity(
          totalChuvaAcumulada: 0,
          totalChuvaUltimoMes: 0,
          chuvaMesAMes: [],
          comparativoUltimos2Anos: [],
        );
    return ClimateChartsWebBody(charts: data);
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.active, required this.onPressed});

  final bool active;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.tune_rounded, size: 17),
        label: Text(active ? 'Filtros ativos' : 'Filtrar'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          foregroundColor: MyColors.colorPrimary,
          backgroundColor: active ? const Color(0x14128977) : Colors.white,
          side: BorderSide(
            color: active ? MyColors.colorPrimary : const Color(0xFFC9D4CB),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  const _ToolbarIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    required this.isLoading,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 46,
        height: 46,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: MyColors.colorPrimary,
            backgroundColor: Colors.white,
            padding: EdgeInsets.zero,
            side: const BorderSide(color: Color(0xFFC9D4CB)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          child: isLoading
              ? const SizedBox.square(
                  dimension: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: MyColors.colorPrimary,
                  ),
                )
              : Icon(icon, size: 17),
        ),
      ),
    );
  }
}

class _ClimateTableHeader extends StatelessWidget {
  const _ClimateTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F7F3),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: const Row(
        children: [
          SizedBox(width: 38),
          SizedBox(width: 12),
          Expanded(flex: 2, child: _HeaderText('Quantidade')),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _HeaderText('Início')),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _HeaderText('Fim')),
          SizedBox(width: 16),
          SizedBox(width: 188),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: .35,
        color: Color(0xFF777777),
      ),
    );
  }
}

class _ClimateTableRow extends StatelessWidget {
  const _ClimateTableRow({
    required this.climate,
    required this.deleting,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final ClimateEntity climate;
  final bool deleting;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: deleting ? null : onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              const _ClimateIcon(),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: _ValueText(_climateQuantity(climate))),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _ValueText(climate.dataIn)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _ValueText(climate.dataOut)),
              const SizedBox(width: 16),
              SizedBox(
                width: 188,
                child: _ClimateActions(
                  deleting: deleting,
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClimateStackedRow extends StatelessWidget {
  const _ClimateStackedRow({
    required this.climate,
    required this.deleting,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final ClimateEntity climate;
  final bool deleting;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: deleting ? null : onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ClimateIcon(),
                  const SizedBox(width: 12),
                  Expanded(child: _ValueText(_climateQuantity(climate))),
                ],
              ),
              const SizedBox(height: 13),
              _CompactValue(label: 'Início', value: climate.dataIn),
              const SizedBox(height: 6),
              _CompactValue(label: 'Fim', value: climate.dataOut),
              const SizedBox(height: 14),
              _ClimateActions(
                deleting: deleting,
                onEdit: onEdit,
                onDelete: onDelete,
                expanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClimateIcon extends StatelessWidget {
  const _ClimateIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0x14128977),
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Icon(
        LucideIcons.cloudRain,
        size: 18,
        color: MyColors.colorPrimary,
      ),
    );
  }
}

class _ValueText extends StatelessWidget {
  const _ValueText(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4F5652),
      ),
    );
  }
}

class _CompactValue extends StatelessWidget {
  const _CompactValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8A8A8A),
            ),
          ),
        ),
        Expanded(child: _ValueText(value)),
      ],
    );
  }
}

class _ClimateActions extends StatelessWidget {
  const _ClimateActions({
    required this.deleting,
    required this.onEdit,
    required this.onDelete,
    this.expanded = false,
  });

  final bool deleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    if (deleting) {
      return const SizedBox(
        height: 38,
        child: Center(
          child: SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: MyColors.colorPrimary,
            ),
          ),
        ),
      );
    }

    final edit = SizedBox(
      width: expanded ? null : 88,
      height: 38,
      child: OutlinedButton.icon(
        onPressed: onEdit,
        icon: const Icon(LucideIcons.pencil, size: 15),
        label: const Text('Editar'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          foregroundColor: MyColors.colorPrimary,
          side: const BorderSide(color: Color(0xFFBFD4C7)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
    final remove = SizedBox(
      width: expanded ? null : 92,
      height: 38,
      child: OutlinedButton.icon(
        onPressed: onDelete,
        icon: const Icon(LucideIcons.trash2, size: 15),
        label: const Text('Excluir'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          foregroundColor: const Color(0xFFC4473A),
          side: const BorderSide(color: Color(0xFFE1B8B2)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );

    return Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (expanded) Expanded(child: edit) else edit,
        const SizedBox(width: 8),
        if (expanded) Expanded(child: remove) else remove,
      ],
    );
  }
}

String _climateQuantity(ClimateEntity climate) {
  return '${_formatDecimal(climate.quantidade)} mm';
}

String _formatDecimal(double value) {
  if (value == value.truncateToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(2);
}

class _ClimateDetailsWebDialog extends StatelessWidget {
  const _ClimateDetailsWebDialog({required this.climate});

  final ClimateEntity climate;

  @override
  Widget build(BuildContext context) {
    return WebDialogFrame(
      title: 'Detalhes da chuva',
      width: 560,
      bodyPadding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailField(label: 'Quantidade', value: _climateQuantity(climate)),
          _DetailField(label: 'Data início', value: climate.dataIn),
          _DetailField(label: 'Data fim', value: climate.dataOut),
        ],
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final display = value?.trim().isNotEmpty == true ? value!.trim() : '-';
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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
              height: 1.50,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              display,
              style: const TextStyle(
                color: Color(0xFF313131),
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClimateDateFilterWebDialog extends StatefulWidget {
  const _ClimateDateFilterWebDialog({
    this.initialDataIn,
    this.initialDataOut,
  });

  final String? initialDataIn;
  final String? initialDataOut;

  @override
  State<_ClimateDateFilterWebDialog> createState() =>
      _ClimateDateFilterWebDialogState();
}

class _ClimateDateFilterWebDialogState
    extends State<_ClimateDateFilterWebDialog> {
  late final TextEditingController _dataInController;
  late final TextEditingController _dataOutController;

  @override
  void initState() {
    super.initState();
    _dataInController = TextEditingController(text: widget.initialDataIn ?? '');
    _dataOutController =
        TextEditingController(text: widget.initialDataOut ?? '');
  }

  @override
  void dispose() {
    _dataInController.dispose();
    _dataOutController.dispose();
    super.dispose();
  }

  Future<void> _pick(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _tryParse(controller.text) ?? now,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 20),
    );
    if (picked == null) return;
    controller.text = _formatDate(picked);
    setState(() {});
  }

  void _apply({required bool clear}) {
    Navigator.pop(
      context,
      ClimateFilterSheetResult(
        dataIn: clear ? null : _normalized(_dataInController.text),
        dataOut: clear ? null : _normalized(_dataOutController.text),
        shouldClear: clear,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasFilters =
        _normalized(_dataInController.text) != null ||
        _normalized(_dataOutController.text) != null;
    return WebDialogFrame(
      title: 'Filtrar chuvas',
      width: 480,
      bodyPadding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DateField(
            label: 'Data início',
            controller: _dataInController,
            onTap: () => _pick(_dataInController),
          ),
          const SizedBox(height: 14),
          _DateField(
            label: 'Data fim',
            controller: _dataOutController,
            onTap: () => _pick(_dataOutController),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (hasFilters) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _apply(clear: true),
                    child: const Text('Limpar'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: hasFilters ? () => _apply(clear: false) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.colorPrimary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFBFC9C5),
                  ),
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.controller,
    required this.onTap,
  });

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
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF313131),
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
            fillColor: const Color(0xFFEBEBEB),
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

class _WebStateMessage extends StatelessWidget {
  const _WebStateMessage({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

String? _normalized(String? value) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}

DateTime? _tryParse(String value) {
  final parts = value.trim().split('/');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  return DateTime(year, month, day);
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}
