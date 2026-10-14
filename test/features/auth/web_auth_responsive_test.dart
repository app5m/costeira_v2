import 'package:costeira/features/auth/presentation/web/auth_web_frame.dart';
import 'package:costeira/features/auth/presentation/web/welcome_web_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const viewports = <Size>[Size(1440, 900), Size(900, 1024), Size(390, 844)];

  for (final viewport in viewports) {
    testWidgets('welcome fits ${viewport.width}x${viewport.height}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(viewport);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: WelcomeWebPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bem-vindo à Costeira'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('auth frame fits ${viewport.width}x${viewport.height}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(viewport);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: AuthWebFrame(
            title: 'Entrar',
            subtitle: 'Preencha os campos abaixo.',
            body: Column(
              children: [TextField(), SizedBox(height: 16), TextField()],
            ),
            footer: SizedBox(height: 48),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Entrar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
