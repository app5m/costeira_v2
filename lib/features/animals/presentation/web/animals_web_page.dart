import 'package:costeira/core/common/get_list/domain/entities/get_list_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_params_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_category_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_item_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_subcategory_entity.dart';
import 'package:costeira/core/common/get_list/domain/usecases/get_list_usecase.dart';
import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/sub_user_flag.dart';
import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:costeira/core/components/web_empty_state.dart';
import 'package:costeira/core/components/web_page_dialog.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/animals/domain/entities/animal_charts_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/get_animal_charts_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/animal_list_page_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/animals_page_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/lotes_page_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/page_action_result.dart';
import 'package:costeira/features/animals/presentation/pages/animals/add_animal.dart';
import 'package:costeira/features/animals/presentation/pages/animals/animal_detail.dart';
import 'package:costeira/features/animals/presentation/pages/animals/animal_edit.dart';
import 'package:costeira/features/animals/presentation/web/animal_lot_add_web_dialog.dart';
import 'package:costeira/features/animals/presentation/web/animal_lot_form_web_dialog.dart';
import 'package:costeira/features/animals/presentation/widgets/animal_filter_sheet.dart';
import 'package:costeira/features/animals/presentation/widgets/animal_lot_filter_sheet.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AnimalsWebPage extends StatefulWidget {
  const AnimalsWebPage({super.key});

  @override
  State<AnimalsWebPage> createState() => _AnimalsWebPageState();
}

