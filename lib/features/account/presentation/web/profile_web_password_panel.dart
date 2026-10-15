import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_buttons.dart';
import 'package:costeira/core/components/app_form_field.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/account/repositories/account_repository.dart';
import 'package:costeira/features/auth/models/user_session.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ProfileWebPasswordPanel extends StatefulWidget {
  const ProfileWebPasswordPanel({super.key});

  @override
  State<ProfileWebPasswordPanel> createState() =>
      _ProfileWebPasswordPanelState();
}

class _ProfileWebPasswordPanelState extends State<ProfileWebPasswordPanel> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  late final AccountRepository _repository;
  UserSession? _user;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _repository = Modular.get<AccountRepository>();
    _loadUser();
  }

  Future<void> _loadUser() async {
    _user = await SessionStorage.getUserSession();
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _newController.text.length >= 8;
  bool get _hasUppercase => _newController.text.contains(RegExp(r'[A-Z]'));
  bool get _matches =>
      _confirmController.text.isNotEmpty &&
      _newController.text == _confirmController.text;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      onChanged: () => setState(() {}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alterar senha',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF252525),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Insira sua senha atual e a nova para efetuar a alteração.',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF777777),
            ),
          ),
          const SizedBox(height: 28),
          AppFormField(
            label: 'Senha atual',
            hintText: 'Digite a senha atual',
            controller: _currentController,
            obscureText: !_showCurrent,
            autocorrect: false,
            enableSuggestions: false,
            autofillHints: const [AutofillHints.password],
            suffixIcon: _visibilityButton(
              visible: _showCurrent,
              onPressed: () => setState(() => _showCurrent = !_showCurrent),
            ),
            validator: _required,
          ),
          const SizedBox(height: 18),
          AppFormField(
            label: 'Nova senha',
            hintText: 'Digite a nova senha',
            controller: _newController,
            obscureText: !_showNew,
            autocorrect: false,
            enableSuggestions: false,
            autofillHints: const [AutofillHints.newPassword],
            onChanged: (_) => setState(() {}),
            suffixIcon: _visibilityButton(
              visible: _showNew,
              onPressed: () => setState(() => _showNew = !_showNew),
            ),
            validator: _validateNew,
          ),
          const SizedBox(height: 12),
          _PasswordRule(
            label: 'Deve ter no mínimo 8 caracteres',
            valid: _hasMinLength,
          ),
          const SizedBox(height: 8),
          _PasswordRule(
            label: 'Deve ter uma letra maiúscula',
            valid: _hasUppercase,
          ),
          const SizedBox(height: 18),
          AppFormField(
            label: 'Repita a nova senha',
            hintText: 'Repita a nova senha',
            controller: _confirmController,
            obscureText: !_showConfirm,
            autocorrect: false,
            enableSuggestions: false,
            autofillHints: const [AutofillHints.newPassword],
            onChanged: (_) => setState(() {}),
            suffixIcon: _visibilityButton(
              visible: _showConfirm,
              onPressed: () => setState(() => _showConfirm = !_showConfirm),
            ),
            validator: _validateConfirm,
          ),
          const SizedBox(height: 12),
          _PasswordRule(
            label: 'As senhas fornecidas são idênticas',
            valid: _matches,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: 220,
            child: PrimaryButton(
              label: 'Salvar nova senha',
              isLoading: _saving,
              onPressed: _canSubmit ? _submit : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _visibilityButton({
    required bool visible,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: const Color(0xFF777777),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_user == null) {
      _message('Usuário não autenticado.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      final response = await _repository.updatePassword(
        id: _user!.id,
        password: _newController.text,
      );
      _message(response.message, isError: !response.isSuccess);
      if (response.isSuccess) {
        _currentController.clear();
        _newController.clear();
        _confirmController.clear();
      }
    } on ApiException catch (error) {
      _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? value) =>
      (value ?? '').isEmpty ? 'Campo obrigatório' : null;

  String? _validateNew(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Campo obrigatório';
    if (password.length < 8 || !password.contains(RegExp(r'[A-Z]'))) {
      return 'A senha não atende aos critérios';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if ((value ?? '').isEmpty) return 'Campo obrigatório';
    if (value != _newController.text) return 'As senhas não coincidem';
    return null;
  }

  bool get _canSubmit =>
      _required(_currentController.text) == null &&
      _validateNew(_newController.text) == null &&
      _validateConfirm(_confirmController.text) == null;

  void _message(String message, {bool isError = true}) {
    if (!mounted) return;
    AppSnackBar.show(context: context, message: message, isError: isError);
  }
}

class _PasswordRule extends StatelessWidget {
  const _PasswordRule({required this.label, required this.valid});

  final String label;
  final bool valid;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          valid ? Icons.check_circle : Icons.radio_button_unchecked,
          color: valid ? MyColors.colorPrimary : const Color(0xFFAAAAAA),
          size: 17,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: valid ? MyColors.colorPrimary : const Color(0xFF777777),
            ),
          ),
        ),
      ],
    );
  }
}
