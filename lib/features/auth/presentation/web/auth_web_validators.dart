final RegExp authEmailPattern = RegExp(
  r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$',
);

String? validateAuthEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) {
    return 'Informe o e-mail';
  }
  if (!authEmailPattern.hasMatch(email)) {
    return 'E-mail inválido';
  }
  return null;
}

String? validateLoginPassword(String? value) {
  if ((value ?? '').isEmpty) {
    return 'Informe a senha';
  }
  if ((value ?? '').length < 6) {
    return 'A senha deve ter ao menos 6 caracteres';
  }
  return null;
}

String? validateRegisterPassword(String? value) {
  final password = value ?? '';
  if (password.isEmpty) {
    return 'Informe a senha';
  }
  if (password.length < 8) {
    return 'A senha deve ter ao menos 8 caracteres';
  }
  return null;
}

String? validateRequiredField(String? value) {
  if ((value ?? '').trim().isEmpty) {
    return 'Campo obrigatório';
  }
  return null;
}

String cleanDigits(String value) {
  return value.replaceAll(RegExp(r'\D'), '');
}
