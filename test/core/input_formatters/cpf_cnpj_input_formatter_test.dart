import 'package:costeira/core/input_formatters/cpf_cnpj_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const formatter = CpfCnpjInputFormatter();

  TextEditingValue format(String text) {
    return formatter.formatEditUpdate(
      const TextEditingValue(text: ''),
      TextEditingValue(text: text),
    );
  }

  test('formata CPF até 11 dígitos', () {
    expect(format('52998224725').text, '529.982.247-25');
  });

  test('formata CNPJ a partir do 12º dígito', () {
    expect(format('11222333000181').text, '11.222.333/0001-81');
  });

  test('limita em 14 dígitos', () {
    expect(format('11222333000181999').text, '11.222.333/0001-81');
  });
}