class _AnimalsWebPageState extends State<AnimalsWebPage>
    with SingleTickerProviderStateMixin {
  late final AnimalsPageController _pageController;
  late final GetAnimalChartsController _chartsController;
  late final AnimalListPageController _animalsController;
  late final LotesPageController _lotsController;
  final ValueNotifier<int> _chartsRevision = ValueNotifier(0);
  final ValueNotifier<int> _animalsRevision = ValueNotifier(0);
  final ValueNotifier<int> _lotsRevision = ValueNotifier(0);
  bool _chartsInitialized = false;
  bool _animalsInitialized = false;
  bool _lotsInitialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = Modular.get<AnimalsPageController>();
    _chartsController = Modular.get<GetAnimalChartsController>();
    _animalsController = Modular.get<AnimalListPageController>();
    _lotsController = Modular.get<LotesPageController>();
    _pageController.init(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadCharts();
      _loadAnimals();
      _loadLots();
    });
  }

  @override
  void dispose() {
    _chartsRevision.dispose();
    _animalsRevision.dispose();
    _lotsRevision.dispose();
    _pageController.dispose();
    _animalsController.dispose();
    _lotsController.dispose();
    super.dispose();
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

  Future<void> _loadAnimals() async {
    final result = await _animalsController.loadInitialData();
    if (mounted) {
      _animalsInitialized = true;
      _animalsRevision.value++;
    }
    if (!mounted || result == null || result.isSuccess) return;
    AppSnackBar.show(context: context, message: result.message, isError: true);
  }

  Future<void> _loadLots() async {
    final result = await _lotsController.loadInitialData();
    if (mounted) {
      _lotsInitialized = true;
      _lotsRevision.value++;
    }
    if (!mounted || result == null || result.isSuccess) return;
    AppSnackBar.show(context: context, message: result.message, isError: true);
  }

  Future<void> _openAddAnimal() async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const WebPageDialog(
        title: 'Adicionar animal',
        width: 760,
        maxHeight: 840,
        child: AnimalAdd(),
      ),
    );
    if (!mounted || result?['success'] != true) return;
    _pageController.handleAnimalCreated();
    await _loadAnimals();
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: result?['message']?.toString() ?? 'Animal salvo com sucesso.',
      isError: false,
    );
  }

  Future<void> _openEditAnimal(AnimalEntity animal) async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WebPageDialog(
        title: 'Editar animal',
        width: 760,
        maxHeight: 840,
        child: EditAnimal(animal: animal),
      ),
    );
    if (!mounted) return;
    final action = await _animalsController.handleEditResult(result);
    if (mounted && action != null) _animalsRevision.value++;
    if (!mounted || action == null) return;
    AppSnackBar.show(
      context: context,
      message: action.message,
      isError: !action.isSuccess,
    );
  }

  Future<void> _openAnimalDetails(AnimalEntity animal) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WebPageDialog(
        title: 'Detalhes do animal',
        width: 700,
        maxHeight: 760,
        child: DetailAnimal(animal: animal),
      ),
    );
  }

  Future<void> _openAddLot() async {
    final result = await openAnimalLotAdd(context);
    if (!mounted || result?['success'] != true) return;
    _pageController.handleLotCreated();
    await _loadLots();
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: result?['message']?.toString() ?? 'Lote salvo com sucesso.',
      isError: false,
    );
  }

  Future<void> _openEditLot(AnimalLotEntity lot) async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AnimalLotFormWebDialog.edit(lot: lot),
    );
    if (!mounted) return;
    final action = await _lotsController.handleEditResult(result);
    if (mounted && action != null) _lotsRevision.value++;
    if (!mounted || action == null) return;
    AppSnackBar.show(
      context: context,
      message: action.message,
      isError: !action.isSuccess,
    );
  }

  Future<void> _openAnimalFilter() async {
    final filter = _animalsController.currentFilter;
    final result = await showDialog<AnimalFilterSheetResult>(
      context: context,
      builder: (_) => _AnimalFilterWebDialog(
        initialBrinco: filter?.brinco,
        initialCategoryId: filter?.appAnimaisCategoriasId,
        initialSubcategoryId: filter?.appAnimaisSubcategoriasId,
        initialBaseRacialId: filter?.utBasesRaciaisId,
      ),
    );
    if (!mounted || result == null) return;
    final action = await _animalsController.applyFilters(result);
    if (mounted) {
      _animalsInitialized = true;
      _animalsRevision.value++;
    }
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: action.message,
      isError: !action.isSuccess,
    );
  }

  Future<void> _openLotFilter() async {
    final result = await showDialog<AnimalLotFilterSheetResult>(
      context: context,
      builder: (_) =>
          _LotFilterWebDialog(initialName: _lotsController.currentFilter?.nome),
    );
    if (!mounted || result == null) return;
    final action = await _lotsController.applyFilters(result);
    if (mounted) {
      _lotsInitialized = true;
      _lotsRevision.value++;
    }
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: action.message,
      isError: !action.isSuccess,
    );
  }

  Future<void> _confirmDeleteAnimal(AnimalEntity animal) async {
    final brinco = _animalTag(animal);
    final action = await showDialog<PageActionResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DeleteConfirmationDialog(
        title: 'Excluir animal',
        message: 'Tem certeza que deseja excluir $brinco permanentemente?',
        onConfirm: () => _animalsController.deleteAnimal(animal),
      ),
    );
    if (!mounted || action == null) return;
    _animalsRevision.value++;
    AppSnackBar.show(
      context: context,
      message: action.message,
      isError: !action.isSuccess,
    );
  }

  Future<void> _confirmDeleteLot(AnimalLotEntity lot) async {
    final action = await showDialog<PageActionResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DeleteConfirmationDialog(
        title: 'Excluir lote',
        message:
            'Tem certeza que deseja excluir o lote ${lot.nome} permanentemente?',
        onConfirm: () => _lotsController.deleteLot(lot),
      ),
    );
    if (!mounted || action == null) return;
    _lotsRevision.value++;
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
      builder: (context, _) => ColoredBox(
        color: Colors.white,
        child: Column(
          children: [
            _tabs(),
            const Divider(height: 1, color: Color(0xFFE7E4DD)),
            _toolbar(),
            const Divider(height: 1, color: Color(0xFFE7E4DD)),
            Expanded(child: _tabBody()),
          ],
        ),
      ),
    );
  }

  Widget _toolbar() {
    final animation = switch (_pageController.tabIndex) {
      0 => _chartsController,
      1 => _animalsController,
      _ => _lotsController,
    };
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => _toolbarContent(),
    );
  }

  Widget _toolbarContent() {
    final tab = _pageController.tabIndex;
    final isAnimals = tab == 1;
    final isLots = tab == 2;
    final loading = tab == 0
        ? _chartsController.isLoading
        : isAnimals
        ? _animalsController.isLoading
        : _lotsController.isLoading;
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
                    tab == 0
                        ? 'Indicadores do rebanho'
                        : isAnimals
                        ? _countLabel(
                            _animalsController.animals.length,
                            'animal',
                            'animais',
                          )
                        : _countLabel(
                            _lotsController.lots.length,
                            'lote',
                            'lotes',
                          ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _toolbarCaptionStyle,
                  ),
                )
              else
                const Spacer(),
              if (isAnimals || isLots) ...[
                _FilterButton(
                  active: isAnimals
                      ? _animalsController.hasActiveFilters()
                      : _lotsController.hasActiveFilters(),
                  onPressed: loading
                      ? null
                      : isAnimals
                      ? _openAnimalFilter
                      : _openLotFilter,
                ),
                const SizedBox(width: 8),
              ],
              _ToolbarIconButton(
                tooltip: tab == 0 ? 'Atualizar gráficos' : 'Atualizar lista',
                isLoading: loading,
                onPressed: loading
                    ? null
                    : tab == 0
                    ? _loadCharts
                    : isAnimals
                    ? _loadAnimals
                    : _loadLots,
              ),
              if (isAnimals || isLots) ...[
                const SizedBox(width: 8),
                _AddButton(
                  compact: compact,
                  label: isAnimals ? 'Adicionar animal' : 'Adicionar lote',
                  onPressed: loading
                      ? null
                      : isAnimals
                      ? _openAddAnimal
                      : _openAddLot,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _tabs() {
    return LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: constraints.maxWidth < 470 ? constraints.maxWidth : 470,
          child: TabBar(
            controller: _pageController.tabController,
            onTap: _pageController.setTabIndex,
            labelColor: const Color(0xFF313131),
            unselectedLabelColor: const Color(0xFF868686),
            indicatorColor: MyColors.colorPrimary2,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Dados'),
              Tab(text: 'Animais'),
              Tab(text: 'Lotes'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabBody() {
    final tab = _pageController.tabIndex;
    final revision = switch (tab) {
      0 => _chartsRevision,
      1 => _animalsRevision,
      _ => _lotsRevision,
    };
    final Listenable loadingAnimation = switch (tab) {
      0 => _chartsController,
      1 => _animalsController,
      _ => _lotsController,
    };
    bool isLoading() => switch (tab) {
      0 => _chartsController.isLoading,
      1 => _animalsController.isLoading,
      _ => _lotsController.isLoading,
    };
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: ValueListenableBuilder<int>(
            valueListenable: revision,
            builder: (context, _, __) => switch (tab) {
              0 => _chartsTab(),
              1 => _animalsTab(),
              _ => _lotsTab(),
            },
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

  Widget _chartsTab() {
    if (!_chartsInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    final charts = _chartsController.charts;
    if (_chartsController.isLoading && charts == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_chartsController.errorMessage != null && charts == null) {
      return _ErrorState(
        message: _chartsController.errorMessage!,
        onRetry: _chartsController.isLoading ? null : _loadCharts,
      );
    }
    if (charts == null || !_hasChartData(charts)) {
      return const _CenteredMessage('Nenhum dado disponível ainda.');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = constraints.maxWidth < 760 ? 16.0 : 28.0;
        final statsColumns = constraints.maxWidth >= 980
            ? 3
            : constraints.maxWidth >= 620
            ? 2
            : 1;
        final available = constraints.maxWidth - (padding * 2);
        final statWidth =
            (available - ((statsColumns - 1) * 12)) / statsColumns;
        final distributionsSideBySide = constraints.maxWidth >= 1040;
        return Stack(
          children: [
            Scrollbar(
              child: ListView(
                padding: EdgeInsets.fromLTRB(padding, 22, padding, 32),
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _StatCard(
                        width: statWidth,
                        title: 'Peso médio',
                        value: '${_formatDecimal(charts.pesoMedioFazenda)} kg',
                        subtitle:
                            'Baseado em ${charts.quantidadeAnimais} animais',
                        icon: LucideIcons.scale,
                      ),
                      _StatCard(
                        width: statWidth,
                        title: 'Total de UA',
                        value: '${_formatDecimal(charts.totalUa)} UA',
                        subtitle:
                            'Baseado em ${charts.quantidadeAnimais} animais',
                        icon: LucideIcons.activity,
                      ),
                      _StatCard(
                        width: statWidth,
                        title: 'Peso total do rebanho',
                        value: '${_formatDecimal(charts.pesoTotalRebanho)} kg',
                        subtitle: '${charts.quantidadeAnimais} animais',
                        icon: LucideIcons.barChart3,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (distributionsSideBySide)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _DistributionCard(
                              title: 'Composição do rebanho',
                              entries: [
                                for (final item in charts.distribuicaoCategoria)
                                  _DistributionEntry(
                                    label: item.categoria,
                                    amount: item.quantidade,
                                    percentage: item.percentual,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _DistributionCard(
                              title: 'Proporção por sexo',
                              entries: [
                                for (final item in charts.proporcaoSexo)
                                  _DistributionEntry(
                                    label: item.sexoNome,
                                    amount: item.quantidade,
                                    percentage: item.percentual,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    _DistributionCard(
                      title: 'Composição do rebanho',
                      entries: [
                        for (final item in charts.distribuicaoCategoria)
                          _DistributionEntry(
                            label: item.categoria,
                            amount: item.quantidade,
                            percentage: item.percentual,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _DistributionCard(
                      title: 'Proporção por sexo',
                      entries: [
                        for (final item in charts.proporcaoSexo)
                          _DistributionEntry(
                            label: item.sexoNome,
                            amount: item.quantidade,
                            percentage: item.percentual,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (_chartsController.isLoading)
              const Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(minHeight: 3),
              ),
          ],
        );
      },
    );
  }

  Widget _animalsTab() {
    if (!_animalsInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_animalsController.isLoading && _animalsController.animals.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_animalsController.errorMessage != null &&
        _animalsController.animals.isEmpty) {
      return _ErrorState(
        message: _animalsController.errorMessage!,
        onRetry: _animalsController.isLoading ? null : _loadAnimals,
      );
    }
    if (_animalsController.animals.isEmpty) {
      return WebEmptyState(
        icon: LucideIcons.tag,
        title: 'Nenhum animal cadastrado até agora.',
        description:
            'Use o botão Adicionar animal para cadastrar o primeiro animal.',
        actionLabel: 'Adicionar animal',
        onAction: _openAddAnimal,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => Scrollbar(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            constraints.maxWidth < 760 ? 16 : 28,
            22,
            constraints.maxWidth < 760 ? 16 : 28,
            32,
          ),
          children: [
            if (constraints.maxWidth >= 900)
              _animalsTable()
            else
              _animalStackedRows(),
          ],
        ),
      ),
    );
  }

  Widget _animalsTable() {
    return _TableShell(
      children: [
        const _TableHeader(
          columns: [
            _ColumnSpec('BRINCO', 3),
            _ColumnSpec('RESUMO', 4),
            _ColumnSpec('LOTE', 2),
            _ColumnSpec('POTREIRO', 2),
            _ColumnSpec('', 3),
          ],
        ),
        for (
          var index = 0;
          index < _animalsController.animals.length;
          index++
        ) ...[
          if (index > 0) const Divider(height: 1, color: Color(0xFFE7E4DD)),
          _AnimalTableRow(
            animal: _animalsController.animals[index],
            summary: _animalsController.buildSummary(
              _animalsController.animals[index],
            ),
            deleting: _animalsController.isDeleting,
            onOpen: () => _openAnimalDetails(_animalsController.animals[index]),
            onEdit: () => _openEditAnimal(_animalsController.animals[index]),
            onDelete: () =>
                _confirmDeleteAnimal(_animalsController.animals[index]),
          ),
        ],
      ],
    );
  }

  Widget _animalStackedRows() {
    return _TableShell(
      children: [
        for (
          var index = 0;
          index < _animalsController.animals.length;
          index++
        ) ...[
          if (index > 0) const Divider(height: 1, color: Color(0xFFE7E4DD)),
          _AnimalStackedRow(
            animal: _animalsController.animals[index],
            summary: _animalsController.buildSummary(
              _animalsController.animals[index],
            ),
            deleting: _animalsController.isDeleting,
            onOpen: () => _openAnimalDetails(_animalsController.animals[index]),
            onEdit: () => _openEditAnimal(_animalsController.animals[index]),
            onDelete: () =>
                _confirmDeleteAnimal(_animalsController.animals[index]),
          ),
        ],
      ],
    );
  }

  Widget _lotsTab() {
    if (!_lotsInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_lotsController.isLoading && _lotsController.lots.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_lotsController.errorMessage != null && _lotsController.lots.isEmpty) {
      return _ErrorState(
        message: _lotsController.errorMessage!,
        onRetry: _lotsController.isLoading ? null : _loadLots,
      );
    }
    if (_lotsController.lots.isEmpty) {
      return WebEmptyState(
        icon: LucideIcons.clipboardList,
        title: 'Nenhum lote cadastrado até agora.',
        description:
            'Use o botão Adicionar lote para cadastrar o primeiro lote.',
        actionLabel: 'Adicionar lote',
        onAction: _openAddLot,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => Scrollbar(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            constraints.maxWidth < 760 ? 16 : 28,
            22,
            constraints.maxWidth < 760 ? 16 : 28,
            32,
          ),
          children: [
            if (constraints.maxWidth >= 760)
              _lotsTable()
            else
              _lotStackedRows(),
          ],
        ),
      ),
    );
  }

  Widget _lotsTable() {
    return _TableShell(
      children: [
        const _TableHeader(
          columns: [
            _ColumnSpec('NOME', 5),
            _ColumnSpec('ANIMAIS', 2),
            _ColumnSpec('CATEGORIA', 3),
            _ColumnSpec('', 3),
          ],
        ),
        for (var index = 0; index < _lotsController.lots.length; index++) ...[
          if (index > 0) const Divider(height: 1, color: Color(0xFFE7E4DD)),
          _LotTableRow(
            lot: _lotsController.lots[index],
            deleting: _lotsController.isDeleting,
            onEdit: () => _openEditLot(_lotsController.lots[index]),
            onDelete: () => _confirmDeleteLot(_lotsController.lots[index]),
          ),
        ],
      ],
    );
  }

  Widget _lotStackedRows() {
    return _TableShell(
      children: [
        for (var index = 0; index < _lotsController.lots.length; index++) ...[
          if (index > 0) const Divider(height: 1, color: Color(0xFFE7E4DD)),
          _LotStackedRow(
            lot: _lotsController.lots[index],
            deleting: _lotsController.isDeleting,
            onEdit: () => _openEditLot(_lotsController.lots[index]),
            onDelete: () => _confirmDeleteLot(_lotsController.lots[index]),
          ),
        ],
      ],
    );
  }
}

class _AnimalFilterWebDialog extends StatefulWidget {
  const _AnimalFilterWebDialog({
    this.initialBrinco,
    this.initialCategoryId,
    this.initialSubcategoryId,
    this.initialBaseRacialId,
  });

  final String? initialBrinco;
  final int? initialCategoryId;
  final int? initialSubcategoryId;
  final int? initialBaseRacialId;

  @override
  State<_AnimalFilterWebDialog> createState() => _AnimalFilterWebDialogState();
}

class _AnimalFilterWebDialogState extends State<_AnimalFilterWebDialog> {
  final GetListUsecase _getListUsecase = Modular.get<GetListUsecase>();
  late final TextEditingController _tagController;
  bool _isLoading = true;
  String? _errorMessage;
  List<ListCategoryEntity> _categories = const [];
  List<ListItemEntity> _bases = const [];
  int? _categoryId;
  int? _subcategoryId;
  int? _baseId;

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController(text: widget.initialBrinco ?? '');
    _tagController.addListener(_changed);
    _categoryId = widget.initialCategoryId;
    _subcategoryId = widget.initialSubcategoryId;
    _baseId = widget.initialBaseRacialId;
    _loadOptions();
  }

  @override
  void dispose() {
    _tagController.removeListener(_changed);
    _tagController.dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  List<ListSubcategoryEntity> get _subcategories {
    for (final category in _categories) {
      if (category.id == _categoryId) return category.subcategorias;
    }
    return const [];
  }

  bool get _hasFilters =>
      _tagController.text.trim().isNotEmpty ||
      _categoryId != null ||
      _subcategoryId != null ||
      _baseId != null;

  Future<void> _loadOptions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final session = await SessionStorage.getUserSession();
      final userId = session == null ? null : sessionAccountUserId(session.id);
      final lists = await Future.wait<GetListEntity>([
        _getListUsecase(GetListParamsEntity(sexo: 1, userId: userId)),
        _getListUsecase(GetListParamsEntity(sexo: 2, userId: userId)),
      ]);
      final categories = <int, ListCategoryEntity>{};
      final bases = <int, ListItemEntity>{};
      for (final list in lists) {
        for (final category in list.animaisCategorias) {
          categories[category.id] = category;
        }
        for (final base in list.animaisBasesRaciais) {
          bases[base.id] = base;
        }
      }
      _categories = categories.values.toList()
        ..sort((a, b) => a.nome.compareTo(b.nome));
      _bases = bases.values.toList()..sort((a, b) => a.nome.compareTo(b.nome));
      if (!_categories.any((item) => item.id == _categoryId)) {
        _categoryId = null;
        _subcategoryId = null;
      }
      if (!_bases.any((item) => item.id == _baseId)) _baseId = null;
      if (!_subcategories.any((item) => item.id == _subcategoryId)) {
        _subcategoryId = null;
      }
    } catch (_) {
      _errorMessage = 'Nao foi possivel carregar os filtros.';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _apply() {
    final tag = _tagController.text.trim();
    Navigator.pop(
      context,
      AnimalFilterSheetResult.apply(
        brinco: tag.isEmpty ? null : tag,
        appAnimaisCategoriasId: _categoryId,
        appAnimaisSubcategoriasId: _subcategoryId,
        utBasesRaciaisId: _baseId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WebDialogFrame(
      title: 'Filtrar animais',
      width: 620,
      maxHeight: 690,
      footer: _DialogActions(
        canClear: _hasFilters,
        onClear: () =>
            Navigator.pop(context, const AnimalFilterSheetResult.clear()),
        onApply: _apply,
      ),
      bodyPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: _isLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          : _errorMessage != null
          ? _ErrorState(message: _errorMessage!, onRetry: _loadOptions)
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(
                  label: 'Brinco',
                  child: TextField(
                    controller: _tagController,
                    decoration: _inputDecoration('Ex: BR12123'),
                  ),
                ),
                _SelectField(
                  label: 'Categoria',
                  value: _categoryId,
                  options: [
                    for (final item in _categories)
                      AppSelectOption(value: item.id, label: item.nome),
                  ],
                  onChanged: (value) => setState(() {
                    _categoryId = value;
                    _subcategoryId = null;
                  }),
                ),
                if (_categoryId != null && _subcategories.isNotEmpty)
                  _SelectField(
                    label: 'Subcategoria',
                    value: _subcategoryId,
                    options: [
                      for (final item in _subcategories)
                        AppSelectOption(
                          value: item.id,
                          label: item.nome,
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => _subcategoryId = value),
                  ),
                _SelectField(
                  label: 'Base racial',
                  value: _baseId,
                  options: [
                    for (final item in _bases)
                      AppSelectOption(value: item.id, label: item.nome),
                  ],
                  onChanged: (value) => setState(() => _baseId = value),
                ),
              ],
            ),
    );
  }
}

class _LotFilterWebDialog extends StatefulWidget {
  const _LotFilterWebDialog({this.initialName});

  final String? initialName;

  @override
  State<_LotFilterWebDialog> createState() => _LotFilterWebDialogState();
}

class _LotFilterWebDialogState extends State<_LotFilterWebDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
    _controller.addListener(_changed);
  }

  @override
  void dispose() {
    _controller.removeListener(_changed);
    _controller.dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasName = _controller.text.trim().isNotEmpty;
    return WebDialogFrame(
      title: 'Filtrar lotes',
      width: 560,
      maxHeight: 360,
      footer: _DialogActions(
        canClear: hasName,
        onClear: () => Navigator.pop(
          context,
          const AnimalLotFilterSheetResult.clear(),
        ),
        onApply: () {
          final name = _controller.text.trim();
          Navigator.pop(
            context,
            AnimalLotFilterSheetResult.apply(
              nome: name.isEmpty ? null : name,
            ),
          );
        },
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        child: _FieldLabel(
          label: 'Nome',
          child: TextField(
            controller: _controller,
            decoration: _inputDecoration('Insira aqui...'),
          ),
        ),
      ),
    );
  }
}

class _DialogActions extends StatelessWidget {
  const _DialogActions({
    required this.canClear,
    required this.onClear,
    required this.onApply,
  });

  final bool canClear;
  final VoidCallback onClear;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: canClear ? onClear : null,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(110, 46),
              foregroundColor: MyColors.colorPrimary,
              side: const BorderSide(color: MyColors.colorPrimary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Limpar'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onApply,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              minimumSize: const Size(110, 46),
              backgroundColor: MyColors.colorPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final int? value;
  final List<AppSelectOption<int>> options;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return _FieldLabel(
      label: label,
      child: AppSelectOverlay<int>(
        value: value,
        options: options,
        onChanged: onChanged,
        placeholder: 'Selecionar',
        fieldColor: Colors.white,
        menuColor: Colors.white,
        border: Border.all(color: const Color(0xFFD8D5CE)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _fieldLabelStyle),
          const SizedBox(height: 7),
          child,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.width,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final double width;
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE7E4DD)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5EC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: MyColors.colorPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _cardLabelStyle),
                  const SizedBox(height: 5),
                  Text(value, style: _statValueStyle),
                  const SizedBox(height: 3),
                  Text(subtitle, style: _mutedStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DistributionEntry {
  const _DistributionEntry({
    required this.label,
    required this.amount,
    required this.percentage,
  });

  final String label;
  final int amount;
  final double percentage;
}

class _DistributionCard extends StatelessWidget {
  const _DistributionCard({required this.title, required this.entries});

  final String title;
  final List<_DistributionEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 230),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7E4DD)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _sectionTitleStyle),
          const SizedBox(height: 20),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 46),
              child: Center(child: Text('Nenhum dado disponível.')),
            )
          else
            for (final entry in entries) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _rowPrimaryStyle,
                    ),
                  ),
                  Text(
                    '${entry.amount} · ${_formatDecimal(entry.percentage)}%',
                    style: _mutedStyle,
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 9,
                  value: (entry.percentage / 100).clamp(0, 1),
                  backgroundColor: const Color(0xFFECEAE4),
                  color: MyColors.colorPrimary,
                ),
              ),
              const SizedBox(height: 17),
            ],
        ],
      ),
    );
  }
}

class _TableShell extends StatelessWidget {
  const _TableShell({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E4DD)),
      ),
      child: Column(children: children),
    );
  }
}

class _ColumnSpec {
  const _ColumnSpec(this.label, this.flex);

  final String label;
  final int flex;
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.columns});

  final List<_ColumnSpec> columns;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F7F3),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: Row(
        children: [
          for (final column in columns)
            Expanded(
              flex: column.flex,
              child: Text(column.label, style: _tableHeaderStyle),
            ),
        ],
      ),
    );
  }
}

