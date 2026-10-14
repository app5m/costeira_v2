import 'dart:async';

import 'package:costeira/app/app_route_data.dart';
import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_buttons.dart';
import 'package:costeira/core/components/app_form_field.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/services/location_service.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/auth/auth_bypass.dart';
import 'package:costeira/features/auth/models/register_draft.dart';
import 'package:costeira/features/auth/presentation/web/auth_web_frame.dart';
import 'package:costeira/features/auth/presentation/web/auth_web_validators.dart';
import 'package:costeira/features/auth/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class RegisterCredentialsWebPage extends StatefulWidget {
  const RegisterCredentialsWebPage({super.key, required this.draft});

  final RegisterDraft draft;

  @override
  State<RegisterCredentialsWebPage> createState() =>
      _RegisterCredentialsWebPageState();
}

class _RegisterCredentialsWebPageState
    extends State<RegisterCredentialsWebPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final AuthRepository _authRepository;
  late final LocationService _locationService;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authRepository = Modular.get<AuthRepository>();
    _locationService = Modular.get<LocationService>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthWebFrame(
      title: 'Cadastrar',
      subtitle: 'Defina os dados de acesso para concluir o cadastro.',
      fallbackRoute: AppRoutes.registerCompany,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '3 de 3',
                style: TextStyle(
                  color: Color(0xFF00823A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: 'E-mail',
              hintText: 'exemplo@email.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: validateAuthEmail,
              onChanged: _refreshForm,
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: 'Senha',
              hintText: 'Digite a senha',
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: _refreshForm,
              suffixIcon: AuthPasswordToggle(
                obscured: _obscurePassword,
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: validateRegisterPassword,
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: 'Confirmar senha',
              hintText: 'Repita a senha',
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: _refreshForm,
              suffixIcon: AuthPasswordToggle(
                obscured: _obscureConfirmPassword,
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              validator: _validateConfirmPassword,
            ),
          ],
        ),
      ),
      footer: PrimaryButton(
        label: 'Avançar',
        isLoading: _isLoading,
        onPressed: _canSubmit ? _submit : null,
      ),
    );
  }

  void _refreshForm(String _) {
    if (mounted) {
      setState(() {});
    }
  }

  String? _validateConfirmPassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Confirme a senha';
    }
    if (value != _passwordController.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  bool get _canSubmit =>
      validateAuthEmail(_emailController.text) == null &&
      validateRegisterPassword(_passwordController.text) == null &&
      _validateConfirmPassword(_confirmPasswordController.text) == null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });

    try {
      final coordinates = await _locationService
          .getCurrentCoordinates()
          .timeout(const Duration(seconds: 8), onTimeout: () => null);
      if (!mounted) {
        return;
      }
      if (coordinates == null) {
        _showMessage('Permita a localização para continuar.');
        return;
      }

      final email = _emailController.text.trim();
      final registerResponse = await _authRepository.register(
        draft: widget.draft.copyWith(
          email: email,
          password: _passwordController.text,
        ),
        coordinates: coordinates,
      );

      if (!mounted) {
        return;
      }
      if (_isPendingApproval(
        registerResponse.message.status,
        registerResponse.message.message,
      )) {
        await _openPendingApproval(
          message: registerResponse.message.message,
          email: email,
        );
        return;
      }

      _showMessage(
        registerResponse.message.message,
        isError: !registerResponse.message.isSuccess,
      );
      if (!registerResponse.message.isSuccess) {
        return;
      }

      final codeResponse = await _authRepository.sendTwoFactor(
        email: email,
        password: _passwordController.text,
        coordinates: coordinates,
      );

      if (!mounted) {
        return;
      }
      if (_isPendingApproval(codeResponse.status, codeResponse.message)) {
        await _openPendingApproval(message: codeResponse.message, email: email);
        return;
      }

      _showMessage(codeResponse.message, isError: !codeResponse.isSuccess);
      if (!codeResponse.isSuccess || !mounted) {
        return;
      }

      await Modular.to.pushReplacementNamed(
        AppRoutes.validationCode,
        arguments: ValidationCodeRouteData(
          email: email,
          password: _passwordController.text,
          latitude: coordinates.latitude,
          longitude: coordinates.longitude,
          userType: widget.draft.tipoPessoa,
          pendingUser: registerResponse.user,
        ),
      );
    } on ApiException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isPendingApproval(String status, String message) {
    return status == '02' && AuthBypass.isPendingApprovalMessage(message);
  }

  Future<void> _openPendingApproval({
    required String message,
    required String email,
  }) async {
    await SessionStorage.saveWebPendingApproval(message: message, email: email);
    if (!mounted) {
      return;
    }
    Modular.to.navigate(
      AppRoutes.pendingApproval,
      arguments: PendingApprovalRouteData(message: message, email: email),
    );
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) {
      return;
    }
    AppSnackBar.show(context: context, message: message, isError: isError);
  }
}
