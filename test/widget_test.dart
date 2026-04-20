import 'package:costeira/app/app_module.dart';
import 'package:costeira/app/app_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_modular/flutter_modular.dart';

void main() {
  testWidgets('renders modular app shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      ModularApp(module: AppModule(), child: const AppWidget()),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.byType(AppWidget), findsOneWidget);
  });
}