class _AnimalTableRow extends StatelessWidget {
  const _AnimalTableRow({
    required this.animal,
    required this.summary,
    required this.deleting,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final AnimalEntity animal;
  final String summary;
  final bool deleting;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AnimalTagLabel(animal: animal),
                  SubUserFlag(nome: animal.subUsuarioNome),
                ],
              ),
            ),
            Expanded(flex: 4, child: Text(summary, style: _rowTextStyle)),
            Expanded(
              flex: 2,
              child: Text(
                _referenceName(animal.lote?.nome),
                style: _rowTextStyle,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _referenceName(animal.potreiro?.nome),
                style: _rowTextStyle,
              ),
            ),
            Expanded(
              flex: 3,
              child: _RowActions(
                deleting: deleting,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimalStackedRow extends StatelessWidget {
  const _AnimalStackedRow({
    required this.animal,
    required this.summary,
    required this.deleting,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final AnimalEntity animal;
  final String summary;
  final bool deleting;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AnimalTagLabel(animal: animal),
            SubUserFlag(nome: animal.subUsuarioNome),
            const SizedBox(height: 8),
            Text(summary, style: _rowTextStyle),
            const SizedBox(height: 5),
            Text(
              'Lote: ${_referenceName(animal.lote?.nome)}  ·  Potreiro: ${_referenceName(animal.potreiro?.nome)}',
              style: _mutedStyle,
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: _RowActions(
                deleting: deleting,
                onEdit: onEdit,
                onDelete: onDelete,
                expanded: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimalTagLabel extends StatelessWidget {
  const _AnimalTagLabel({required this.animal});

  final AnimalEntity animal;

  @override
  Widget build(BuildContext context) {
    final hasTag = animal.brinco?.trim().isNotEmpty ?? false;
    if (hasTag) return Text(_animalTag(animal), style: _rowPrimaryStyle);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF0EFEA),
          borderRadius: BorderRadius.circular(7),
        ),
        child: const Text(
          'Brinco não cadastrado',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
          ),
        ),
      ),
    );
  }
}

class _LotTableRow extends StatelessWidget {
  const _LotTableRow({
    required this.lot,
    required this.deleting,
    required this.onEdit,
    required this.onDelete,
  });

  final AnimalLotEntity lot;
  final bool deleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: Row(
        children: [
          Expanded(flex: 5, child: Text(lot.nome, style: _rowPrimaryStyle)),
          Expanded(
            flex: 2,
            child: Text(lot.animalsCount.toString(), style: _rowTextStyle),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _referenceName(lot.categoriaNome),
              style: _rowTextStyle,
            ),
          ),
          Expanded(
            flex: 3,
            child: _RowActions(
              deleting: deleting,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}

class _LotStackedRow extends StatelessWidget {
  const _LotStackedRow({
    required this.lot,
    required this.deleting,
    required this.onEdit,
    required this.onDelete,
  });

  final AnimalLotEntity lot;
  final bool deleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final category = lot.categoriaNome?.trim();
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lot.nome, style: _rowPrimaryStyle),
                const SizedBox(height: 6),
                Text(
                  '${lot.animalsCount} animais${category == null || category.isEmpty ? '' : ' · $category'}',
                  style: _mutedStyle,
                ),
              ],
            ),
          ),
          _RowActions(deleting: deleting, onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }
}

class _RowActions extends StatelessWidget {
  const _RowActions({
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
    final edit = SizedBox(
      width: expanded ? null : 88,
      height: 38,
      child: OutlinedButton.icon(
        onPressed: deleting ? null : onEdit,
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
        onPressed: deleting ? null : onDelete,
        icon: deleting
            ? const SizedBox.square(
                dimension: 15,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(LucideIcons.trash2, size: 15),
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
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (expanded) Expanded(child: edit) else edit,
        const SizedBox(width: 8),
        if (expanded) Expanded(child: remove) else remove,
      ],
    );
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
    required this.isLoading,
    required this.onPressed,
  });

  final String tooltip;
  final bool isLoading;
  final VoidCallback? onPressed;

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
              : const Icon(LucideIcons.refreshCw, size: 17),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.compact,
    required this.label,
    required this.onPressed,
  });

  final bool compact;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? 126 : 170,
      height: 46,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded, size: 19),
        label: Text(compact ? 'Adicionar' : label),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          backgroundColor: MyColors.colorPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFBFC9C5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center, style: _rowTextStyle),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center, style: _emptyStyle),
      ),
    );
  }
}

