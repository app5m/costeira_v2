import 'package:costeira/features/auth/models/register_draft.dart';
import 'package:costeira/views/shared/widgets/app_buttons.dart';
import 'package:costeira/views/shared/widgets/app_form_field.dart';
import 'package:costeira/views/shared/widgets/flow_page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

import 'cadastro_three.dart';

class Cadastrotwo extends StatefulWidget {
  const Cadastrotwo({
    super.key,
    required this.draft,
  });

  final RegisterDraft draft;

  @override
  State<Cadastrotwo> createState() => _CadastrotwoState();
}

class _CadastrotwoState extends State<Cadastrotwo> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _whatsAppController = TextEditingController();
  final _cpfController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _whatsAppController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlowPageScaffold(
      title: 'Cadastrar',
      subtitle: 'Agora informe os dados do responsável.',
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: const Color(0xFFEBEBEB),
                    child: SvgPicture.asset(
                      'icon/user-round.svg',
                      width: 44,
                      height: 44,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFEBEBEB),
                      child: SvgPicture.asset(
                        'icon/edit-rounded.svg',
                        width: 16,
                        height: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            AppFormField(
              label: 'Nome completo',
              hintText: 'Insira seu nome',
              controller: _nameController,
              validator: _requiredField,
            ),
            const SizedBox(height: 18),
            AppFormField(
              label: 'WhatsApp',
              hintText: '(00) 00000-0000',
              controller: _whatsAppController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _requiredField,
            ),
            const SizedBox(height: 18),
            AppFormField(
              label: 'CPF',
              hintText: '000.000.000-00',
              controller: _cpfController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateCpf,
            ),
          ],
        ),
      ),
      footer: PrimaryButton(
        label: 'Avançar',
        onPressed: _canSubmit ? _submit : null,
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Cadastrotree(
          draft: widget.draft.copyWith(
            nome: _nameController.text.trim(),
            celular: _whatsAppController.text.trim(),
            documento: _cpfController.text.trim(),
          ),
        ),
      ),
    );
  }

  String? _requiredField(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  String? _validateCpf(String? value) {
    final cleanValue = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (cleanValue.isEmpty) {
      return 'Campo obrigatório';
    }
    if (cleanValue.length != 11) {
      return 'CPF inválido';
    }
    return null;
  }

  bool get _canSubmit =>
      _requiredField(_nameController.text) == null &&
      _requiredField(_whatsAppController.text) == null &&
      _validateCpf(_cpfController.text) == null;
}
