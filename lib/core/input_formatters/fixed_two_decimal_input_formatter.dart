import 'package:flutter/services.dart';

class FixedTwoDecimalInputFormatter extends TextInputFormatter {
  const FixedTwoDecimalInputFormatter({this.maxIntegerDigits = 9});

  final int maxIntegerDigits;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '0.00', selection: TextSelection.collapsed(offset: 4));
    }

    final withoutLeadingZeros = digitsOnly.replaceFirst(RegExp(r'^0+'), '');
    final safeDigits = withoutLeadingZeros.isEmpty ? '0' : withoutLeadingZeros;
    final integerDigitsLength = safeDigits.length > 2 ? safeDigits.length - 2 : 1;

    if (integerDigitsLength > maxIntegerDigits) {
      return oldValue;
    }

    final formatted = _formatDigits(safeDigits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatDigits(String digits) {
    final padded = digits.padLeft(3, '0');
    final splitIndex = padded.length - 2;
    final integerPart = padded.substring(0, splitIndex);
    final decimalPart = padded.substring(splitIndex);
    return '${int.parse(integerPart)}.$decimalPart';
  }
}