class _DialogTitle extends StatelessWidget {
  const _DialogTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: _dialogTitleStyle);
}

class _DeleteConfirmationDialog extends StatefulWidget {
  const _DeleteConfirmationDialog({
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final Future<PageActionResult> Function() onConfirm;

  @override
  State<_DeleteConfirmationDialog> createState() =>
      _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<_DeleteConfirmationDialog> {
  bool _deleting = false;

  Future<void> _confirm() async {
    setState(() => _deleting = true);
    final result = await widget.onConfirm();
    if (!mounted) return;
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: _DialogTitle(widget.title),
      content: Text(widget.message, style: _dialogBodyStyle),
      actions: [
        TextButton(
          onPressed: _deleting ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        OutlinedButton(
          onPressed: _deleting ? null : _confirm,
          style: _dangerButtonStyle,
          child: Text(_deleting ? 'Excluindo...' : 'Excluir'),
        ),
      ],
    );
  }
}

bool _hasChartData(AnimalChartsEntity charts) {
  return charts.quantidadeAnimais > 0 ||
      charts.pesoTotalRebanho != 0 ||
      charts.pesoMedioFazenda != 0 ||
      charts.totalUa != 0 ||
      charts.distribuicaoCategoria.isNotEmpty ||
      charts.proporcaoSexo.isNotEmpty;
}

String _animalTag(AnimalEntity animal) {
  final tag = animal.brinco?.trim();
  return tag == null || tag.isEmpty ? 'Brinco não cadastrado' : tag;
}

String _referenceName(String? value) {
  final text = value?.trim();
  return text == null || text.isEmpty ? '-' : text;
}

String _formatDecimal(num value) {
  final number = value.toDouble();
  return number == number.truncateToDouble()
      ? number.toInt().toString()
      : number.toStringAsFixed(2).replaceAll('.', ',');
}

String _countLabel(int count, String singular, String plural) {
  return count == 1 ? '1 $singular cadastrado' : '$count $plural cadastrados';
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFD8D5CE)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: MyColors.colorPrimary),
    ),
  );
}

