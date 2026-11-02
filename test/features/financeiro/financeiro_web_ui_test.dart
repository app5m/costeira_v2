import 'package:costeira/core/menus/menu_action_resolver.dart';
import 'package:costeira/core/menus/menu_slug.dart';
import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/web/widgets/financeiro_web_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('financeiro deixa de ser módulo em desenvolvimento na web', () {
    expect(
      MenuActionResolver.isDevelopmentModule(MenuSlug.financeiro),
      isFalse,
    );
    expect(MenuActionResolver.isDevelopmentModule(MenuSlug.relatorios), isTrue);
  });

  testWidgets('toolbar e empty state renderizam', (tester) async {
    var exited = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                FinanceiroWebToolbar(
                  title: 'Ambiente financeiro',
                  subtitle: 'Contexto',
                  actions: [
                    FinanceiroWebPrimaryButton(
                      label: 'Voltar ao Dashboard',
                      onPressed: () => exited = true,
                    ),
                  ],
                ),
                const FinanceiroWebEmpty(message: 'Sem permissão'),
                FinanceiroWebMetricCard(
                  label: 'Saldo',
                  value: financeiroWebReais(10),
                ),
                const FinanceiroWebStatusChip(SituacaoLancamento.liquidado),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Ambiente financeiro'), findsOneWidget);
    expect(find.text('Sem permissão'), findsOneWidget);
    expect(find.text('SALDO'), findsOneWidget);
    expect(find.text('Liquidado'), findsOneWidget);

    await tester.tap(find.text('Voltar ao Dashboard'));
    await tester.pump();
    expect(exited, isTrue);
  });

  testWidgets('back button e empty action', (tester) async {
    var back = false;
    var action = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              FinanceiroWebBackButton(onPressed: () => back = true),
              FinanceiroWebEmpty(
                message: 'Você não tem permissão para acessar o Financeiro.',
                actionLabel: 'Voltar ao Dashboard',
                onAction: () => action = true,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FinanceiroWebBackButton));
    await tester.pump();
    expect(back, isTrue);

    await tester.tap(find.text('Voltar ao Dashboard'));
    await tester.pump();
    expect(action, isTrue);
  });

  for (final size in const [Size(1440, 900), Size(720, 900), Size(390, 844)]) {
    testWidgets('tabela e painel cabem em ${size.width.toInt()}', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(size: size),
          child: MaterialApp(
            home: Scaffold(
              body: ListView(
                children: const [
                  FinanceiroWebPanel(
                    child: FinanceiroWebTableHeader(
                      columns: [
                        ('Conta', 4),
                        ('Saldo', 2),
                        ('Status', 2),
                      ],
                    ),
                  ),
                  FinanceiroWebSectionTitle('Relatórios'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('CONTA'), findsOneWidget);
      expect(find.text('Relatórios'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
