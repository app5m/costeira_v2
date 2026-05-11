import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';
import 'package:costeira/features/sanitarios/presentation/controllers/list_sanitarios_controller.dart';
import 'package:costeira/features/sanitarios/presentation/controllers/sanitario_form_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AddPlanejamento extends StatefulWidget {
  const AddPlanejamento({super.key, this.sanitario});

  final SanitarioEntity? sanitario;

  @override
  State<AddPlanejamento> createState() => _AddPlanejamentoState();
}

class _AddPlanejamentoState extends State<AddPlanejamento> {
  static const _carrapaticidaManejo = 'aplicação de carrapaticida';

  final _formKey = GlobalKey<FormState>();
  final _obsController = TextEditingController();
  late final ListSanitariosController _listController;
  late final SanitarioFormController _formController;

  String? _tipoManejo;
  String? _tipoCarrapaticida;
  DateTime? _dataPlanejada;
  Set<int> _categoriaIds = {};
  Set<int> _loteIds = {};

  bool get _isEditing => widget.sanitario != null;
  bool get _requiresCarrapaticida => _tipoManejo == _carrapaticidaManejo;

  @override
  void initState() {
    super.initState();
    _listController = Modular.get<ListSanitariosController>();
    _formController = Modular.get<SanitarioFormController>();
    _fillInitialValues();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_listController.result.tiposManejos.isEmpty) {
        _listController.load();
      }
    });
  }

  @override
  void dispose() {
    _obsController.dispose();
    super.dispose();
  }

  void _fillInitialValues() {
    final sanitario = widget.sanitario;
    if (sanitario == null) {
      return;
    }

    _tipoManejo = sanitario.tipoManejo;
    _tipoCarrapaticida = sanitario.tipoCarrapaticida;
    _dataPlanejada = _parseApiDate(sanitario.dataPlanejada);
    _obsController.text = sanitario.obs ?? '';
    _categoriaIds = sanitario.categorias
        .map((item) => item.appAnimaisCategoriasId ?? item.id)
        .where((id) => id > 0)
        .toSet();
    _loteIds = sanitario.lotes
        .map((item) => item.appAnimaisLotesId ?? item.id)
        .where((id) => id > 0)
        .toSet();
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
          _isEditing ? 'Atualizar planejamento' : 'Adicionar planejamento',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([_listController, _formController]),
        builder: (context, _) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SelectField<String>(
                    label: 'Tipo de manejo',
                    value: _tipoManejo,
                    placeholder: 'Selecione',
                    options: _listController.result.tiposManejos
                        .map(
                          (item) => AppSelectOption<String>(
                            value: item.id,
                            label: item.nome,
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      setState(() {
                        _tipoManejo = value;
                        if (!_requiresCarrapaticida) {
                          _tipoCarrapaticida = null;
                        }
                      });
                    },
                    validator: (_) => _tipoManejo == null
                        ? 'Selecione o tipo de manejo.'
                        : null,
                  ),
                  if (_requiresCarrapaticida)
                    _SelectField<String>(
                      label: 'Tipo de carrapaticida',
                      value: _tipoCarrapaticida,
                      placeholder: 'Selecione',
                      options: _carrapaticidaOptions,
                      onChanged: (value) {
                        setState(() => _tipoCarrapaticida = value);
                      },
                      validator: (_) => _tipoCarrapaticida == null
                          ? 'Selecione o tipo de carrapaticida.'
                          : null,
                    ),
                  _DateField(
                    label: 'Data planejada',
                    value: _dataPlanejada == null
                        ? '00/00/0000'
                        : _formatDate(_dataPlanejada!),
                    onTap: _selectDate,
                    validator: (_) {
                      if (_dataPlanejada == null) {
                        return 'Selecione a data planejada.';
                      }
                      if (_isBeforeToday(_dataPlanejada!)) {
                        return 'Selecione hoje ou uma data futura.';
                      }
                      return null;
                    },
                  ),
                  _MultiSelectField(
                    label: 'Categoria',
                    value: _selectedCategoriasText,
                    onTap: () => _selectCategorias(context),
                    validator: (_) => _categoriaIds.isEmpty
                        ? 'Selecione ao menos uma categoria.'
                        : null,
                  ),
                  _MultiSelectField(
                    label: 'Lote envolvido',
                    value: _selectedLotesText,
                    onTap: () => _selectLotes(context),
                    validator: (_) =>
                        _loteIds.isEmpty ? 'Selecione ao menos um lote.' : null,
                  ),
                  _ObsField(controller: _obsController),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.colorPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _formController.isLoading ? null : _submit,
                      child: _formController.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Salvar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<AppSelectOption<String>> get _carrapaticidaOptions {
    final manejo = _listController.result.tiposManejos
        .cast<SanitarioTipoManejoEntity?>()
        .firstWhere(
          (item) => item?.id == _carrapaticidaManejo,
          orElse: () => null,
        );
    return (manejo?.tiposCarrapaticida ?? const [])
        .map(
          (item) => AppSelectOption<String>(
            value: item.id.toString(),
            label: item.nome,
          ),
        )
        .toList(growable: false);
  }

  String get _selectedCategoriasText {
    if (_categoriaIds.isEmpty) {
      return 'Selecione';
    }
    return _listController.result.categorias
        .where((item) => _categoriaIds.contains(item.id))
        .map((item) => item.nome.trim())
        .where((item) => item.isNotEmpty)
        .join(', ');
  }

  String get _selectedLotesText {
    if (_loteIds.isEmpty) {
      return 'Selecione';
    }
    return _listController.result.lotes
        .where((item) => _loteIds.contains(item.id))
        .map((item) => item.nome.trim())
        .where((item) => item.isNotEmpty)
        .join(', ');
  }

  Future<void> _selectDate() async {
    final today = DateTime.now();
    final firstDate = DateTime(today.year, today.month, today.day);
    final selected = await showDatePicker(
      context: context,
      initialDate:
          _dataPlanejada != null && !_dataPlanejada!.isBefore(firstDate)
          ? _dataPlanejada!
          : firstDate,
      firstDate: firstDate,
      lastDate: DateTime(today.year + 10),
    );

    if (selected != null) {
      setState(() => _dataPlanejada = selected);
    }
  }

  Future<void> _selectCategorias(BuildContext context) async {
    final selected = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _MultiSelectSheet<SanitarioCategoriaEntity>(
        title: 'Selecionar categorias',
        items: _listController.result.categorias,
        selectedIds: _categoriaIds,
        idOf: (item) => item.id,
        labelOf: (item) => item.nome.trim(),
      ),
    );

    if (selected != null) {
      setState(() => _categoriaIds = selected);
    }
  }

  Future<void> _selectLotes(BuildContext context) async {
    final selected = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _MultiSelectSheet<SanitarioLoteEntity>(
        title: 'Selecionar lotes',
        items: _listController.result.lotes,
        selectedIds: _loteIds,
        idOf: (item) => item.id,
        labelOf: (item) => item.nome.trim(),
      ),
    );

    if (selected != null) {
      setState(() => _loteIds = selected);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      final result = await _formController.submit(
        SanitarioUpsertEntity(
          id: widget.sanitario?.id,
          tipoManejo: _tipoManejo!,
          tipoCarrapaticida: _requiresCarrapaticida ? _tipoCarrapaticida : null,
          dataPlanejada: _formatDate(_dataPlanejada!),
          obs: _obsController.text.trim().isEmpty
              ? null
              : _obsController.text.trim(),
          categorias: _categoriaIds.toList(growable: false),
          lotes: _loteIds.toList(growable: false),
        ),
      );

      if (!mounted) {
        return;
      }
      AppSnackBar.show(
        context: context,
        message: result?.message ?? 'Planejamento salvo com sucesso.',
        isError: false,
      );
      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      AppSnackBar.show(context: context, message: error.message);
    }
  }

  DateTime? _parseApiDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final date = value.split(' ').first;
    final parts = date.split('/');
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
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  bool _isBeforeToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.isBefore(today);
  }
}