final ButtonStyle _dangerButtonStyle = OutlinedButton.styleFrom(
  foregroundColor: const Color(0xFFC4473A),
  side: const BorderSide(color: Color(0xFFC4473A)),
);

const TextStyle _toolbarCaptionStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 13,
  fontWeight: FontWeight.w600,
  color: Color(0xFF777777),
);

const TextStyle _tableHeaderStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 10,
  fontWeight: FontWeight.w700,
  color: Color(0xFF686868),
);

const TextStyle _rowPrimaryStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 13,
  fontWeight: FontWeight.w700,
  color: Color(0xFF313131),
);

const TextStyle _rowTextStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: Color(0xFF555555),
);

const TextStyle _mutedStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 11,
  fontWeight: FontWeight.w500,
  color: Color(0xFF858585),
);

const TextStyle _cardLabelStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: Color(0xFF6B6B6B),
);

const TextStyle _statValueStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 22,
  fontWeight: FontWeight.w700,
  color: Color(0xFF173D2A),
);

const TextStyle _sectionTitleStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: Color(0xFF313131),
);

const TextStyle _fieldLabelStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 13,
  fontWeight: FontWeight.w600,
  color: Color(0xFF313131),
);

const TextStyle _emptyStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: Color(0xFF858585),
);

const TextStyle _dialogTitleStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 18,
  fontWeight: FontWeight.w700,
);

const TextStyle _dialogBodyStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14,
  height: 1.45,
  color: Color(0xFF666666),
);
