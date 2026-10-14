import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/components/app_buttons.dart';
import 'package:costeira/core/components/app_form_field.dart';
import 'package:costeira/features/auth/models/register_draft.dart';
import 'package:costeira/features/auth/presentation/web/auth_web_frame.dart';
import 'package:costeira/features/auth/presentation/web/auth_web_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class RegisterResponsibleWebPage extends StatefulWidget {
  const RegisterResponsibleWebPage({super.key, required this.draft});

  final RegisterDraft draft;

  @override
  State<RegisterResponsibleWebPage> createState() =>
      _RegisterResponsibleWebPageState();
}

class _RegisterResponsibleWebPageState
    extends State<RegisterResponsibleWebPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _whatsAppController = TextEditingController();
  final _cpfController = TextEditingController();
  final _whatsAppMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final _cpfMaskFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _nameController.dispose();
    _whatsAppController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthWebFrame(
      title: 'Cadastrar',
      subtitle: 'Agora informe os dados do responsável.',
      fallbackRoute: AppRoutes.registerCompany,
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '2 de 3',
                style: TextStyle(
                  color: Color(0xFF00823A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            AppFormField(
              label: 'Nome completo',
              hintText: 'Insira seu nome',
              controller: _nameController,
              textInputAction: TextInputAction.next,
              validator: validateRequiredField,
            ),
            const SizedBox(height: 18),
            AppFormField(
              label: 'WhatsApp',
              hintText: '(00) 00000-0000',
              controller: _whatsAppController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: [_whatsAppMaskFormatter],
              validator: _validateWhatsApp,
            ),
            const SizedBox(height: 18),
            AppFormField(
              label: 'CPF',
              hintText: '000.000.000-00',
              controller: _cpfController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [_cpfMaskFormatter],
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await Modular.to.pushNamed(
      AppRoutes.registerCredentials,
      arguments: widget.draft.copyWith(
        nome: _nameController.text.trim(),
        celular: _whatsAppMaskFormatter.getUnmaskedText(),
        documento: _cpfMaskFormatter.getUnmaskedText(),
      ),
    );
  }

  String? _validateCpf(String? value) {
    final cleanValue = cleanDigits(value ?? '');
    if (cleanValue.isEmpty) {
      return 'Campo obrigatório';
    }
    if (cleanValue.length != 11) {
      return 'CPF inválido';
    }
    return null;
  }

  String? _validateWhatsApp(String? value) {
    final cleanValue = cleanDigits(value ?? '');
    if (cleanValue.isEmpty) {
      return 'Campo obrigatório';
    }
    if (cleanValue.length != 11) {
      return 'WhatsApp inválido';
    }
    return null;
  }

  bool get _canSubmit =>
      validateRequiredField(_nameController.text) == null &&
      _validateWhatsApp(_whatsAppController.text) == null &&
      _validateCpf(_cpfController.text) == null;
}
