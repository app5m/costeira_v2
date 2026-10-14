import 'package:costeira/core/storage/session_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists and clears the web pending approval session', () async {
    await SessionStorage.saveWebPendingApproval(
      message: 'Aguarde aprovação do administrador.',
      email: 'pessoa@exemplo.com',
    );

    expect(await SessionStorage.getWebPendingApproval(), {
      'message': 'Aguarde aprovação do administrador.',
      'email': 'pessoa@exemplo.com',
    });

    await SessionStorage.clearWebPendingApproval();

    expect(await SessionStorage.getWebPendingApproval(), isNull);
  });
}
