import 'package:costeira/core/components/app_form_field.dart';
import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/services/places_service.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_kind.dart';
import 'package:costeira/features/cadastros/presentation/page_controllers/parceiro_form_page_controller.dart';
import 'package:costeira/features/cadastros/presentation/widgets/address_autocomplete_field.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ParceiroFormWebDialog extends StatefulWidget {
  const ParceiroFormWebDialog({
    super.key,
    required this.kind,
    required this.appFazendasId,
    this.parceiro,
  });

  final ParceiroKind kind;
  final int appFazendasId;
  final ParceiroEntity? parceiro;

  @override
  State<ParceiroFormWebDialog> createState() => _ParceiroFormWebDialogState();
}

class _ParceiroFormWebDialogState extends State<ParceiroFormWebDialog> {
  late final ParceiroFormPageController _controller;
  late final PlacesService _placesService;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<ParceiroFormPageController>();
    _placesService = Modular.get<PlacesService>();
    _controller.addListener(_refresh);
    _controller.init(
      kind: widget.kind,
      appFazendasId: widget.appFazendasId,
      parceiro: widget.parceiro,
    );
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
    final narrow = MediaQuery.sizeOf(context).width < 620;
    final action = _controller.isEditing ? 'Editar' : 'Adicionar';
    final subject = _controller.kind.singular.toLowerCase();

    return WebDialogFrame(
      title: '$action $subject',
      width: 700,
      maxHeight: 760,
      bodyPadding: EdgeInsets.fromLTRB(
        narrow ? 16 : 28,
        22,
        narrow ? 24 : 40,
        8,
      ),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_submitError != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                narrow ? 16 : 28,
                12,
                narrow ? 16 : 28,
                0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _submitError!,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFC4473A),
                  ),
                ),
              ),
            ),
          _footer(narrow),
        ],
      ),
      child: _form(),
    );
  }

  Widget _form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Tipo de pessoa'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ChoiceButton(
                label: 'Pessoa física',
                selected: _controller.isPessoaFisica,
                onTap: () =>
                    _controller.setTipoPessoa(WSConstantes.tipoPessoaFisica),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ChoiceButton(
                label: 'Pessoa jurídica',
                selected: !_controller.isPessoaFisica,
                onTap: () =>
                    _controller.setTipoPessoa(WSConstantes.tipoPessoaJuridica),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        AppFormField(
          label: 'Nome completo',
          hintText: 'Nome',
          controller: _controller.nomeController,
        ),
        const SizedBox(height: 16),
        AppFormField(
          label: 'E-mail',
          hintText: 'email@exemplo.com',
          keyboardType: TextInputType.emailAddress,
          controller: _controller.emailController,
        ),
        const SizedBox(height: 16),
        AppFormField(
          label: 'Celular',
          hintText: '(00) 00000-0000',
          keyboardType: TextInputType.phone,
          controller: _controller.celularController,
          inputFormatters: [_controller.phoneMaskFormatter],
        ),
        const SizedBox(height: 16),
        if (_controller.isPessoaFisica)
          AppFormField(
            label: 'CPF',
            hintText: '000.000.000-00',
            keyboardType: TextInputType.number,
            controller: _controller.cpfController,
            inputFormatters: [_controller.cpfMaskFormatter],
          )
        else ...[
          AppFormField(
            label: 'CNPJ',
            hintText: '00.000.000/0000-00',
            keyboardType: TextInputType.number,
            controller: _controller.cnpjController,
            inputFormatters: [_controller.cnpjMaskFormatter],
            onChanged: _controller.onCnpjChanged,
            suffixIcon: _controller.isLookingUpCnpj
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _controller.isCnpjApproved
                ? const Icon(Icons.check_circle, color: MyColors.colorPrimary)
                : null,
          ),
          if (_controller.cnpjMessage != null) ...[
            const SizedBox(height: 6),
            Text(
              _controller.cnpjMessage!,
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: _controller.cnpjMessageIsError
                    ? const Color(0xFFC4473A)
                    : _controller.isLookingUpCnpj
                    ? const Color(0xFF6B6B6B)
                    : _controller.isCnpjApproved
                    ? MyColors.colorPrimary
                    : const Color(0xFF8B6508),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 16),
          AppFormField(
            label: 'Nome fantasia',
            hintText: 'Nome fantasia',
            controller: _controller.nomeFantasiaController,
          ),
          const SizedBox(height: 16),
          AppFormField(
            label: 'Razão social',
            hintText: 'Razão social',
            controller: _controller.razaoSocialController,
          ),
        ],
        const SizedBox(height: 16),
        AddressAutocompleteField(
          controller: _controller.enderecoController,
          placesService: _placesService,
        ),
        const SizedBox(height: 16),
        AppFormField(
          label: 'Número',
          hintText: '100',
          controller: _controller.numeroController,
        ),
        const SizedBox(height: 16),
        AppFormField(
          label: 'Complemento',
          hintText: 'Casa, sala...',
          controller: _controller.complementoController,
        ),
      ],
    );
  }

  Widget _footer(bool narrow) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        narrow ? 16 : 20,
        12,
        narrow ? 16 : 20,
        16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _controller.isLoading
                ? null
                : () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _controller.isLoading || !_controller.isFormValid
                ? null
                : _submit,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              minimumSize: const Size(120, 44),
              backgroundColor: MyColors.colorPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(_controller.isLoading ? 'Salvando...' : 'Salvar'),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF313131),
        fontSize: 14,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0x1400823A) : const Color(0xFFF5F4F0),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? MyColors.colorPrimary : const Color(0xFFE7E4DD),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? MyColors.colorPrimary : const Color(0xFF313131),
              fontSize: 13,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
