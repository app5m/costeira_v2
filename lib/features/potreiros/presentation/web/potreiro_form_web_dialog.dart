import 'package:costeira/core/components/app_form_field.dart';
import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:costeira/core/input_formatters/fixed_two_decimal_input_formatter.dart';
import 'package:costeira/features/potreiros/presentation/page_controllers/potreiro_add_page_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';

class PotreiroFormWebDialog extends StatefulWidget {
  const PotreiroFormWebDialog({super.key});

  @override
  State<PotreiroFormWebDialog> createState() => _PotreiroFormWebDialogState();
}

class _PotreiroFormWebDialogState extends State<PotreiroFormWebDialog> {
  static const _decimalFormatter = FixedTwoDecimalInputFormatter();

  late final PotreiroAddPageController _controller;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<PotreiroAddPageController>();
    _controller.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_controller.isLoading || !_controller.isFormValid) return;
    setState(() => _submitError = null);
    final result = await _controller.submit();
    if (!mounted) return;
    if (result.isSuccess) {
      Navigator.of(context).pop({'success': true, 'message': result.message});
      return;
    }
    setState(() => _submitError = result.message);
  }

  @override
  Widget build(BuildContext context) {
    return WebDialogFrame(
      title: 'Adicionar potreiro',
      width: 700,
      maxHeight: 760,
      bodyPadding: const EdgeInsets.fromLTRB(28, 22, 28, 8),
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_submitError != null) ...[
              Text(
                _submitError!,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFC4473A),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _controller.isLoading || !_controller.isFormValid
                    ? null
                    : _submit,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: MyColors.colorPrimary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFBFC9C5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _controller.isLoading
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Salvar',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFormField(
            label: 'Nome',
            hintText: 'Nome do potreiro',
            controller: _controller.nomeController,
          ),
          const SizedBox(height: 16),
          AppFormField(
            label: 'Área total',
            hintText: '0.00',
            controller: _controller.areaTotalController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: const <TextInputFormatter>[_decimalFormatter],
          ),
          const SizedBox(height: 16),
          AppFormField(
            label: 'Área utilizável',
            hintText: '0.00',
            controller: _controller.areaUtilController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: const <TextInputFormatter>[_decimalFormatter],
          ),
          const SizedBox(height: 16),
          _SelectField(
            label: 'Status atual do potreiro',
            value: _controller.selectedStatusAtual,
            options: PotreiroAddPageController.statusOptions,
            onChanged: _controller.onStatusAtualChanged,
          ),
          const SizedBox(height: 16),
          AppFormField(
            label: 'Tipo forragem',
            hintText: 'Tipo da forragem presente no potreiro',
            controller: _controller.tipoForragemController,
          ),
          const SizedBox(height: 16),
          _SelectField(
            label: 'Acesso a água',
            value: _controller.selectedAcessoAgua,
            options: PotreiroAddPageController.acessoOptions,
            onChanged: _controller.onAcessoAguaChanged,
          ),
          const SizedBox(height: 16),
          _SelectField(
            label: 'Acesso a sombra',
            value: _controller.selectedAcessoSombra,
            options: PotreiroAddPageController.acessoOptions,
            onChanged: _controller.onAcessoSombraChanged,
          ),
          const SizedBox(height: 16),
          AppFormField(
            label: 'Lotação média',
            hintText: '0.00',
            controller: _controller.lotacaoMediaController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: const <TextInputFormatter>[_decimalFormatter],
          ),
          const SizedBox(height: 16),
          const Text(
            'Observações',
            style: TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _controller.obsController,
            minLines: 3,
            maxLines: 3,
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
            ),
            decoration: InputDecoration(
              hintText: 'Ex: Área com pastagem bem formada...',
              hintStyle: const TextStyle(
                color: Color(0xFF8C8C8C),
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
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

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

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
        AppSelectOverlay<String>(
          value: value,
          options: [
            for (final item in options)
              AppSelectOption(value: item, label: item),
          ],
          onChanged: onChanged,
          placeholder: 'Selecionar',
          fieldColor: const Color(0xFFEBEBEB),
          menuColor: Colors.white,
          border: Border.all(color: Colors.transparent),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
        ),
      ],
    );
  }
}
