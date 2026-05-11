import 'package:costeira/app/app_route_data.dart';
import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/services/location_service.dart';
import 'package:costeira/features/auth/models/register_draft.dart';
import 'package:costeira/features/auth/repositories/auth_repository.dart';
import 'package:costeira/core/components/app_buttons.dart';
import 'package:costeira/core/components/app_form_field.dart';
import 'package:costeira/core/components/flow_page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class RegisterCredentialsPage extends StatefulWidget {
  const RegisterCredentialsPage({super.key, required this.draft});

  final RegisterDraft draft;

  @override
  State<RegisterCredentialsPage> createState() =>
      _RegisterCredentialsPageState();
}

class _RegisterCredentialsPageState extends State<RegisterCredentialsPage> {
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
    return FlowPageScaffold(
      title: 'Cadastrar',
      subtitle: 'Defina os dados de acesso para concluir o cadastro.',
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
              hintText: 'Digite a senha',
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.newPassword],
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey,
                ),
              ),
              validator: _validatePassword,
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: 'Confirmar senha',
              hintText: 'Repita a senha',
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              autofillHints: const [AutofillHints.newPassword],
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey,
                ),
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

      final registerResponse = await _authRepository.register(
        draft: widget.draft.copyWith(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
        coordinates: coordinates,
      );

      _showMessage(
        registerResponse.message,
        isError: !registerResponse.isSuccess,
      );
      if (!registerResponse.isSuccess) {
        return;
      }

      final codeResponse = await _authRepository.sendTwoFactor(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        coordinates: coordinates,
      );

      _showMessage(codeResponse.message, isError: !codeResponse.isSuccess);
      if (!codeResponse.isSuccess || !mounted) {
        return;
      }

      await Modular.to.pushReplacementNamed(
        AppRoutes.validationCode,
        arguments: ValidationCodeRouteData(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          latitude: coordinates.latitude,
          longitude: coordinates.longitude,
          userType: widget.draft.tipoPessoa,
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
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Informe a senha';
    }
    if (password.length < 8) {
      return 'A senha deve ter ao menos 8 caracteres';
    }
    return null;
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
      _validateEmail(_emailController.text) == null &&
      _validatePassword(_passwordController.text) == null &&
      _validateConfirmPassword(_confirmPasswordController.text) == null;

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) {
      return;
    }
    AppSnackBar.show(context: context, message: message, isError: isError);
  }
}

typedef Cadastrotree = RegisterCredentialsPage;
