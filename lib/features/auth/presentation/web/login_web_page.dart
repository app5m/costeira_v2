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
import 'package:costeira/features/auth/presentation/web/auth_web_frame.dart';
import 'package:costeira/features/auth/presentation/web/auth_web_validators.dart';
import 'package:costeira/features/auth/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class LoginWebPage extends StatefulWidget {
  const LoginWebPage({super.key});

  @override
  State<LoginWebPage> createState() => _LoginWebPageState();
}

class _LoginWebPageState extends State<LoginWebPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthRepository _authRepository;
  late final LocationService _locationService;
  bool _obscureText = true;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthWebFrame(
      title: 'Entrar',
      subtitle: 'Preencha os campos abaixo.',
      fallbackRoute: AppRoutes.welcome,
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: Column(
          children: [
            AppFormField(
              label: 'E-mail',
              hintText: 'exemplo@email.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: validateAuthEmail,
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: 'Senha',
              hintText: 'Digite sua senha',
              controller: _passwordController,
              obscureText: _obscureText,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              suffixIcon: AuthPasswordToggle(
                obscured: _obscureText,
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
              validator: validateLoginPassword,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Modular.to.pushNamed(AppRoutes.recoverPassword);
                },
                child: const Text(
                  'Esqueceu sua senha?',
                  style: TextStyle(
                    color: Color(0xFF8C8C8C),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
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

  bool get _canSubmit =>
      validateAuthEmail(_emailController.text) == null &&
      validateLoginPassword(_passwordController.text) == null;

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
      final response = await _authRepository.sendTwoFactor(
        email: email,
        password: _passwordController.text,
        coordinates: coordinates,
      );

      if (!mounted) {
        return;
      }

      if (response.status == '02' &&
          AuthBypass.isPendingApprovalMessage(response.message)) {
        await SessionStorage.saveWebPendingApproval(
          message: response.message,
          email: email,
        );
        if (!mounted) {
          return;
        }
        await Modular.to.pushReplacementNamed(
          AppRoutes.pendingApproval,
          arguments: PendingApprovalRouteData(
            message: response.message,
            email: email,
          ),
        );
        return;
      }

      _showMessage(
        response.message,
        isError:
            !response.isSuccess &&
            !AuthBypass.shouldBypass(response.status, response.message),
      );

      if (!response.isSuccess &&
          !AuthBypass.shouldBypass(response.status, response.message)) {
        return;
      }

      await Modular.to.pushReplacementNamed(
        AppRoutes.validationCode,
        arguments: ValidationCodeRouteData(
          email: email,
          password: _passwordController.text,
          latitude: coordinates.latitude,
          longitude: coordinates.longitude,
          userType: 1,
          pendingUser: await SessionStorage.getPendingUser(email: email),
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

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) {
      return;
    }
    AppSnackBar.show(context: context, message: message, isError: isError);
  }
}
