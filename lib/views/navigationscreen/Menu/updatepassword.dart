import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/account/repositories/account_repository.dart';
import 'package:costeira/features/auth/models/user_session.dart';
import 'package:costeira/theme/colors.dart';
import 'package:costeira/core/components/app_buttons.dart';
import 'package:costeira/core/components/app_form_field.dart';
import 'package:costeira/core/components/primary_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class UpdatePasswordPage extends StatefulWidget {
  const UpdatePasswordPage({super.key});

  @override
  State<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final AccountRepository _accountRepository;

  UserSession? _user;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _accountRepository = Modular.get<AccountRepository>();
    _loadUser();
  }

  Future<void> _loadUser() async {
    _user = await SessionStorage.getUserSession();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasUppercase => _newPasswordController.text.contains(RegExp(r'[A-Z]'));
  bool get _passwordsMatch =>
      _confirmPasswordController.text.isNotEmpty &&
      _newPasswordController.text == _confirmPasswordController.text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PrimarySectionAppBar(context: context, title: 'Alterar senha'),
      body: SafeArea(
        child: Form(
          key: _formKey,
          onChanged: () => setState(() {}),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'Insira sua senha atual e a nova para efetuar a alteração.',
                      style: TextStyle(
                        color: Color(0xFF8C8C8C),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppFormField(
                      label: 'Senha atual',
                      hintText: 'Digite a senha atual',
                      controller: _currentPasswordController,
                      obscureText: !_showCurrentPassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _showCurrentPassword = !_showCurrentPassword;
                          });
                        },
                        icon: Icon(
                          _showCurrentPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                      ),
                      validator: _requiredField,
                    ),
                    const SizedBox(height: 16),
                    AppFormField(
                      label: 'Nova senha',
                      hintText: 'Digite a nova senha',
                      controller: _newPasswordController,
                      obscureText: !_showNewPassword,
                      onChanged: (_) => setState(() {}),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _showNewPassword = !_showNewPassword;
                          });
                        },
                        icon: Icon(
                          _showNewPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                      ),
                      validator: _validateNewPassword,
                    ),
                    const SizedBox(height: 12),
                    _PasswordRule(label: 'Deve ter no mínimo 8 caracteres', isValid: _hasMinLength),
                    const SizedBox(height: 8),
                    _PasswordRule(label: 'Deve ter uma letra maiúscula', isValid: _hasUppercase),
                    const SizedBox(height: 16),
                    AppFormField(
                      label: 'Repita a nova senha',
                      hintText: 'Repita a nova senha',
                      controller: _confirmPasswordController,
                      obscureText: !_showConfirmPassword,
                      onChanged: (_) => setState(() {}),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _showConfirmPassword = !_showConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _showConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                      ),
                      validator: _validateConfirmPassword,
                    ),
                    const SizedBox(height: 12),
                    _PasswordRule(
                      label: 'As senhas fornecidas são idênticas',
                      isValid: _passwordsMatch,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: PrimaryButton(
                  label: 'Salvar nova senha',
                  isLoading: _isLoading,
                  onPressed: _canSubmit ? _submit : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_user == null) {
      _showMessage('Usuário não autenticado.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _accountRepository.updatePassword(
        id: _user!.id,
        password: _newPasswordController.text,
      );
      _showMessage(response.message);
      if (response.isSuccess && mounted) {
        Navigator.of(context).pop();
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

  String? _requiredField(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Campo obrigatório';
    }
    if (password.length < 8 || !password.contains(RegExp(r'[A-Z]'))) {
      return 'A senha não atende aos critérios';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Campo obrigatório';
    }
    if (value != _newPasswordController.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  bool get _canSubmit =>
      _requiredField(_currentPasswordController.text) == null &&
      _validateNewPassword(_newPasswordController.text) == null &&
      _validateConfirmPassword(_confirmPasswordController.text) == null;

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PasswordRule extends StatelessWidget {
  const _PasswordRule({required this.label, required this.isValid});

  final String label;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check_circle, color: isValid ? Colors.green : Colors.grey, size: 18),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: MyColors.colorPrimary2)),
      ],
    );
  }
}

typedef UpdatePassword = UpdatePasswordPage;
