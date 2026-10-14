import 'package:costeira/core/api/api_response_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('recovers JSON appended after PHP warnings', () {
    const response = '''
<b>Warning</b>: Undefined constant HOME_URI<br />
<b>Warning</b>: openssl_encrypt(): invalid IV<br />
[{"status":"02","msg":"Aguarde aprovação do administrador."}]
''';

    final recovered = recoverEmbeddedJson(response);
    final map = responseAsMap(recovered);

    expect(map['status'], '02');
    expect(map['msg'], 'Aguarde aprovação do administrador.');
  });

  test('keeps a non-JSON response unchanged', () {
    const response = '<b>Warning</b>: resposta sem payload';

    expect(recoverEmbeddedJson(response), response);
  });
}
