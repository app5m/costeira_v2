import 'package:costeira/features/financeiro/presentation/web/financeiro_web_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Harness espelhando a troca de abas do shell sem Modular/API.
class _FinanceiroAbaHarness extends StatefulWidget {
  const _FinanceiroAbaHarness();

  @override
  State<_FinanceiroAbaHarness> createState() => _FinanceiroAbaHarnessState();
}

class _FinanceiroAbaHarnessState extends State<_FinanceiroAbaHarness> {
  FinanceiroWebAba aba = FinanceiroWebAba.visao;
  bool naRaiz = true;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 760;
    return Scaffold(
      body: Row(
        children: [
          if (wide && naRaiz)
            SizedBox(
              width: 200,
              child: ListView(
                children: [
                  for (final item in FinanceiroWebAba.values)
                    ListTile(
                      key: ValueKey('aba-${item.name}'),
                      selected: aba == item,
                      title: Text(item.name),
                      onTap: naRaiz
                          ? () => setState(() {
                              aba = item;
                              naRaiz = true;
                            })
                          : null,
                    ),
                ],
              ),
            ),
          Expanded(
            child: Column(
              children: [
                Text('aba:${aba.name}'),
                TextButton(
                  onPressed: () => setState(() => naRaiz = false),
                  child: const Text('abrir-subfluxo'),
                ),
                TextButton(
                  onPressed: () => setState(() => naRaiz = true),
                  child: const Text('voltar-raiz'),
                ),
                if (!wide)
                  const Text('drawer-mode')
                else if (naRaiz)
                  const Text('rail-mode')
                else
                  const Text('subfluxo-mode'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('preserva aba ao alternar seções na raiz', (tester) async {
    final view = tester.view;
    view.physicalSize = const Size(1200, 800);
    view.devicePixelRatio = 1;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: _FinanceiroAbaHarness()));
    expect(find.text('aba:visao'), findsOneWidget);
    expect(find.text('rail-mode'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('aba-lancamentos')));
    await tester.pump();
    expect(find.text('aba:lancamentos'), findsOneWidget);

    await tester.tap(find.text('abrir-subfluxo'));
    await tester.pump();
    expect(find.text('subfluxo-mode'), findsOneWidget);

    await tester.tap(find.text('voltar-raiz'));
    await tester.pump();
    expect(find.text('aba:lancamentos'), findsOneWidget);
    expect(find.text('rail-mode'), findsOneWidget);
  });

  testWidgets('usa drawer mode abaixo de 760px', (tester) async {
    final view = tester.view;
    view.physicalSize = const Size(390, 844);
    view.devicePixelRatio = 1;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: _FinanceiroAbaHarness()));
    expect(find.text('drawer-mode'), findsOneWidget);
    expect(find.byKey(const ValueKey('aba-visao')), findsNothing);
  });
}
