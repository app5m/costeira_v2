import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

enum _FiltroVenda { todas, pendentes, acertadas }

class VendasParceriaPage extends StatefulWidget {
  const VendasParceriaPage({
    super.key,
    required this.parceriaId,
    required this.aoVoltar,
    required this.aoRegistrar,
    required this.aoAcerto,
    required this.aoFinanceiro,
  });

  final int parceriaId;
  final VoidCallback aoVoltar;
  final VoidCallback aoRegistrar;
  final ValueChanged<VendaParceriaFin> aoAcerto;
  final ValueChanged<VendaParceriaFin> aoFinanceiro;

  @override
  State<VendasParceriaPage> createState() => _VendasParceriaPageState();
}

class _VendasParceriaPageState extends State<VendasParceriaPage> {
  _FiltroVenda _filtro = _FiltroVenda.todas;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FinanceiroEscopo.of(context).carregarParceria(widget.parceriaId);
    });
  }

  String _dataExibir(String raw) {
    final texto = raw.trim();
    final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(texto);
    if (iso != null) {
      return '${iso.group(3)}/${iso.group(2)}/${iso.group(1)}';
    }
    return texto;
  }

  String _precoExibir(String raw) {
    final texto = raw.trim();
    if (texto.isEmpty) return '';
    if (texto.toLowerCase().contains('r\$')) {
      return texto.endsWith('/kg') ? texto : '$texto/kg';
    }
    final n = double.tryParse(texto.replaceAll(',', '.'));
    if (n != null) return '${reais(n)}/kg';
    return 'R\$ $texto/kg';
  }

  String _pesoExibir(double? peso) {
    if (peso == null || peso <= 0) return '';
    final inteiro = peso == peso.roundToDouble();
    final texto = inteiro ? peso.toInt().toString() : peso.toStringAsFixed(1);
    return '$texto kg';
  }

  @override
  Widget build(BuildContext context) {
    final loja = FinanceiroEscopo.of(context);
    final parceria = loja.parceriaDetalhe?.id == widget.parceriaId
        ? loja.parceriaDetalhe
        : loja.parcerias.where((e) => e.id == widget.parceriaId).firstOrNull;
    final vendas = parceria?.vendas ?? const <VendaParceriaFin>[];
    final filtradas = [
      for (final item in vendas)
        if (_filtro == _FiltroVenda.todas ||
            (_filtro == _FiltroVenda.pendentes && !item.acertoConfirmado) ||
            (_filtro == _FiltroVenda.acertadas && item.acertoConfirmado))
          item,
    ];

    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: const Text('Vendas', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.aoVoltar),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.aoRegistrar,
        backgroundColor: MyColors.colorPrimary,
        tooltip: 'Registrar venda',
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          GrupoChips(
            opcoes: const ['Todas', 'Sem acerto', 'Acertadas'],
            selecionado: switch (_filtro) {
              _FiltroVenda.todas => 'Todas',
              _FiltroVenda.pendentes => 'Sem acerto',
              _FiltroVenda.acertadas => 'Acertadas',
            },
            aoEscolher: (rotulo) => setState(() {
              _filtro = switch (rotulo) {
                'Sem acerto' => _FiltroVenda.pendentes,
                'Acertadas' => _FiltroVenda.acertadas,
                _ => _FiltroVenda.todas,
              };
            }),
          ),
          const SizedBox(height: 12),
          if (loja.carregandoParcerias && parceria == null)
            const LoadingFinanceiro(altura: 160, rotulo: 'Carregando vendas…')
          else if (filtradas.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'Nenhuma venda neste filtro.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF8A8A8A)),
              ),
            )
          else
            for (final item in filtradas) ...[
              _CartaoVenda(
                item: item,
                data: item.data.isEmpty ? null : _dataExibir(item.data),
                preco: _precoExibir(item.precoKg),
                peso: _pesoExibir(item.pesoTotal),
                aoAcerto: () => widget.aoAcerto(item),
                aoFinanceiro: () => widget.aoFinanceiro(item),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class _CartaoVenda extends StatelessWidget {
  const _CartaoVenda({
    required this.item,
    required this.data,
    required this.preco,
    required this.peso,
    required this.aoAcerto,
    required this.aoFinanceiro,
  });

  final VendaParceriaFin item;
  final String? data;
  final String preco;
  final String peso;
  final VoidCallback aoAcerto;
  final VoidCallback aoFinanceiro;

  @override
  Widget build(BuildContext context) {
    final titulo = data == null || data!.isEmpty ? 'Venda #${item.id}' : 'Venda · $data';
    final meta = [
      if (item.compradorNome != null && item.compradorNome!.trim().isNotEmpty)
        item.compradorNome!.trim(),
      if (preco.isNotEmpty) preco,
      if (item.qtdAnimais != null && item.qtdAnimais! > 0)
        '${item.qtdAnimais} ${item.qtdAnimais == 1 ? 'animal' : 'animais'}',
      if (peso.isNotEmpty) peso,
    ].join(' · ');

    return CartaoBranco(
      aoToque: item.acertoConfirmado ? aoFinanceiro : aoAcerto,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F6EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.sell_outlined, color: MyColors.colorPrimary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            titulo,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color(0xFF1F2A24),
                            ),
                          ),
                        ),
                        if (item.valorBruto != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            reais(item.valorBruto!),
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Color(0xFF1F2A24),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    FlagStatusFinanceiro(
                      rotulo: item.acertoConfirmado ? 'Acertada' : 'Sem acerto',
                      positivo: item.acertoConfirmado,
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        meta,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Color(0xFF8A8A8A),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: item.acertoConfirmado ? aoFinanceiro : aoAcerto,
              icon: Icon(
                item.acertoConfirmado ? Icons.account_balance_wallet_outlined : Icons.calculate_outlined,
                size: 18,
              ),
              label: Text(
                item.acertoConfirmado ? 'Ver financeiro' : 'Conferir acerto',
                style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: MyColors.colorPrimary,
                side: const BorderSide(color: Color(0xFFB7DFC4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
