import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/auth/repositories/auth_repository.dart';
import 'package:costeira/core/components/app_buttons.dart';
import 'package:costeira/core/components/app_form_field.dart';
import 'package:costeira/core/components/flow_page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class RecoverPasswordPage extends StatefulWidget {
  const RecoverPasswordPage({super.key});

  @override
  State<RecoverPasswordPage> createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends State<RecoverPasswordPage> {
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
    return FlowPageScaffold(
      title: 'Recuperação de senha',
      subtitle: 'Enviaremos um link de redefinição de senha para o seu e-mail.',
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: AppFormField(
          label: 'E-mail',
          hintText: 'exemplo@email.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          validator: (value) {
            final email = value?.trim() ?? '';
            if (email.isEmpty) {
              return 'Informe o e-mail';
            }
            final regex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!regex.hasMatch(email)) {
              return 'E-mail inválido';
            }
            return null;
          },
        ),
      ),
      footer: PrimaryButton(
        label: 'Enviar',
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
      final response = await _authRepository.recoverPassword(
        _emailController.text.trim(),
      );
      _showMessage(response.message, isError: !response.isSuccess);
      if (response.isSuccess && mounted) {
        Modular.to.pop();
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

  bool get _canSubmit {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      return false;
    }
    final regex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }
}
