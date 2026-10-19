import 'dart:math' as math;

import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/core/components/sub_user_flag.dart';
import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:costeira/core/components/web_empty_state.dart';
import 'package:costeira/core/components/web_page_dialog.dart';
import 'package:costeira/features/tasks/domain/entities/task_charts_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_filter_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_responsavel_entity.dart';
import 'package:costeira/features/tasks/presentation/controllers/get_task_charts_controller.dart';
import 'package:costeira/features/tasks/presentation/controllers/list_task_responsaveis_controller.dart';
import 'package:costeira/features/tasks/presentation/controllers/list_tasks_controller.dart';
import 'package:costeira/features/tasks/presentation/helpers/task_formatters.dart';
import 'package:costeira/features/tasks/presentation/pages/add_tarefa.dart';
import 'package:costeira/features/tasks/presentation/pages/add_task_responsavel.dart';
import 'package:costeira/features/tasks/presentation/pages/edit_task.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TasksWebPage extends StatefulWidget {
  const TasksWebPage({super.key});

  @override
  State<TasksWebPage> createState() => _TasksWebPageState();
}

class _TasksWebPageState extends State<TasksWebPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ListTasksController _tasksController;
  late final ListTaskResponsaveisController _responsaveisController;
  late final GetTaskChartsController _chartsController;

  final ValueNotifier<int> _listRevision = ValueNotifier(0);
  final ValueNotifier<int> _responsaveisRevision = ValueNotifier(0);
  final ValueNotifier<int> _chartsRevision = ValueNotifier(0);

  int _tabIndex = 0;
  int? _busyTaskId;
  int? _busyResponsavelId;
  bool _listInitialized = false;
  bool _responsaveisInitialized = false;
  bool _chartsInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _tasksController = Modular.get<ListTasksController>();
    _responsaveisController = Modular.get<ListTaskResponsaveisController>();
    _chartsController = Modular.get<GetTaskChartsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadTasks();
      _loadResponsaveis();
      _loadCharts();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _listRevision.dispose();
    _responsaveisRevision.dispose();
    _chartsRevision.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabIndex == _tabController.index) return;
    setState(() => _tabIndex = _tabController.index);
  }

  bool _hasActiveFilters(TaskFilterEntity filter) {
    return filter.dataIn != null ||
        filter.dataOut != null ||
        filter.urgencia != null ||
        filter.status != null;
  }

  Future<void> _loadTasks({TaskFilterEntity? filter}) async {
    try {
      await _tasksController.load(filter: filter);
    } catch (error) {
      if (mounted && error is! ApiException) {
        AppSnackBar.show(
          context: context,
          message: 'Nao foi possivel listar as tarefas.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        _listInitialized = true;
        _listRevision.value++;
      }
    }
  }

  Future<void> _loadResponsaveis() async {
    try {
      await _responsaveisController.load();
    } catch (error) {
      if (mounted && error is! ApiException) {
        AppSnackBar.show(
          context: context,
          message: 'Nao foi possivel listar os responsaveis.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        _responsaveisInitialized = true;
        _responsaveisRevision.value++;
      }
    }
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

  Future<void> _previousListMonth() async {
    if (_tasksController.isLoading) return;
    final current = _tasksController.filter.month ?? DateTime.now();
    await _loadTasks(
      filter: _tasksController.filter.copyWith(
        month: DateTime(current.year, current.month - 1),
      ),
    );
  }

  Future<void> _nextListMonth() async {
    if (_tasksController.isLoading) return;
    final current = _tasksController.filter.month ?? DateTime.now();
    await _loadTasks(
      filter: _tasksController.filter.copyWith(
        month: DateTime(current.year, current.month + 1),
      ),
    );
  }

  Future<void> _previousChartsMonth() async {
    try {
      await _chartsController.previousMonth();
    } catch (_) {
    } finally {
      if (mounted) {
        _chartsInitialized = true;
        _chartsRevision.value++;
      }
    }
  }

  Future<void> _nextChartsMonth() async {
    try {
      await _chartsController.nextMonth();
    } catch (_) {
    } finally {
      if (mounted) {
        _chartsInitialized = true;
        _chartsRevision.value++;
      }
    }
  }

  Future<void> _openFilter() async {
    if (_tasksController.isLoading) return;
    final result = await showDialog<TaskFilterEntity>(
      context: context,
      builder: (_) => _TaskFilterWebDialog(
        initialFilter: _tasksController.filter,
      ),
    );
    if (!mounted || result == null) return;
    await _loadTasks(filter: result);
  }

  Future<void> _openTaskForm([TaskEntity? task]) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WebPageDialog(
        title: task == null ? 'Adicionar tarefa' : 'Editar tarefa',
        width: 720,
        maxHeight: 840,
        child: task == null ? const AddTask() : EditTask(task: task),
      ),
    );
    if (!mounted) return;
    await _loadTasks();
  }

  Future<void> _openTaskDetails(TaskEntity task) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TaskDetailsWebDialog(task: task),
    );
  }

  Future<void> _openResponsavelForm([TaskResponsavelEntity? responsavel]) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WebPageDialog(
        title: responsavel == null
            ? 'Adicionar responsável'
            : 'Editar responsável',
        width: 640,
        maxHeight: 720,
        child: AddTaskResponsavel(responsavel: responsavel),
      ),
    );
    if (!mounted) return;
    await _loadResponsaveis();
  }

  Future<void> _openResponsavelDetails(
    TaskResponsavelEntity responsavel,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResponsavelDetailsWebDialog(responsavel: responsavel),
    );
  }

  Future<void> _confirmDeleteTask(TaskEntity task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Excluir tarefa',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Tem certeza que deseja excluir essa tarefa permanentemente?',
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
    setState(() => _busyTaskId = task.id);
    try {
      final message = await _tasksController.deleteTask(task);
      if (mounted) _listRevision.value++;
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message: message.message,
        isError: false,
      );
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message: error is ApiException
            ? error.message
            : 'Nao foi possivel excluir a tarefa.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _busyTaskId = null);
    }
  }

  Future<void> _setDone(TaskEntity task) async {
    setState(() => _busyTaskId = task.id);
    try {
      final message = await _tasksController.setDone(task);
      if (mounted) _listRevision.value++;
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message: message.message,
        isError: false,
      );
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message: error is ApiException
            ? error.message
            : 'Nao foi possivel concluir a tarefa.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _busyTaskId = null);
    }
  }

  Future<void> _confirmDeleteResponsavel(
    TaskResponsavelEntity responsavel,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Excluir responsável',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Tem certeza que deseja excluir ${responsavel.nome} permanentemente?',
          style: const TextStyle(
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
    setState(() => _busyResponsavelId = responsavel.id);
    try {
      final message = await _responsaveisController.deleteResponsavel(
        responsavel,
      );
      if (mounted) _responsaveisRevision.value++;
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message: message.message,
        isError: false,
      );
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message: error is ApiException
            ? error.message
            : 'Nao foi possivel excluir o responsavel.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _busyResponsavelId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
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
  }

  Widget _tabs() {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 420,
        child: TabBar(
          controller: _tabController,
          onTap: (index) => setState(() => _tabIndex = index),
          tabs: const [
            Tab(text: 'Lista'),
            Tab(text: 'Responsáveis'),
            Tab(text: 'Gráficos'),
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
    final Listenable animation = switch (_tabIndex) {
      0 => _tasksController,
      1 => _responsaveisController,
      _ => _chartsController,
    };
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => _toolbarContent(),
    );
  }

  Widget _toolbarContent() {
    final isList = _tabIndex == 0;
    final isResponsaveis = _tabIndex == 1;
    final isLoading = switch (_tabIndex) {
      0 => _tasksController.isLoading,
      1 => _responsaveisController.isLoading,
      _ => _chartsController.isLoading,
    };
    final listCount = _tasksController.tasks.length;
    final responsaveisCount = _responsaveisController.responsaveis.length;

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
                        ? listCount == 1
                              ? '1 tarefa'
                              : '$listCount tarefas'
                        : isResponsaveis
                        ? responsaveisCount == 1
                              ? '1 responsável'
                              : '$responsaveisCount responsáveis'
                        : 'Indicadores mensais de tarefas',
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
                  active: _hasActiveFilters(_tasksController.filter),
                  onPressed: isLoading ? null : _openFilter,
                ),
                const SizedBox(width: 8),
              ],
              _ToolbarIconButton(
                tooltip: isList
                    ? 'Atualizar lista'
                    : isResponsaveis
                    ? 'Atualizar responsáveis'
                    : 'Atualizar gráficos',
                icon: LucideIcons.refreshCw,
                isLoading: isLoading,
                onPressed: isLoading
                    ? null
                    : isList
                    ? () => _loadTasks()
                    : isResponsaveis
                    ? _loadResponsaveis
                    : _loadCharts,
              ),
              if (isList || isResponsaveis) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: compact
                      ? 126
                      : isResponsaveis
                      ? 210
                      : 170,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : isList
                        ? () => _openTaskForm()
                        : () => _openResponsavelForm(),
                    icon: const Icon(Icons.add_rounded, size: 19),
                    label: Text(
                      compact
                          ? 'Adicionar'
                          : isList
                          ? 'Adicionar tarefa'
                          : 'Adicionar responsável',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                    ),
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
    final revision = switch (_tabIndex) {
      0 => _listRevision,
      1 => _responsaveisRevision,
      _ => _chartsRevision,
    };
    final Listenable loadingAnimation = switch (_tabIndex) {
      0 => _tasksController,
      1 => _responsaveisController,
      _ => _chartsController,
    };
    bool isLoading() => switch (_tabIndex) {
      0 => _tasksController.isLoading,
      1 => _responsaveisController.isLoading,
      _ => _chartsController.isLoading,
    };

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: ValueListenableBuilder<int>(
            valueListenable: revision,
            builder: (context, _, __) => switch (_tabIndex) {
              0 => _listTab(),
              1 => _responsaveisTab(),
              _ => _chartsTab(),
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

  Widget _listTab() {
    if (!_listInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_tasksController.isLoading && _tasksController.tasks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_tasksController.errorMessage != null &&
        _tasksController.tasks.isEmpty) {
      return _WebStateMessage(
        message: _tasksController.errorMessage!,
        actionLabel: 'Tentar novamente',
        onAction: () => _loadTasks(),
      );
    }
    if (_tasksController.tasks.isEmpty) {
      return WebEmptyState(
        icon: LucideIcons.checkSquare,
        title: 'Nenhuma tarefa encontrada.',
        description: 'Use o botão Adicionar tarefa para criar a primeira.',
        actionLabel: 'Adicionar tarefa',
        onAction: () => _openTaskForm(),
      );
    }

    final tasks = _tasksController.tasks;
    final pending = tasks.where((task) => !task.isDone).length;
    final done = tasks.where((task) => task.isDone).length;
    final execution = tasks.isEmpty
        ? 0
        : ((done / tasks.length) * 100).round();

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final horizontal = constraints.maxWidth < 720 ? 16.0 : 28.0;
        return Scrollbar(
          child: ListView(
            padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 32),
            children: [
              _MonthSelector(
                month: _tasksController.filter.month ?? DateTime.now(),
                isLoading: _tasksController.isLoading,
                onPrevious: _previousListMonth,
                onNext: _nextListMonth,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Tarefas pendentes',
                      value: pending.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Execução',
                      value: '$execution%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                    if (wide) const _TaskTableHeader(),
                    for (var index = 0; index < tasks.length; index++) ...[
                      if (index > 0)
                        const Divider(height: 1, color: Color(0xFFE7E4DD)),
                      if (wide)
                        _TaskTableRow(
                          task: tasks[index],
                          busy: _busyTaskId == tasks[index].id,
                          onOpen: () => _openTaskDetails(tasks[index]),
                          onEdit: () => _openTaskForm(tasks[index]),
                          onDelete: () => _confirmDeleteTask(tasks[index]),
                          onToggleDone: () => _setDone(tasks[index]),
                        )
                      else
                        _TaskStackedRow(
                          task: tasks[index],
                          busy: _busyTaskId == tasks[index].id,
                          onOpen: () => _openTaskDetails(tasks[index]),
                          onEdit: () => _openTaskForm(tasks[index]),
                          onDelete: () => _confirmDeleteTask(tasks[index]),
                          onToggleDone: () => _setDone(tasks[index]),
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

  Widget _responsaveisTab() {
    if (!_responsaveisInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_responsaveisController.isLoading &&
        _responsaveisController.responsaveis.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_responsaveisController.errorMessage != null &&
        _responsaveisController.responsaveis.isEmpty) {
      return _WebStateMessage(
        message: _responsaveisController.errorMessage!,
        actionLabel: 'Tentar novamente',
        onAction: _loadResponsaveis,
      );
    }
    if (_responsaveisController.responsaveis.isEmpty) {
      return WebEmptyState(
        icon: LucideIcons.users,
        title: 'Nenhum responsável cadastrado.',
        description: 'Cadastre um responsável para vincular às tarefas.',
        actionLabel: 'Adicionar responsável',
        onAction: () => _openResponsavelForm(),
      );
    }

    final itens = _responsaveisController.responsaveis;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final horizontal = constraints.maxWidth < 720 ? 16.0 : 28.0;
        return Scrollbar(
          child: ListView(
            padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 32),
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
                    if (wide) const _ResponsavelTableHeader(),
                    for (var index = 0; index < itens.length; index++) ...[
                      if (index > 0)
                        const Divider(height: 1, color: Color(0xFFE7E4DD)),
                      if (wide)
                        _ResponsavelTableRow(
                          responsavel: itens[index],
                          busy: _busyResponsavelId == itens[index].id,
                          onOpen: () => _openResponsavelDetails(itens[index]),
                          onEdit: () => _openResponsavelForm(itens[index]),
                          onDelete: () =>
                              _confirmDeleteResponsavel(itens[index]),
                        )
                      else
                        _ResponsavelStackedRow(
                          responsavel: itens[index],
                          busy: _busyResponsavelId == itens[index].id,
                          onOpen: () => _openResponsavelDetails(itens[index]),
                          onEdit: () => _openResponsavelForm(itens[index]),
                          onDelete: () =>
                              _confirmDeleteResponsavel(itens[index]),
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

  Widget _chartsTab() {
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
    final data = charts ?? TaskChartsEntity.empty;
    final empty =
        data.programadas.quantidade == 0 &&
        data.atrasadas.quantidade == 0 &&
        data.realizadas.quantidade == 0 &&
        data.rankingFuncionarios.isEmpty;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        final horizontal = constraints.maxWidth < 720 ? 16.0 : 28.0;
        return Scrollbar(
          child: ListView(
            padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 32),
            children: [
              _MonthSelector(
                month: _chartsController.month,
                isLoading: _chartsController.isLoading,
                onPrevious: _previousChartsMonth,
                onNext: _nextChartsMonth,
              ),
              const SizedBox(height: 16),
              if (empty)
                const SizedBox(
                  height: 360,
                  child: WebEmptyState(
                    icon: LucideIcons.pieChart,
                    title: 'Sem dados para exibir neste período.',
                  ),
                )
              else ...[
                if (wide)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _ExecucaoCard(charts: data)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _RealizadasCard(
                            percentual: data.realizadas.percentual,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  _ExecucaoCard(charts: data),
                  const SizedBox(height: 16),
                  _RealizadasCard(percentual: data.realizadas.percentual),
                ],
                const SizedBox(height: 16),
                if (wide)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _MetricStatCard(
                            title: 'Programadas',
                            value: '${data.programadas.quantidade}',
                            subtitle:
                                '${_formatPercent(data.programadas.percentual)}%',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _MetricStatCard(
                            title: 'Atrasadas',
                            value: '${data.atrasadas.quantidade}',
                            subtitle:
                                '${_formatPercent(data.atrasadas.percentual)}%',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _MetricStatCard(
                            title: 'Realizadas',
                            value: '${data.realizadas.quantidade}',
                            subtitle:
                                '${_formatPercent(data.realizadas.percentual)}%',
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  _MetricStatCard(
                    title: 'Programadas',
                    value: '${data.programadas.quantidade}',
                    subtitle: '${_formatPercent(data.programadas.percentual)}%',
                  ),
                  const SizedBox(height: 12),
                  _MetricStatCard(
                    title: 'Atrasadas',
                    value: '${data.atrasadas.quantidade}',
                    subtitle: '${_formatPercent(data.atrasadas.percentual)}%',
                  ),
                  const SizedBox(height: 12),
                  _MetricStatCard(
                    title: 'Realizadas',
                    value: '${data.realizadas.quantidade}',
                    subtitle: '${_formatPercent(data.realizadas.percentual)}%',
                  ),
                ],
                const SizedBox(height: 16),
                _RankingCard(items: data.rankingFuncionarios),
              ],
            ],
          ),
        );
      },
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

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.month,
    required this.isLoading,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final bool isLoading;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E4DD)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: isLoading ? null : onPrevious,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Text(
            formatTaskMonth(month),
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: isLoading ? null : onNext,
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E4DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 18,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskTableHeader extends StatelessWidget {
  const _TaskTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F7F3),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: const Row(
        children: [
          SizedBox(width: 90, child: _HeaderText('Status')),
          SizedBox(width: 16),
          Expanded(flex: 3, child: _HeaderText('Tarefa')),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _HeaderText('Urgência')),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _HeaderText('Responsável')),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _HeaderText('Prazo')),
          SizedBox(width: 16),
          SizedBox(width: 260),
        ],
      ),
    );
  }
}

class _ResponsavelTableHeader extends StatelessWidget {
  const _ResponsavelTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F7F3),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: const Row(
        children: [
          Expanded(flex: 3, child: _HeaderText('Nome')),
          SizedBox(width: 16),
          Expanded(flex: 3, child: _HeaderText('Email')),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _HeaderText('Celular')),
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

class _TaskTableRow extends StatelessWidget {
  const _TaskTableRow({
    required this.task,
    required this.busy,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleDone,
  });

  final TaskEntity task;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleDone;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: busy ? null : onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: _StatusFlag(task: task),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.descricao,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF313131),
                        fontSize: 13,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SubUserFlag(nome: task.subUsuarioNome),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _CellText(task.urgenciaNome)),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _CellText(task.responsavel?.nome ?? 'Sem responsavel'),
              ),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _CellText(_taskDatesLabel(task))),
              const SizedBox(width: 16),
              SizedBox(
                width: 260,
                child: _TaskActions(
                  busy: busy,
                  isDone: task.isDone,
                  onEdit: onEdit,
                  onDelete: onDelete,
                  onToggleDone: onToggleDone,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskStackedRow extends StatelessWidget {
  const _TaskStackedRow({
    required this.task,
    required this.busy,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleDone,
  });

  final TaskEntity task;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleDone;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: busy ? null : onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusFlag(task: task),
              const SizedBox(height: 10),
              Text(
                task.descricao,
                style: const TextStyle(
                  color: Color(0xFF313131),
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SubUserFlag(nome: task.subUsuarioNome),
              const SizedBox(height: 10),
              _CompactValue(label: 'Urgência', value: task.urgenciaNome),
              const SizedBox(height: 6),
              _CompactValue(
                label: 'Responsável',
                value: task.responsavel?.nome ?? 'Sem responsavel',
              ),
              const SizedBox(height: 6),
              _CompactValue(label: 'Prazo', value: _taskDatesLabel(task)),
              const SizedBox(height: 14),
              _TaskActions(
                busy: busy,
                isDone: task.isDone,
                expanded: true,
                onEdit: onEdit,
                onDelete: onDelete,
                onToggleDone: onToggleDone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResponsavelTableRow extends StatelessWidget {
  const _ResponsavelTableRow({
    required this.responsavel,
    required this.busy,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final TaskResponsavelEntity responsavel;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final email = responsavel.email.trim().isEmpty ? '-' : responsavel.email;
    final celular = responsavel.celular.trim().isEmpty
        ? '-'
        : formatTaskResponsavelPhone(responsavel.celular);
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: busy ? null : onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Expanded(flex: 3, child: _CellText(responsavel.nome)),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: _CellText(email)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _CellText(celular)),
              const SizedBox(width: 16),
              SizedBox(
                width: 188,
                child: _SimpleActions(
                  busy: busy,
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

class _ResponsavelStackedRow extends StatelessWidget {
  const _ResponsavelStackedRow({
    required this.responsavel,
    required this.busy,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final TaskResponsavelEntity responsavel;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final email = responsavel.email.trim().isEmpty ? '-' : responsavel.email;
    final celular = responsavel.celular.trim().isEmpty
        ? '-'
        : formatTaskResponsavelPhone(responsavel.celular);
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: busy ? null : onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                responsavel.nome,
                style: const TextStyle(
                  color: Color(0xFF313131),
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _CompactValue(label: 'Email', value: email),
              const SizedBox(height: 6),
              _CompactValue(label: 'Celular', value: celular),
              const SizedBox(height: 14),
              _SimpleActions(
                busy: busy,
                expanded: true,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusFlag extends StatelessWidget {
  const _StatusFlag({required this.task});

  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    final color = task.isDone
        ? MyColors.colorPrimary
        : task.isOverdue
        ? const Color(0xFFC45C4A)
        : const Color(0xFFD9762B);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: ShapeDecoration(
          color: color.withValues(alpha: 0.22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(64),
          ),
        ),
        child: Text(
          task.statusNome,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TaskActions extends StatelessWidget {
  const _TaskActions({
    required this.busy,
    required this.isDone,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleDone,
    this.expanded = false,
  });

  final bool busy;
  final bool isDone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleDone;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final edit = SizedBox(
      width: expanded ? null : 88,
      height: 38,
      child: OutlinedButton.icon(
        onPressed: busy ? null : onEdit,
        icon: busy
            ? const SizedBox.square(
                dimension: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(LucideIcons.pencil, size: 15),
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
        onPressed: busy ? null : onDelete,
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
    final toggle = SizedBox(
      width: expanded ? null : 46,
      height: 38,
      child: OutlinedButton(
        onPressed: busy ? null : onToggleDone,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: isDone
              ? const Color(0xFF8C8C8C)
              : MyColors.colorPrimary,
          side: BorderSide(
            color: isDone ? const Color(0xFFD0D0D0) : const Color(0xFFBFD4C7),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Icon(isDone ? Icons.undo : Icons.check_circle_outline, size: 18),
      ),
    );

    return Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (expanded) Expanded(child: edit) else edit,
        const SizedBox(width: 8),
        if (expanded) Expanded(child: remove) else remove,
        const SizedBox(width: 8),
        if (expanded) Expanded(child: toggle) else toggle,
      ],
    );
  }
}

class _SimpleActions extends StatelessWidget {
  const _SimpleActions({
    required this.busy,
    required this.onEdit,
    required this.onDelete,
    this.expanded = false,
  });

  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final edit = SizedBox(
      width: expanded ? null : 88,
      height: 38,
      child: OutlinedButton.icon(
        onPressed: busy ? null : onEdit,
        icon: busy
            ? const SizedBox.square(
                dimension: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(LucideIcons.pencil, size: 15),
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
        onPressed: busy ? null : onDelete,
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

class _CellText extends StatelessWidget {
  const _CellText(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 1,
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
          width: 84,
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
        Expanded(child: _CellText(value)),
      ],
    );
  }
}

class _WebStateMessage extends StatelessWidget {
  const _WebStateMessage({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
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
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _TaskFilterWebDialog extends StatefulWidget {
  const _TaskFilterWebDialog({required this.initialFilter});

  final TaskFilterEntity initialFilter;

  @override
  State<_TaskFilterWebDialog> createState() => _TaskFilterWebDialogState();
}

class _TaskFilterWebDialogState extends State<_TaskFilterWebDialog> {
  DateTime? _dataIn;
  DateTime? _dataOut;
  int? _urgencia;
  int? _status;

  @override
  void initState() {
    super.initState();
    _dataIn = widget.initialFilter.dataIn;
    _dataOut = widget.initialFilter.dataOut;
    _urgencia = widget.initialFilter.urgencia;
    _status = widget.initialFilter.status;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate =
        (isStart ? _dataIn : _dataOut) ?? _dataIn ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _dataIn = picked;
        if (_dataOut != null && _dataOut!.isBefore(picked)) {
          _dataOut = picked;
        }
      } else {
        _dataOut = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WebDialogFrame(
      title: 'Filtros',
      width: 520,
      maxHeight: 640,
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  TaskFilterEntity(
                    month: widget.initialFilter.month,
                    dataIn: _dataIn,
                    dataOut: _dataOut,
                    urgencia: _urgencia,
                    status: _status,
                  ),
                );
              },
              text: 'Aplicar',
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, widget.initialFilter.clearAdvanced());
              },
              child: const Text('Limpar filtros'),
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FilterDateField(
              label: 'Data inicial',
              value: _dataIn == null ? 'Selecionar' : formatTaskDate(_dataIn!),
              onTap: () => _pickDate(isStart: true),
            ),
            const SizedBox(height: 12),
            _FilterDateField(
              label: 'Data final',
              value: _dataOut == null
                  ? 'Selecionar'
                  : formatTaskDate(_dataOut!),
              onTap: () => _pickDate(isStart: false),
            ),
            const SizedBox(height: 12),
            AppSelectOverlay<int>(
              value: _urgencia,
              placeholder: 'Urgencia',
              options: const [
                AppSelectOption(value: 1, label: 'Muito urgente'),
                AppSelectOption(value: 2, label: 'Urgente'),
                AppSelectOption(value: 3, label: 'Não tão urgente'),
              ],
              onChanged: (value) => setState(() => _urgencia = value),
            ),
            const SizedBox(height: 12),
            AppSelectOverlay<int>(
              value: _status,
              placeholder: 'Status',
              options: const [
                AppSelectOption(value: 1, label: 'Pendente'),
                AppSelectOption(value: 3, label: 'Concluído'),
              ],
              onChanged: (value) => setState(() => _status = value),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterDateField extends StatelessWidget {
  const _FilterDateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
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
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: value == 'Selecionar'
                          ? const Color(0xFF8C8C8C)
                          : const Color(0xFF313131),
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today_outlined, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskDetailsWebDialog extends StatelessWidget {
  const _TaskDetailsWebDialog({required this.task});

  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    return WebDialogFrame(
      title: 'Detalhes da tarefa',
      width: 640,
      maxHeight: 720,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          _DetailField(label: 'O que fazer', value: task.descricao),
          _DetailField(
            label: 'Responsável',
            value: task.responsavel?.nome ?? '-',
          ),
          _DetailField(label: 'Tipo', value: task.tipo == 2 ? 'Mensal' : 'Datas'),
          _DetailField(label: 'Urgência', value: task.urgenciaNome),
          _DetailField(label: 'Status', value: task.statusNome),
          _DetailField(label: 'Datas', value: _detailDatesLabel(task)),
          _DetailField(
            label: 'Observações',
            value: task.obs.trim().isEmpty ? '-' : task.obs,
          ),
        ],
      ),
    );
  }
}

class _ResponsavelDetailsWebDialog extends StatelessWidget {
  const _ResponsavelDetailsWebDialog({required this.responsavel});

  final TaskResponsavelEntity responsavel;

  @override
  Widget build(BuildContext context) {
    final email = responsavel.email.trim().isEmpty ? '-' : responsavel.email;
    final celular = responsavel.celular.trim().isEmpty
        ? '-'
        : formatTaskResponsavelPhone(responsavel.celular);
    return WebDialogFrame(
      title: 'Detalhes do responsável',
      width: 560,
      maxHeight: 520,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          _DetailField(label: 'Nome', value: responsavel.nome),
          _DetailField(label: 'Email', value: email),
          _DetailField(label: 'Celular', value: celular),
        ],
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({required this.label, required this.value});

  final String label;
  final String value;

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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF313131),
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricStatCard extends StatelessWidget {
  const _MetricStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E4DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 13,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 22,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF5C5C5C),
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExecucaoCard extends StatelessWidget {
  const _ExecucaoCard({required this.charts});

  final TaskChartsEntity charts;

  @override
  Widget build(BuildContext context) {
    final segments = <_DonutSegment>[
      _DonutSegment(
        value: charts.realizadas.percentual,
        color: const Color(0xFF394762),
        label: 'Realizado',
      ),
      _DonutSegment(
        value: charts.programadas.percentual,
        color: const Color(0xFF7E97C2),
        label: 'Planejado',
      ),
      if (charts.atrasadas.percentual > 0)
        _DonutSegment(
          value: charts.atrasadas.percentual,
          color: const Color(0xFFE8744F),
          label: 'Atrasado',
        ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E4DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Execução',
            style: TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: CustomPaint(painter: _DonutPainter(segments: segments)),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              for (final s in segments)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: s.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${s.label} (${_formatPercent(s.value)}%)',
                      style: const TextStyle(
                        color: Color(0xFF5C5C5C),
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RealizadasCard extends StatelessWidget {
  const _RealizadasCard({required this.percentual});

  final double percentual;

  @override
  Widget build(BuildContext context) {
    final clamped = percentual.clamp(0, 100).toDouble();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E4DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tarefas realizadas',
            style: TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: clamped / 100,
              minHeight: 12,
              backgroundColor: const Color(0xFFEBEBEB),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF394762),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_formatPercent(clamped)}%',
              style: const TextStyle(
                color: Color(0xFF5C5C5C),
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  const _RankingCard({required this.items});

  final List<TaskChartsRankingItemEntity> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E4DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ranking de execução por funcionário',
            style: TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.users, size: 28, color: Color(0xFFB7C4BA)),
                  SizedBox(height: 12),
                  Text(
                    'Nenhum funcionario com tarefas realizadas no periodo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF8C8C8C),
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            ...List.generate(items.length, (index) {
              final item = items[index];
              final nome = item.responsavel.nome.trim().isEmpty
                  ? '-'
                  : item.responsavel.nome;
              return Padding(
                padding: EdgeInsets.only(top: index == 0 ? 0 : 8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFF394762),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        nome,
                        style: const TextStyle(
                          color: Color(0xFF313131),
                          fontSize: 13,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${item.quantidadeRealizadas}',
                      style: const TextStyle(
                        color: Color(0xFF5C5C5C),
                        fontSize: 13,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _DonutSegment {
  const _DonutSegment({
    required this.value,
    required this.color,
    required this.label,
  });

  final double value;
  final Color color;
  final String label;
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.segments});

  final List<_DonutSegment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 22.0;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    final background = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFFEBEBEB);
    canvas.drawArc(rect, 0, math.pi * 2, false, background);

    final total = segments.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0) return;

    var startAngle = -math.pi / 2;
    for (final segment in segments) {
      if (segment.value <= 0) continue;
      final sweep = (segment.value / total) * math.pi * 2;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt
        ..color = segment.color;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    if (oldDelegate.segments.length != segments.length) return true;
    for (var i = 0; i < segments.length; i++) {
      final a = oldDelegate.segments[i];
      final b = segments[i];
      if (a.value != b.value || a.color != b.color) return true;
    }
    return false;
  }
}

String _taskDatesLabel(TaskEntity task) {
  final dates = task.datas.isEmpty
      ? ''
      : task.datas
            .map((item) => item.mesAno ?? item.data.split(' ').first)
            .join(', ');
  final prazo = task.dataPrazo?.trim();
  if (prazo != null && prazo.isNotEmpty) {
    return dates.isEmpty ? 'Prazo $prazo' : 'Prazo $prazo · $dates';
  }
  if (dates.isEmpty) {
    return task.tipo == 2 ? 'Mensal' : 'Sem datas';
  }
  return dates;
}

String _detailDatesLabel(TaskEntity task) {
  if (task.datas.isEmpty) return '-';
  return task.datas
      .map((item) => item.mesAno ?? item.data.split(' ').first)
      .join(', ');
}

String _formatPercent(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
}
