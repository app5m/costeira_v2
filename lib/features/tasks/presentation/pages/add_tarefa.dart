import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/features/tasks/domain/entities/task_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_responsavel_entity.dart';
import 'package:costeira/features/tasks/presentation/pages/add_task_responsavel.dart';
import 'package:costeira/features/tasks/presentation/controllers/list_task_responsaveis_controller.dart';
import 'package:costeira/features/tasks/presentation/controllers/save_task_controller.dart';
import 'package:costeira/features/tasks/presentation/helpers/task_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../theme/colors.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key, this.task});

  final TaskEntity? task;

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  static const _taskTypes = [
    AppSelectOption<int>(value: 1, label: 'Datas'),
    AppSelectOption<int>(value: 2, label: 'Mensal'),
  ];
  static const _urgencies = [
    AppSelectOption<int>(value: 1, label: 'Muito urgente'),
    AppSelectOption<int>(value: 2, label: 'Urgente'),
    AppSelectOption<int>(value: 3, label: 'Nao tao urgente'),
  ];
  static const _months = [
    _MonthOption('01', 'Janeiro'),
    _MonthOption('02', 'Fevereiro'),
    _MonthOption('03', 'Marco'),
    _MonthOption('04', 'Abril'),
    _MonthOption('05', 'Maio'),
    _MonthOption('06', 'Junho'),
    _MonthOption('07', 'Julho'),
    _MonthOption('08', 'Agosto'),
    _MonthOption('09', 'Setembro'),
    _MonthOption('10', 'Outubro'),
    _MonthOption('11', 'Novembro'),
    _MonthOption('12', 'Dezembro'),
  ];

  final _descricaoController = TextEditingController();
  final _obsController = TextEditingController();
  final ListTaskResponsaveisController _responsaveisController =
      Modular.get<ListTaskResponsaveisController>();
  final SaveTaskController _saveTaskController =
      Modular.get<SaveTaskController>();

  int? _selectedType;
  int? _selectedUrgency;
  int? _selectedResponsavelId;
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _selectedMonths = [];
  bool _isLoading = false;

  bool get _isEditing => widget.task != null;

  bool get _isFormValid {
    return _selectedType != null &&
        _descricaoController.text.trim().isNotEmpty &&
        _selectedUrgency != null;
  }

  @override
  void initState() {
    super.initState();
    _hydrateFromTask();
    _responsaveisController.addListener(_onResponsaveisChanged);
    _responsaveisController.load().catchError((_) {});
  }

  @override
  void dispose() {
    _responsaveisController.removeListener(_onResponsaveisChanged);
    _descricaoController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  void _onResponsaveisChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _hydrateFromTask() {
    final task = widget.task;
    if (task == null) {
      return;
    }

    _selectedType = task.tipo;
    _selectedUrgency = task.urgenciaId == 0 ? null : task.urgenciaId;
    _selectedResponsavelId = task.responsavelId;
    _descricaoController.text = task.descricao;
    _obsController.text = task.obs;

    if (task.tipo == 2) {
      _selectedMonths = task.datas
          .map((item) {
            final mesAno = item.mesAno ?? item.data;
            final month = _months.firstWhere(
              (option) =>
                  mesAno.toLowerCase().startsWith(option.label.toLowerCase()),
              orElse: () => const _MonthOption('', ''),
            );
            return month.value;
          })
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
    } else if (task.datas.isNotEmpty) {
      _startDate = parseTaskApiDate(task.datas.first.data);
      _endDate = parseTaskApiDate(task.datas.last.data);
    }
  }

  Future<void> _submit() async {
    if (!_isFormValid || _isLoading) {
      return;
    }

    final datas = _buildDatasPayload();
    if ((_selectedType == 1 || _selectedType == 2) && datas.isEmpty) {
      AppSnackBar.show(
        context: context,
        message: _selectedType == 1
            ? 'Informe a data inicial e final.'
            : 'Selecione ao menos um mes.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final message = await _saveTaskController.submit(
        task: widget.task,
        responsavelId: _selectedResponsavelId,
        tipo: _selectedType!,
        descricao: _descricaoController.text.trim(),
        obs: _obsController.text.trim(),
        urgencia: _selectedUrgency!,
        datas: datas,
      );

      if (!mounted) {
        return;
      }

      AppSnackBar.show(
        context: context,
        message: message.message,
        isError: false,
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }
      AppSnackBar.show(
        context: context,
        message: error is ApiException
            ? error.message
            : 'Nao foi possivel salvar a tarefa.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<String> _buildDatasPayload() {
    if (_selectedType == 2) {
      return List<String>.from(_selectedMonths)..sort();
    }
    if (_startDate == null || _endDate == null) {
      return [];
    }
    return [formatTaskDate(_startDate!), formatTaskDate(_endDate!)];
  }

  Future<void> _openResponsavelSelection() async {
    if (_responsaveisController.responsaveis.isEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddTaskResponsavel()),
      );
      await _responsaveisController.load().catchError((_) {});
      if (mounted && _responsaveisController.responsaveis.isNotEmpty) {
        await _openResponsavelSelection();
      }
      return;
    }

    if (!mounted) {
      return;
    }

    final result = await showModalBottomSheet<_ResponsavelSelectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ResponsavelSelectionSheet(
        responsaveis: _responsaveisController.responsaveis,
        initialSelectedId: _selectedResponsavelId,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    if (result.shouldAdd) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddTaskResponsavel()),
      );
      await _responsaveisController.load().catchError((_) {});
      if (mounted && _responsaveisController.responsaveis.isNotEmpty) {
        await _openResponsavelSelection();
      }
      return;
    }

    setState(() => _selectedResponsavelId = result.selectedId);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate =
        (isStart ? _startDate : _endDate) ?? _startDate ?? DateTime.now();
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
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _openMonthSelection() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MonthSelectionSheet(selectedMonths: _selectedMonths),
    );

    if (result != null) {
      setState(() => _selectedMonths = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          _isEditing ? 'Editar tarefa' : 'Adicionar tarefa',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _descricaoController,
              label: 'O que fazer',
              hint: 'Descricao da tarefa',
            ),
            _buildSelectField(
              label: 'Responsavel',
              value: _selectedResponsavelName,
              placeholder: 'Selecionar responsavel',
              onTap: _openResponsavelSelection,
            ),
            _buildDropdown(
              label: 'Tipo',
              value: _selectedType,
              options: _taskTypes,
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                  _startDate = null;
                  _endDate = null;
                  _selectedMonths = [];
                });
              },
            ),
            if (_selectedType == 1) ...[
              _buildDateField(
                label: 'Data inicial',
                value: _startDate == null
                    ? 'Selecionar data'
                    : formatTaskDate(_startDate!),
                onTap: () => _pickDate(isStart: true),
              ),
              _buildDateField(
                label: 'Data final',
                value: _endDate == null
                    ? 'Selecionar data'
                    : formatTaskDate(_endDate!),
                onTap: () => _pickDate(isStart: false),
              ),
            ],
            if (_selectedType == 2)
              _buildSelectField(
                label: 'Meses',
                value: _selectedMonthsLabel,
                placeholder: 'Selecionar meses',
                onTap: _openMonthSelection,
              ),
            _buildDropdown(
              label: 'Urgencia',
              value: _selectedUrgency,
              options: _urgencies,
              onChanged: (value) => setState(() => _selectedUrgency = value),
            ),
            _buildTextField(
              controller: _obsController,
              label: 'Observacoes',
              hint: 'Observacoes da tarefa',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            CustomButton(
              onPressed: _submit,
              text: _isEditing ? 'Salvar' : 'Adicionar',
              enabled: _isFormValid,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String get _selectedResponsavelName {
    final responsavel = _responsaveisController.responsaveis
        .where((item) => item.id == _selectedResponsavelId)
        .firstOrNull;
    return responsavel?.nome ?? '';
  }

  String get _selectedMonthsLabel {
    if (_selectedMonths.isEmpty) {
      return '';
    }
    return _months
        .where((month) => _selectedMonths.contains(month.value))
        .map((month) => month.label)
        .join(', ');
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
            letterSpacing: 0.10,
          ),
          decoration: _inputDecoration(hint),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required int? value,
    required List<AppSelectOption<int>> options,
    required void Function(int? value) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        AppSelectOverlay<int>(
          value: value,
          placeholder: 'Selecione',
          options: options,
          onChanged: onChanged,
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildSelectField({
    required String label,
    required String value,
    required String placeholder,
    required Future<void> Function() onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty ? placeholder : value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: value.isEmpty
                          ? const Color(0xFF8C8C8C)
                          : const Color(0xFF313131),
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_right,
                  color: Color(0xFF8C8C8C),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return _buildSelectField(
      label: label,
      value: value.startsWith('Selecionar') ? '' : value,
      placeholder: value,
      onTap: () async => onTap(),
    );
  }

  Text _label(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF313131),
        fontSize: 14,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w400,
        height: 1.50,
        letterSpacing: 0.10,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF8C8C8C),
        fontSize: 14,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w400,
        height: 1.50,
        letterSpacing: 0.10,
      ),
      filled: true,
      fillColor: const Color(0xFFEBEBEB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _ResponsavelSelectionResult {
  const _ResponsavelSelectionResult({this.selectedId, this.shouldAdd = false});

  final int? selectedId;
  final bool shouldAdd;
}

class _ResponsavelSelectionSheet extends StatefulWidget {
  const _ResponsavelSelectionSheet({
    required this.responsaveis,
    required this.initialSelectedId,
  });

  final List<TaskResponsavelEntity> responsaveis;
  final int? initialSelectedId;

  @override
  State<_ResponsavelSelectionSheet> createState() =>
      _ResponsavelSelectionSheetState();
}

class _ResponsavelSelectionSheetState
    extends State<_ResponsavelSelectionSheet> {
  late int? _selectedId = widget.initialSelectedId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 72,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E2E2),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Selecionar responsavel',
              style: TextStyle(
                color: Color(0xFF313131),
                fontSize: 20,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.responsaveis.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final responsavel = widget.responsaveis[index];
                  final isSelected = _selectedId == responsavel.id;
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      setState(() {
                        _selectedId = isSelected ? null : responsavel.id;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? MyColors.colorPrimary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEBEBEB)),
                        boxShadow: const [
                          BoxShadow(color: Color(0x0A000000), blurRadius: 24),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              responsavel.nome,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF313131),
                                fontSize: 14,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF8C8C8C),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(
                    context,
                    const _ResponsavelSelectionResult(shouldAdd: true),
                  );
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Adicionar responsavel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: MyColors.colorPrimary,
                  side: const BorderSide(color: MyColors.colorPrimary),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CustomButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  _ResponsavelSelectionResult(selectedId: _selectedId),
                );
              },
              text: 'Confirmar',
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthSelectionSheet extends StatefulWidget {
  const _MonthSelectionSheet({required this.selectedMonths});

  final List<String> selectedMonths;

  @override
  State<_MonthSelectionSheet> createState() => _MonthSelectionSheetState();
}

class _MonthSelectionSheetState extends State<_MonthSelectionSheet> {
  late final Set<String> _selected = Set<String>.from(widget.selectedMonths);

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
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E2E2),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Selecionar meses',
              style: TextStyle(
                color: Color(0xFF313131),
                fontSize: 20,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _AddTaskState._months.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final month = _AddTaskState._months[index];
                  final isSelected = _selected.contains(month.value);
                  return CheckboxListTile(
                    value: isSelected,
                    title: Text(month.label),
                    controlAffinity: ListTileControlAffinity.trailing,
                    onChanged: (_) {
                      setState(() {
                        isSelected
                            ? _selected.remove(month.value)
                            : _selected.add(month.value);
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            CustomButton(
              onPressed: () {
                Navigator.pop(context, _selected.toList(growable: false));
              },
              text: 'Confirmar',
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthOption {
  const _MonthOption(this.value, this.label);

  final String value;
  final String label;
}
