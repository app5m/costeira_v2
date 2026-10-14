import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_buttons.dart';
import 'package:costeira/core/components/app_form_field.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/auth/presentation/web/auth_web_frame.dart';
import 'package:costeira/features/auth/presentation/web/auth_web_validators.dart';
import 'package:costeira/features/auth/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class RecoverPasswordWebPage extends StatefulWidget {
  const RecoverPasswordWebPage({super.key});

  @override
  State<RecoverPasswordWebPage> createState() => _RecoverPasswordWebPageState();
}

class _RecoverPasswordWebPageState extends State<RecoverPasswordWebPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late final AuthRepository _authRepository;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authRepository = Modular.get<AuthRepository>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthWebFrame(
      title: 'Recuperação de senha',
      subtitle: 'Enviaremos um link de redefinição de senha para o seu e-mail.',
      fallbackRoute: AppRoutes.login,
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: AppFormField(
          label: 'E-mail',
          hintText: 'exemplo@email.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          validator: validateAuthEmail,
        ),
      ),
      footer: PrimaryButton(
        label: 'Enviar',
        isLoading: _isLoading,
        onPressed: _canSubmit ? _submit : null,
      ),
    );
  }

  bool get _canSubmit => validateAuthEmail(_emailController.text) == null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authRepository.recoverPassword(
        _emailController.text.trim(),
      );
      _showMessage(response.message, isError: !response.isSuccess);
      if (response.isSuccess && mounted) {
        authWebBack(context, AppRoutes.login);
      }
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
