import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:costeira/features/indicadores/presentation/indicadores_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IndicadoresFilterWebDialog extends StatefulWidget {
  const IndicadoresFilterWebDialog({super.key, required this.controller});

  final IndicadoresController controller;

  @override
  State<IndicadoresFilterWebDialog> createState() =>
      _IndicadoresFilterWebDialogState();
}

class _IndicadoresFilterWebDialogState
    extends State<IndicadoresFilterWebDialog> {
  late TipoPeriodoIndicador _periodo;
  late int? _loteId;
  late int? _categoriaId;
  late int? _piqueteId;
  late final TextEditingController _dias;
  DateTime? _dataDe;
  DateTime? _dataAte;

  IndicadoresController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _periodo = _c.periodo;
    _loteId = _c.loteId;
    _categoriaId = _c.categoriaId;
    _piqueteId = _c.piqueteId;
    _dias = TextEditingController(text: '${_c.ultimosDias}');
    _dataDe = _c.dataDe;
    _dataAte = _c.dataAte;
  }

  @override
  void dispose() {
    _dias.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _loteId != null ||
      _categoriaId != null ||
      _piqueteId != null ||
      _periodo != TipoPeriodoIndicador.anoAgricola;

  bool get _canApply {
    if (_periodo == TipoPeriodoIndicador.ultimosDias) {
      final dias = int.tryParse(_dias.text.trim());
      return dias != null && dias > 0;
    }
    if (_periodo == TipoPeriodoIndicador.personalizado) {
      return _dataDe != null && _dataAte != null;
    }
    return true;
  }

  Future<void> _aplicar() async {
    if (!_canApply) return;
    final dias = int.tryParse(_dias.text.trim()) ?? 30;
    Navigator.of(context).pop(true);
    await _c.aplicarFiltros(
      periodo: _periodo,
      loteId: _loteId,
      categoriaId: _categoriaId,
      piqueteId: _piqueteId,
      ultimosDias: dias,
      dataDe: _dataDe,
      dataAte: _dataAte,
    );
  }

  Future<void> _limpar() async {
    Navigator.of(context).pop(true);
    _c.limparFiltros();
  }

  Future<void> _pickDate({required bool inicio}) async {
    final atual = inicio ? _dataDe : _dataAte;
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: atual ?? DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      if (inicio) {
        _dataDe = picked;
      } else {
        _dataAte = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WebDialogFrame(
      title: 'Filtros',
      width: 560,
      maxHeight: 640,
      bodyPadding: const EdgeInsets.fromLTRB(28, 8, 28, 8),
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _hasActiveFilters ? _limpar : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: MyColors.colorPrimary,
                ),
                child: const Text('Limpar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _canApply ? _aplicar : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  elevation: 0,
                  backgroundColor: MyColors.colorPrimary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Aplicar'),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
            _label('Período'),
            const SizedBox(height: 6),
            AppSelectOverlay<TipoPeriodoIndicador>(
              value: _periodo,
              placeholder: 'Período',
              options: const [
                AppSelectOption(
                  value: TipoPeriodoIndicador.todo,
                  label: 'Todo o período',
                ),
                AppSelectOption(
                  value: TipoPeriodoIndicador.anoAgricola,
                  label: 'Ano agrícola atual',
                ),
                AppSelectOption(
                  value: TipoPeriodoIndicador.ultimosDias,
                  label: 'Últimos X dias',
                ),
                AppSelectOption(
                  value: TipoPeriodoIndicador.personalizado,
                  label: 'Personalizado',
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _periodo = value;
                  if (value == TipoPeriodoIndicador.personalizado) {
                    final hoje = DateTime.now();
                    _dataDe ??= DateTime(hoje.year, hoje.month, 1);
                    _dataAte ??= hoje;
                  }
                });
              },
            ),
            if (_periodo == TipoPeriodoIndicador.ultimosDias) ...[
              const SizedBox(height: 16),
              _label('Quantidade de dias'),
              const SizedBox(height: 6),
              TextField(
                controller: _dias,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                decoration: _fieldDecoration(hint: 'Ex: 30'),
              ),
            ],
            if (_periodo == TipoPeriodoIndicador.personalizado) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Data inicial',
                      value: _dataDe,
                      onTap: () => _pickDate(inicio: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: 'Data final',
                      value: _dataAte,
                      onTap: () => _pickDate(inicio: false),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            _label('Lote'),
            const SizedBox(height: 6),
            AppSelectOverlay<int?>(
              value: _loteId,
              placeholder: 'Todos os lotes',
              options: [
                const AppSelectOption(value: null, label: 'Todos os lotes'),
                for (final lote in _c.lotes)
                  AppSelectOption(value: lote.id, label: lote.nome),
              ],
              onChanged: (value) => setState(() => _loteId = value),
            ),
            const SizedBox(height: 16),
            _label('Categoria'),
            const SizedBox(height: 6),
            AppSelectOverlay<int?>(
              value: _categoriaId,
              placeholder: 'Todas as categorias',
              options: [
                const AppSelectOption(
                  value: null,
                  label: 'Todas as categorias',
                ),
                for (final categoria in _c.categorias)
                  AppSelectOption(value: categoria.id, label: categoria.nome),
              ],
              onChanged: (value) => setState(() => _categoriaId = value),
            ),
            const SizedBox(height: 16),
            _label('Piquete'),
            const SizedBox(height: 6),
            AppSelectOverlay<int?>(
              value: _piqueteId,
              placeholder: 'Todos os piquetes',
              options: [
                const AppSelectOption(
                  value: null,
                  label: 'Todos os piquetes',
                ),
                for (final piquete in _c.piquetes)
                  AppSelectOption(value: piquete.id, label: piquete.nome),
              ],
              onChanged: (value) => setState(() => _piqueteId = value),
            ),
          ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF313131),
      ),
    );
  }

  InputDecoration _fieldDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF4F4F4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE7E4DD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE7E4DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: MyColors.colorPrimary),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final texto = value == null
        ? null
        : IndicadoresController.formatar(value!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE7E4DD)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      texto ?? '00/00/0000',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: texto == null
                            ? const Color(0xFF9A9A9A)
                            : const Color(0xFF313131),
                      ),
                    ),
                  ),
                  const Icon(Icons.calendar_today_outlined, size: 18),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
