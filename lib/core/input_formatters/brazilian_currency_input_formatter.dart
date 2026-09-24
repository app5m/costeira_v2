import 'package:flutter/services.dart';

/// Formata digitação como dinheiro PT-BR: `R$ 1.234,56`.
class BrazilianCurrencyInputFormatter extends TextInputFormatter {
  const BrazilianCurrencyInputFormatter({this.maxIntegerDigits = 9});

  final int maxIntegerDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      const text = 'R\$ 0,00';
      return const TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    final withoutLeadingZeros = digitsOnly.replaceFirst(RegExp(r'^0+'), '');
    final safeDigits = withoutLeadingZeros.isEmpty ? '0' : withoutLeadingZeros;
    final integerDigitsLength = safeDigits.length > 2
        ? safeDigits.length - 2
        : 1;

    if (integerDigitsLength > maxIntegerDigits) {
      return oldValue;
    }

    final formatted = BrazilianCurrency.formatFromDigits(safeDigits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class BrazilianCurrency {
  const BrazilianCurrency._();

  /// `R$ 1.234,56` a partir só dos dígitos (centavos inclusos).
  static String formatFromDigits(String digits) {
    final padded = digits.padLeft(3, '0');
    final splitIndex = padded.length - 2;
    final integerPart = padded.substring(0, splitIndex);
    final decimalPart = padded.substring(splitIndex);
    return 'R\$ ${_thousands(integerPart)},$decimalPart';
  }

  /// Formata número para display `R$ 1.234,56`.
  static String format(num value) {
    final cents = (value * 100).round().abs();
    final sign = value < 0 ? '-' : '';
    return '$sign${formatFromDigits(cents.toString())}';
  }

  /// Aceita raw da API/`TextField` e devolve display. Null se vazio.
  static String? formatFromRaw(String? raw) {
    final parsed = parse(raw ?? '');
    if (parsed == null) {
      return null;
    }
    return format(parsed);
  }

  /// `R$ 1.234,56` / `1.234,56` / `1234.56` → double.
  static double? parse(String value) {
    var normalized = value.replaceAll('R\$', '').replaceAll(' ', '').trim();
    if (normalized.isEmpty) {
      return null;
    }
    if (normalized.contains(',')) {
      normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
    }
    return double.tryParse(normalized);
  }

  /// Display → payload API Postman (`1234,56`).
  static String toApi(String display) {
    final parsed = parse(display);
    if (parsed == null) {
      return '';
    }
    return parsed
        .toStringAsFixed(2)
        .replaceAll('.', ',');
  }

  /// Frete/comissão opcional: vazio ou zero → null.
  static String? toApiOrNull(String display) {
    final api = toApi(display);
    if (api.isEmpty || api == '0,00') {
      return null;
    }
    return api;
  }

  static String _thousands(String integerDigits) {
    final buffer = StringBuffer();
    final chars = integerDigits.split('');
    for (var i = 0; i < chars.length; i++) {
      final reverseIndex = chars.length - i;
      buffer.write(chars[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }
}
