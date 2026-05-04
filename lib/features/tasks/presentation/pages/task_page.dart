import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/features/tasks/domain/entities/task_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_filter_entity.dart';
import 'package:costeira/features/tasks/presentation/pages/add_tarefa.dart';
import 'package:costeira/features/tasks/presentation/pages/add_task_responsavel.dart';
import 'package:costeira/features/tasks/presentation/pages/detail_task.dart';
import 'package:costeira/features/tasks/presentation/pages/edit_task.dart';
import 'package:costeira/features/tasks/presentation/controllers/list_tasks_controller.dart';
import 'package:costeira/features/tasks/presentation/helpers/task_formatters.dart';
import 'package:costeira/features/tasks/presentation/widgets/task_responsaveis_tab.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'task_graphs.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ListTasksController _tasksController =
      Modular.get<ListTasksController>();
  int index = 0;
  int _responsaveisTabVersion = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tasksController.addListener(_onTasksControllerChanged);
    _loadTasks();
  }

  @override
  void dispose() {
    _tasksController.removeListener(_onTasksControllerChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTasksControllerChanged() {
    if (mounted) {
      setState(() {});
    }
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
    }
  }

  Future<void> _previousMonth() async {
    if (_tasksController.isLoading) {
      return;
    }
    final current = _tasksController.filter.month ?? DateTime.now();
    await _loadTasks(
      filter: _tasksController.filter.copyWith(
        month: DateTime(current.year, current.month - 1),
      ),
    );
  }

  Future<void> _nextMonth() async {
    if (_tasksController.isLoading) {
      return;
    }
    final current = _tasksController.filter.month ?? DateTime.now();
    await _loadTasks(
      filter: _tasksController.filter.copyWith(
        month: DateTime(current.year, current.month + 1),
      ),
    );
  }

  Future<void> _deleteTask(TaskEntity task) async {
    final shouldDelete = await _showDeleteConfirmation();
    if (!shouldDelete) {
      return;
    }

    try {
      final message = await _tasksController.deleteTask(task);
      if (!mounted) {
        return;
      }
      AppSnackBar.show(
        context: context,
        message: message.message,
        isError: false,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      AppSnackBar.show(
        context: context,
        message: error is ApiException
            ? error.message
            : 'Nao foi possivel excluir a tarefa.',
        isError: true,
      );
    }
  }

  Future<void> _setDone(TaskEntity task) async {
    try {
      final message = await _tasksController.setDone(task);
      if (!mounted) {
        return;
      }
      AppSnackBar.show(
        context: context,
        message: message.message,
        isError: false,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      AppSnackBar.show(
        context: context,
        message: error is ApiException
            ? error.message
            : 'Nao foi possivel concluir a tarefa.',
        isError: true,
      );
    }
  }

  Future<void> _openFilters() async {
    if (_tasksController.isLoading) {
      return;
    }
    final result = await showModalBottomSheet<TaskFilterEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _TaskFilterSheet(initialFilter: _tasksController.filter),
    );

    if (result != null) {
      await _loadTasks(filter: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: index == 0 || index == 1
          ? FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.all(Radius.circular(64)),
              ),
              onPressed: () async {
                if (index == 0) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddTask()),
                  );
                  await _loadTasks();
                  return;
                }

                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddTaskResponsavel()),
                );
                setState(() => _responsaveisTabVersion++);
              },
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Tarefas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Lista'),
              Tab(text: 'Responsaveis'),
              Tab(text: 'Graficos'),
            ],
            onTap: (int inde) {
              setState(() {
                index = inde;
              });
            },
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
          if (index == 0) ...[
            _MonthSelector(
              month: _tasksController.filter.month ?? DateTime.now(),
              isLoading: _tasksController.isLoading,
              onPrevious: _previousMonth,
              onNext: _nextMonth,
              onFilter: _openFilters,
            ),
            const SizedBox(height: 16),
            _buildSummary(),
            const SizedBox(height: 16),
            _buildTaskList(),
          ],
          if (index == 1)
            TaskResponsaveisTab(key: ValueKey(_responsaveisTabVersion)),
          if (index == 2) const Expanded(child: TaskGraphs()),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final tasks = _tasksController.tasks;
    final pending = tasks.where((task) => !task.isDone).length;
    final done = tasks.where((task) => task.isDone).length;
    final execution = tasks.isEmpty ? 0 : ((done / tasks.length) * 100).round();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryCard('Tarefas pendentes', pending.toString()),
          _buildSummaryCard('Execucao', '$execution%'),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 40,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [BoxShadow(color: Color(0x0A000000), blurRadius: 24)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
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
          Text(
            value,
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

  Widget _buildTaskList() {
    if (_tasksController.isLoading && _tasksController.tasks.isEmpty) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    final errorMessage = _tasksController.errorMessage;
    if (errorMessage != null && _tasksController.tasks.isEmpty) {
      return Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(errorMessage, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    final tasks = _tasksController.tasks;
    return Expanded(
      child: tasks.isEmpty
          ? const Center(child: Text('Nenhuma tarefa encontrada.'))
          : RefreshIndicator(
              onRefresh: _loadTasks,
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return _buildTaskCard(tasks[index]);
                },
              ),
            ),
    );
  }

  Widget _buildTaskCard(TaskEntity task) {
    final urgencyColor = colorFromHex(task.urgenciaCor);
    final statusColor = task.isDone ? MyColors.colorPrimary : urgencyColor;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailTask(task: task)),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8, left: 20, right: 20),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: const [BoxShadow(color: Color(0x0A000000), blurRadius: 24)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 16,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: ShapeDecoration(
                      color: const Color(0x198C8C8C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(42.67),
                      ),
                    ),
                    child: SvgPicture.asset(
                      'icon/book-check.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF8C8C8C),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        _flag(task.statusNome, statusColor),
                        Text(
                          task.descricao,
                          style: const TextStyle(
                            color: Color(0xFF313131),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          task.urgenciaNome,
                          style: const TextStyle(
                            color: Color(0xFF313131),
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          task.responsavel?.nome ?? 'Sem responsavel',
                          style: const TextStyle(
                            color: Color(0xFF8C8C8C),
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _taskDatesLabel(task),
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
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                GestureDetector(
                  onTap: () => _deleteTask(task),
                  child: SvgPicture.asset('icon/trash.svg'),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditTask(task: task)),
                    );
                    await _loadTasks();
                  },
                  child: SvgPicture.asset('icon/square-pen.svg'),
                ),
                if (!task.isDone) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _setDone(task),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: MyColors.colorPrimary,
                      size: 22,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _flag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: ShapeDecoration(
        color: color.withValues(alpha: 0.22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(64)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _taskDatesLabel(TaskEntity task) {
    if (task.datas.isEmpty) {
      return task.tipo == 2 ? 'Mensal' : 'Sem datas';
    }
    return task.datas
        .map((item) => item.mesAno ?? item.data.split(' ').first)
        .join(', ');
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showModalBottomSheet<bool>(
          backgroundColor: Colors.white,
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 2,
                    color: const Color(0xFFE2E2E2),
                  ),
                  const SizedBox(height: 20),
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
                  const Text(
                    'Excluir tarefa',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tem certeza que deseja excluir essa\ntarefa permanentemente?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF8692A8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    text: 'Excluir',
                    backgroundColor: Colors.white,
                    textColor: Colors.red,
                    borderColor: Colors.red,
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
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
            );
          },
        ) ??
        false;
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.month,
    required this.isLoading,
    required this.onPrevious,
    required this.onNext,
    required this.onFilter,
  });

  final DateTime month;
  final bool isLoading;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
          borderRadius: BorderRadius.circular(8),
        ),
        shadows: const [BoxShadow(color: Color(0x0A000000), blurRadius: 24)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: isLoading ? null : onPrevious,
            child: Icon(
              Icons.arrow_back_rounded,
              color: isLoading ? const Color(0xFFBDBDBD) : null,
            ),
          ),
          Text(
            formatTaskMonth(month),
            style: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              height: 1.50,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: isLoading ? null : onFilter,
                child: Icon(
                  Icons.filter_list,
                  color: isLoading ? const Color(0xFFBDBDBD) : null,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: isLoading ? null : onNext,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: isLoading ? const Color(0xFFBDBDBD) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskFilterSheet extends StatefulWidget {
  const _TaskFilterSheet({required this.initialFilter});

  final TaskFilterEntity initialFilter;

  @override
  State<_TaskFilterSheet> createState() => _TaskFilterSheetState();
}

class _TaskFilterSheetState extends State<_TaskFilterSheet> {
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

    if (picked == null) {
      return;
    }

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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 72,
                height: 4,
                color: const Color(0xFFE2E2E2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Filtros',
              style: TextStyle(
                color: Color(0xFF313131),
                fontSize: 20,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
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
                AppSelectOption(value: 3, label: 'Nao tao urgente'),
              ],
              onChanged: (value) => setState(() => _urgencia = value),
            ),
            const SizedBox(height: 12),
            AppSelectOverlay<int>(
              value: _status,
              placeholder: 'Status',
              options: const [
                AppSelectOption(value: 1, label: 'Programado'),
                AppSelectOption(value: 3, label: 'Realizado'),
              ],
              onChanged: (value) => setState(() => _status = value),
            ),
            const SizedBox(height: 20),
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
