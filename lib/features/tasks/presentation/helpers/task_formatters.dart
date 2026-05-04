import 'package:flutter/material.dart';

String formatTaskMonth(DateTime date) {
  return '${_monthNames[date.month - 1]} ${date.year}';
}

String formatTaskDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

DateTime? parseTaskApiDate(String value) {
  final match = RegExp(r'(\d{2})/(\d{2})/(\d{4})').firstMatch(value);
  if (match == null) {
    return null;
  }

  return DateTime(
    int.parse(match.group(3)!),
    int.parse(match.group(2)!),
    int.parse(match.group(1)!),
  );
}

Color colorFromHex(String value) {
  final normalized = value.replaceAll('#', '').trim();
  if (normalized.length != 6) {
    return const Color(0xFF8C8C8C);
  }
  return Color(int.parse('FF$normalized', radix: 16));
}

String formatTaskResponsavelPhone(String value) {
  final digits = _onlyTaskResponsavelDigits(value);
  final buffer = StringBuffer();

  if (digits.isEmpty) {
    return '';
  }

  buffer.write('(');
  buffer.write(digits.substring(0, _min(digits.length, 2)));

  if (digits.length >= 2) {
    buffer.write(')');
  }
  if (digits.length > 2) {
    buffer.write(' ');
    buffer.write(digits.substring(2, _min(digits.length, 7)));
  }
  if (digits.length > 7) {
    buffer.write('-');
    buffer.write(digits.substring(7, _min(digits.length, 11)));
  }

  return buffer.toString();
}

String taskResponsavelApiPhoneDigits(String value) {
  final digits = _onlyTaskResponsavelDigits(value);
  if (digits.isEmpty) {
    return '';
  }
  return digits.startsWith('55') ? digits : '55$digits';
}

String _onlyTaskResponsavelDigits(String value) {
  var digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('55') && digits.length > 11) {
    digits = digits.substring(2);
  }
  return digits.length <= 11 ? digits : digits.substring(0, 11);
}

int _min(int left, int right) => left < right ? left : right;

const List<String> _monthNames = [
  'Janeiro',
  'Fevereiro',
  'Marco',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];