class _SelectField<T> extends StatelessWidget {
  const _SelectField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.validator,
    this.placeholder = 'Selecione',
  });

  final String label;
  final T? value;
  final List<AppSelectOption<T>> options;
  final ValueChanged<T?> onChanged;
  final String? Function(String?) validator;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: FormField<String>(
        validator: validator,
        builder: (field) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Label(label),
            const SizedBox(height: 6),
            AppSelectOverlay<T>(
              value: value,
              options: options,
              placeholder: placeholder,
              onChanged: (value) {
                onChanged(value);
                field.didChange(value?.toString());
              },
            ),
            if (field.hasError) _ErrorText(field.errorText!),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.validator,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return _TappableFormField(
      label: label,
      value: value,
      placeholder: '00/00/0000',
      icon: Icons.calendar_today_outlined,
      onTap: onTap,
      validator: validator,
    );
  }
}

class _MultiSelectField extends StatelessWidget {
  const _MultiSelectField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.validator,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return _TappableFormField(
      label: label,
      value: value,
      placeholder: 'Selecione',
      icon: Icons.keyboard_arrow_right,
      onTap: onTap,
      validator: validator,
    );
  }
}

class _TappableFormField extends StatelessWidget {
  const _TappableFormField({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.icon,
    required this.onTap,
    required this.validator,
  });

  final String label;
  final String value;
  final String placeholder;
  final IconData icon;
  final VoidCallback onTap;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: FormField<String>(
        validator: validator,
        builder: (field) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Label(label),
            const SizedBox(height: 6),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                onTap();
                field.didChange(value);
              },
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBEBEB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: value == placeholder
                              ? const Color(0xFF8C8C8C)
                              : const Color(0xFF313131),
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Icon(icon, color: const Color(0xFF8C8C8C), size: 20),
                  ],
                ),
              ),
            ),
            if (field.hasError) _ErrorText(field.errorText!),
          ],
        ),
      ),
    );
  }
}

class _ObsField extends StatelessWidget {
  const _ObsField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label('Observações'),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            minLines: 3,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ex: Planejamento inicial',
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
    );
  }
}

class _MultiSelectSheet<T> extends StatefulWidget {
  const _MultiSelectSheet({
    required this.title,
    required this.items,
    required this.selectedIds,
    required this.idOf,
    required this.labelOf,
  });

  final String title;
  final List<T> items;
  final Set<int> selectedIds;
  final int Function(T item) idOf;
  final String Function(T item) labelOf;

  @override
  State<_MultiSelectSheet<T>> createState() => _MultiSelectSheetState<T>();
}

class _MultiSelectSheetState<T> extends State<_MultiSelectSheet<T>> {
  late Set<int> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = {...widget.selectedIds};
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          24 + MediaQuery.of(context).viewInsets.bottom,
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
            Text(
              widget.title,
              style: const TextStyle(
                color: Color(0xFF313131),
                fontSize: 20,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: widget.items.isEmpty
                  ? const Center(child: Text('Nenhum item encontrado.'))
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: widget.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        final id = widget.idOf(item);
                        final isSelected = _selectedIds.contains(id);

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              isSelected
                                  ? _selectedIds.remove(id)
                                  : _selectedIds.add(id);
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
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFEBEBEB),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.labelOf(item),
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
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _selectedIds),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.colorPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Confirmar',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF313131),
        fontSize: 14,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.1,
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }
}
