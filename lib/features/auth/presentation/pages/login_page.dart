import 'package:costeira/app/app_route_data.dart';
import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/services/location_service.dart';
import 'package:costeira/features/auth/repositories/auth_repository.dart';
import 'package:costeira/core/components/app_buttons.dart';
import 'package:costeira/core/components/app_form_field.dart';
import 'package:costeira/core/components/flow_page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    return FlowPageScaffold(
      title: 'Entrar',
      subtitle: 'Preencha os campos abaixo.',
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
              autofillHints: const [AutofillHints.email],
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: 'Senha',
              hintText: 'Digite sua senha',
              controller: _passwordController,
              obscureText: _obscureText,
              autofillHints: const [AutofillHints.password],
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                icon: Icon(
                  _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.grey,
                ),
              ),
              validator: _validatePassword,
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });

    try {
      final coordinates = await _locationService.getCurrentCoordinates();
      if (coordinates == null) {
        _showMessage('Permita a localização para continuar.');
        return;
      }

      final response = await _authRepository.sendTwoFactor(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        coordinates: coordinates,
      );

      _showMessage(response.message);

      if (!mounted) {
        return;
      }

      if (response.status == '02') {
        await Modular.to.pushReplacementNamed(
          AppRoutes.pendingApproval,
          arguments: PendingApprovalRouteData(
            message: response.message,
            email: _emailController.text.trim(),
          ),
        );
        return;
      }

      if (!response.isSuccess) {
        return;
      }

      await Modular.to.pushReplacementNamed(
        AppRoutes.validationCode,
        arguments: ValidationCodeRouteData(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          latitude: coordinates.latitude,
          longitude: coordinates.longitude,
          userType: 1,
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

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Informe o e-mail';
    }
    final regex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(email)) {
      return 'E-mail inválido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Informe a senha';
    }
    if ((value ?? '').length < 6) {
      return 'A senha deve ter ao menos 6 caracteres';
    }
    return null;
  }

  bool get _canSubmit =>
      _validateEmail(_emailController.text) == null &&
      _validatePassword(_passwordController.text) == null;

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

typedef Login = LoginPage;
