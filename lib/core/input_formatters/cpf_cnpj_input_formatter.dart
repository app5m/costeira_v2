import 'package:flutter/services.dart';

/// CPF até 11 dígitos (`000.000.000-00`). A partir do 12º, CNPJ (`00.000.000/0000-00`).
class CpfCnpjInputFormatter extends TextInputFormatter {
  const CpfCnpjInputFormatter();

  static const _cpfMask = '###.###.###-##';
  static const _cnpjMask = '##.###.###/####-##';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final limited = digits.length > 14 ? digits.substring(0, 14) : digits;
    final formatted = _apply(
      limited.length > 11 ? _cnpjMask : _cpfMask,
      limited,
    );
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _apply(String mask, String digits) {
    final buffer = StringBuffer();
    var index = 0;
    for (final char in mask.split('')) {
      if (index >= digits.length) {
        break;
      }
      if (char == '#') {
        buffer.write(digits[index]);
        index++;
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }
}
