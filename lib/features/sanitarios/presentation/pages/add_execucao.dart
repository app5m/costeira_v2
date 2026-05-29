import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';
import 'package:costeira/features/sanitarios/presentation/controllers/executar_sanitario_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AddExecucaoSanitario extends StatefulWidget {
  const AddExecucaoSanitario({super.key, required this.sanitario});

  final SanitarioEntity sanitario;

  @override
  State<AddExecucaoSanitario> createState() => _AddExecucaoSanitarioState();
}

class _AddExecucaoSanitarioState extends State<AddExecucaoSanitario> {
  late final ExecutarSanitarioController _controller;
  DateTime? _dataExecucao;

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<ExecutarSanitarioController>()
      ..addListener(_sync);
    _dataExecucao = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.init());
  }

  @override
  void dispose() {
    _controller.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    if (mounted) setState(() {});
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
        title: const Text(
          'Executar sanitário',
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
        child: _controller.isLoading && _controller.insumos.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(sanitario: widget.sanitario),
                    const SizedBox(height: 18),
                    _DateField(
                      value: _dataExecucao == null
                          ? '00/00/0000'
                          : _formatDate(_dataExecucao!),
                      onTap: _selectDate,
                    ),
                    _DropdownField<int>(
                      label: 'Insumo utilizado',
                      value: _controller.selectedInsumoId,
                      placeholder: _controller.insumos.isEmpty
                          ? 'Nenhum medicamento encontrado'
                          : 'Selecione',
                      options: _controller.insumos
                          .map(
                            (item) => AppSelectOption<int>(
                              value: item.id,
                              label: _controller.insumoLabel(item),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: _controller.onInsumoChanged,
                    ),
                    _QuantityField(
                      controller: _controller.quantidadeController,
                      unidade: _controller.unidadeSelecionada,
                      enabled: _controller.selectedInsumoId != null,
                      maxLabel: _controller.selectedInsumoId == null
                          ? null
                          : _controller.quantidadeMaximaLabel,
                      onMinus: _controller.decrementQuantidade,
                      onPlus: _controller.incrementQuantidade,
                    ),
                    SizedBox(
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: _controller.canAddItem ? _addItem : null,
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar insumo'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: MyColors.colorPrimary,
                          side: BorderSide(color: MyColors.colorPrimary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    if (_controller.errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _controller.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 20),
                    const _SectionTitle('Insumos da execução'),
                    const SizedBox(height: 10),
                    if (_controller.itens.isEmpty)
                      const _EmptyCart()
                    else
                      ..._controller.itens.map(
                        (item) => _CartItem(
                          name: item.insumo.nome,
                          quantity: _controller.itemQuantityLabel(item),
                          onRemove: () =>
                              _controller.removeItem(item.insumo.id),
                        ),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _controller.canSubmit ? _submit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.colorPrimary,
                          disabledBackgroundColor: const Color(0xFFBDBDBD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _controller.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Executar',
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
      ),
    );
  }

  void _addItem() {
    final added = _controller.addItem();
    if (!added || !mounted) return;
    AppSnackBar.show(
      context: context,
      message: 'Insumo adicionado na execução.',
      isError: false,
    );
  }

  Future<void> _submit() async {
    if (_dataExecucao == null) {
      AppSnackBar.show(
        context: context,
        message: 'Selecione a data de execução.',
      );
      return;
    }

    try {
      final result = await _controller.submit(
        sanitarioId: widget.sanitario.id,
        dataExecucao: _formatDate(_dataExecucao!),
      );
      if (!mounted || result == null) return;
      AppSnackBar.show(
        context: context,
        message: result.message,
        isError: false,
      );
      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context: context, message: error.message);
    }
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dataExecucao ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      setState(() => _dataExecucao = selected);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.sanitario});

  final SanitarioEntity sanitario;

  @override
  Widget build(BuildContext context) {
    final lotes = sanitario.lotes
        .map((item) => item.nome.trim())
        .where((item) => item.isNotEmpty)
        .join(', ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sanitario.tipoManejo,
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            lotes.isEmpty ? 'Sem lote vinculado' : lotes,
            style: const TextStyle(
              color: Color(0xFF8C8C8C),
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

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.placeholder = 'Selecione',
  });

  final String label;
  final T? value;
  final List<AppSelectOption<T>> options;
  final ValueChanged<T?> onChanged;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      label: label,
      child: AppSelectOverlay<T>(
        value: options.any((item) => item.value == value) ? value : null,
        placeholder: placeholder,
        options: options,
        enabled: options.isNotEmpty,
        onChanged: onChanged,
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      label: 'Data de execução',
      child: InkWell(
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
                  value,
                  style: const TextStyle(
                    color: Color(0xFF313131),
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const Icon(Icons.calendar_today_outlined, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityField extends StatelessWidget {
  const _QuantityField({
    required this.controller,
    required this.unidade,
    required this.enabled,
    this.maxLabel,
    required this.onMinus,
    required this.onPlus,
  });

  final TextEditingController controller;
  final String unidade;
  final bool enabled;
  final String? maxLabel;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      label: 'Quantidade utilizada',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: enabled ? onMinus : null,
                style: IconButton.styleFrom(foregroundColor: Colors.black),
                icon: const Icon(Icons.remove, color: Colors.black),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                  ],
                  decoration: _inputDecoration(
                    enabled ? '0' : 'Selecione um insumo',
                  ).copyWith(suffixText: unidade.isEmpty ? null : unidade),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: enabled ? onPlus : null,
                style: IconButton.styleFrom(foregroundColor: Colors.black),
                icon: const Icon(Icons.add, color: Colors.black),
              ),
            ],
          ),
          if (maxLabel != null) ...[
            const SizedBox(height: 6),
            Text(
              'Máximo disponível: $maxLabel',
              style: const TextStyle(
                color: Color(0xFF8C8C8C),
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  const _CartItem({
    required this.name,
    required this.quantity,
    required this.onRemove,
  });

  final String name;
  final String quantity;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEBEBEB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: _itemTitle),
                const SizedBox(height: 4),
                Text(quantity, style: _itemSubtitle),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }

  TextStyle get _itemTitle => const TextStyle(
    color: Color(0xFF313131),
    fontSize: 13,
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w600,
  );

  TextStyle get _itemSubtitle => const TextStyle(
    color: Color(0xFF8C8C8C),
    fontSize: 12,
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w500,
  );
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEBEBEB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Nenhum insumo adicionado.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF8C8C8C),
          fontSize: 12,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF313131),
        fontSize: 14,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _FieldShell extends StatelessWidget {
  const _FieldShell({required this.label, required this.child});

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

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFEBEBEB),
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  );
}
