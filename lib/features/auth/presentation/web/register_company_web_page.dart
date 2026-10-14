import 'package:br_validators/validators/br_validators.dart';
import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_buttons.dart';
import 'package:costeira/core/components/app_form_field.dart';
import 'package:costeira/features/auth/models/register_draft.dart';
import 'package:costeira/features/auth/presentation/web/auth_web_frame.dart';
import 'package:costeira/features/auth/presentation/web/auth_web_validators.dart';
import 'package:costeira/features/auth/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class RegisterCompanyWebPage extends StatefulWidget {
  const RegisterCompanyWebPage({super.key});

  @override
  State<RegisterCompanyWebPage> createState() => _RegisterCompanyWebPageState();
}

class _RegisterCompanyWebPageState extends State<RegisterCompanyWebPage> {
  final _formKey = GlobalKey<FormState>();
  final _cnpjController = TextEditingController();
  final _nomeFantasiaController = TextEditingController();
  final _razaoSocialController = TextEditingController();
  final _inscricaoEstadualController = TextEditingController();
  final _cnpjMaskFormatter = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {'#': RegExp(r'\d')},
  );
  late final AuthRepository _authRepository;
  bool _isLookingUpCnpj = false;
  bool _isCnpjApproved = false;
  String? _cnpjMessage;
  bool _cnpjMessageIsError = false;
  String _lastLookedUpCnpj = '';
  int _cnpjLookupRequestId = 0;

  @override
  void initState() {
    super.initState();
    _authRepository = Modular.get<AuthRepository>();
  }

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
    return AuthWebFrame(
      title: 'Cadastrar',
      subtitle: 'Informe os dados da empresa para iniciar o cadastro.',
      fallbackRoute: AppRoutes.welcome,
      contentMaxWidth: 680,
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '1 de 3',
                style: TextStyle(
                  color: Color(0xFF00823A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) =>
                  _buildCompanyFields(constraints.maxWidth),
            ),
          ],
        ),
      ),
      footer: PrimaryButton(
        label: 'Avançar',
        isLoading: _isLookingUpCnpj,
        onPressed: _canSubmit ? _submit : null,
      ),
    );
  }

  Widget _buildCompanyFields(double availableWidth) {
    final useColumns = availableWidth >= 600;
    final fieldWidth = useColumns ? (availableWidth - 18) / 2 : availableWidth;

    return Wrap(
      spacing: 18,
      runSpacing: 18,
      children: [
        SizedBox(
          width: fieldWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppFormField(
                label: 'CNPJ',
                hintText: '00.000.000/0000-00',
                controller: _cnpjController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [_cnpjMaskFormatter],
                validator: _validateCnpj,
                onChanged: _handleCnpjChanged,
                suffixIcon: _isLookingUpCnpj
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _isCnpjApproved
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
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
          ),
        ),
        SizedBox(
          width: fieldWidth,
          child: AppFormField(
            label: 'Nome fantasia',
            hintText: 'Nome fantasia',
            controller: _nomeFantasiaController,
            textInputAction: TextInputAction.next,
            validator: _requiredField,
          ),
        ),
        SizedBox(
          width: fieldWidth,
          child: AppFormField(
            label: 'Razão social',
            hintText: 'Razão social',
            controller: _razaoSocialController,
            textInputAction: TextInputAction.next,
            validator: _requiredField,
          ),
        ),
        SizedBox(
          width: fieldWidth,
          child: AppFormField(
            label: 'Inscrição estadual',
            hintText: '000.000.000',
            controller: _inscricaoEstadualController,
            textInputAction: TextInputAction.done,
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final draft = RegisterDraft(
      cnpj: cleanDigits(_cnpjController.text),
      nomeFantasia: _nomeFantasiaController.text.trim(),
      razaoSocial: _razaoSocialController.text.trim(),
      ie: _inscricaoEstadualController.text.trim(),
    );

    await Modular.to.pushNamed(AppRoutes.registerResponsible, arguments: draft);
  }

  String? _requiredField(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Campo obrigatorio';
    }
    return null;
  }

  String? _validateCnpj(String? value) {
    final cleanValue = cleanDigits(value ?? '');
    if (cleanValue.isEmpty) {
      return 'Campo obrigatorio';
    }
    if (cleanValue.length < 14) {
      return null;
    }
    if (!BRValidators.validateCNPJ(cleanValue)) {
      return 'CNPJ invalido';
    }
    return null;
  }

  void _handleCnpjChanged(String value) {
    final cleanValue = cleanDigits(value);

    if (cleanValue.length < 14) {
      setState(() {
        _isCnpjApproved = false;
        _isLookingUpCnpj = false;
        _cnpjMessage = null;
        _cnpjMessageIsError = false;
        _lastLookedUpCnpj = '';
      });
      return;
    }

    if (!BRValidators.validateCNPJ(cleanValue)) {
      setState(() {
        _isCnpjApproved = false;
        _isLookingUpCnpj = false;
        _cnpjMessage = 'CNPJ invalido.';
        _cnpjMessageIsError = true;
        _lastLookedUpCnpj = cleanValue;
      });
      return;
    }

    if (_lastLookedUpCnpj != cleanValue) {
      _lookupCnpjData(cleanValue);
    }
  }

  Future<void> _lookupCnpjData(String cleanValue) async {
    final requestId = ++_cnpjLookupRequestId;

    setState(() {
      _isLookingUpCnpj = true;
      _isCnpjApproved = false;
      _cnpjMessage = null;
      _cnpjMessageIsError = false;
    });

    try {
      final result = await _authRepository.lookupCnpj(
        _cnpjController.text.trim(),
      );
      if (!mounted || requestId != _cnpjLookupRequestId) {
        return;
      }

      if (result.nomeFantasia.isNotEmpty) {
        _nomeFantasiaController.text = result.nomeFantasia;
      }
      if (result.razaoSocial.isNotEmpty) {
        _razaoSocialController.text = result.razaoSocial;
      }
      if (result.inscricaoEstadual.isNotEmpty) {
        _inscricaoEstadualController.text = result.inscricaoEstadual;
      }

      setState(() {
        _lastLookedUpCnpj = cleanValue;
        _isLookingUpCnpj = false;
        _isCnpjApproved = true;
        _cnpjMessage = result.situacaoCadastral.isEmpty
            ? 'CNPJ validado com sucesso.'
            : 'CNPJ ${result.situacaoCadastral}.';
        _cnpjMessageIsError = false;
      });
    } on ApiException catch (error) {
      if (!mounted || requestId != _cnpjLookupRequestId) {
        return;
      }

      setState(() {
        _lastLookedUpCnpj = cleanValue;
        _isLookingUpCnpj = false;
        _isCnpjApproved = false;
        _cnpjMessage = error.message;
        _cnpjMessageIsError = true;
      });
    }
  }

  bool get _canSubmit =>
      _validateCnpj(_cnpjController.text) == null &&
      cleanDigits(_cnpjController.text).length == 14 &&
      _isCnpjApproved &&
      _requiredField(_nomeFantasiaController.text) == null &&
      _requiredField(_razaoSocialController.text) == null;
}
