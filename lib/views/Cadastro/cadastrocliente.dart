import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/features/auth/repositories/auth_repository.dart';
import 'package:costeira/features/auth/models/register_draft.dart';
import 'package:costeira/views/shared/widgets/app_buttons.dart';
import 'package:costeira/views/shared/widgets/app_form_field.dart';
import 'package:costeira/views/shared/widgets/flow_page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'cadastrotwo.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final _formKey = GlobalKey<FormState>();
  final _cnpjController = TextEditingController();
  final _nomeFantasiaController = TextEditingController();
  final _razaoSocialController = TextEditingController();
  final _inscricaoEstadualController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  final _cnpjMaskFormatter = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {'#': RegExp(r'\d')},
  );
  bool _isValidatingCnpj = false;
  bool _isCnpjApproved = false;
  String? _cnpjMessage;
  bool _cnpjMessageIsError = false;
  String _lastValidatedCnpj = '';
  int _cnpjValidationRequestId = 0;

  @override
  void dispose() {
    _cnpjController.dispose();
    _nomeFantasiaController.dispose();
    _razaoSocialController.dispose();
    _inscricaoEstadualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlowPageScaffold(
      title: 'Cadastrar',
      subtitle: 'Informe os dados da empresa para iniciar o cadastro.',
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: Column(
          children: [
            _buildCnpjField(),
            const SizedBox(height: 16),
            AppFormField(
              label: 'Nome fantasia',
              hintText: 'Nome fantasia',
              controller: _nomeFantasiaController,
              validator: _requiredField,
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: 'Razão social',
              hintText: 'Razão social',
              controller: _razaoSocialController,
              validator: _requiredField,
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: 'Inscrição estadual',
              hintText: '000.000.000',
              controller: _inscricaoEstadualController,
            ),
          ],
        ),
      ),
      footer: PrimaryButton(
        label: 'Avançar',
        isLoading: _isValidatingCnpj,
        onPressed: _canSubmit ? _submit : null,
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Cadastrotwo(
          draft: RegisterDraft(
            cnpj: _cnpjController.text.trim(),
            nomeFantasia: _nomeFantasiaController.text.trim(),
            razaoSocial: _razaoSocialController.text.trim(),
            ie: _inscricaoEstadualController.text.trim(),
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

  String? _validateCnpj(String? value) {
    final cleanValue = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (cleanValue.isEmpty) {
      return 'Campo obrigatório';
    }
    if (cleanValue.length != 14) {
      return 'CNPJ inválido';
    }
    return null;
  }

  Widget _buildCnpjField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CNPJ',
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _cnpjController,
          keyboardType: TextInputType.number,
          inputFormatters: [_cnpjMaskFormatter],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateCnpj,
          onChanged: _handleCnpjChanged,
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: '00.000.000/0000-00',
            hintStyle: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
              letterSpacing: 0.1,
            ),
            suffixIcon: _isValidatingCnpj
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _isCnpjApproved
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      )
                    : null,
          ),
        ),
        if (_cnpjMessage != null) ...[
          const SizedBox(height: 6),
          Text(
            _cnpjMessage!,
            style: TextStyle(
              color: _cnpjMessageIsError ? Colors.red : Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  void _handleCnpjChanged(String value) {
    final cleanValue = value.replaceAll(RegExp(r'\D'), '');

    if (cleanValue.length < 14) {
      setState(() {
        _isCnpjApproved = false;
        _isValidatingCnpj = false;
        _cnpjMessage = null;
        _cnpjMessageIsError = false;
        _lastValidatedCnpj = '';
      });
      return;
    }

    if (cleanValue.length == 14 && _lastValidatedCnpj != cleanValue) {
      _validateCnpjRemotely(value, cleanValue);
    }
  }

  Future<void> _validateCnpjRemotely(String formattedValue, String cleanValue) async {
    final requestId = ++_cnpjValidationRequestId;

    setState(() {
      _isValidatingCnpj = true;
      _isCnpjApproved = false;
      _cnpjMessage = null;
      _cnpjMessageIsError = false;
    });

    try {
      final response = await _authRepository.validateCnpj(formattedValue.trim());
      if (!mounted || requestId != _cnpjValidationRequestId) {
        return;
      }

      setState(() {
        _lastValidatedCnpj = cleanValue;
        _isValidatingCnpj = false;
        _isCnpjApproved = response.isSuccess;
        _cnpjMessage = response.isSuccess ? 'CNPJ validado com sucesso.' : 'CNPJ inválido.';
        _cnpjMessageIsError = !response.isSuccess;
      });
    } on ApiException {
      if (!mounted || requestId != _cnpjValidationRequestId) {
        return;
      }

      setState(() {
        _lastValidatedCnpj = cleanValue;
        _isValidatingCnpj = false;
        _isCnpjApproved = false;
        _cnpjMessage = 'CNPJ inválido.';
        _cnpjMessageIsError = true;
      });
    }
  }

  bool get _canSubmit =>
      _validateCnpj(_cnpjController.text) == null &&
      _isCnpjApproved &&
      _requiredField(_nomeFantasiaController.text) == null &&
      _requiredField(_razaoSocialController.text) == null;
}
