import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/input_formatters/brazilian_currency_input_formatter.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_filter_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_kind.dart';
import 'package:costeira/features/cadastros/domain/usecases/get_parceiros_usecase.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/pages/venda_parceria_animais_page.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class VendaParceriaFormPage extends StatefulWidget {
  const VendaParceriaFormPage({
    super.key,
    required this.parceriaId,
    required this.aoVoltar,
    required this.aoSalvo,
  });

  final int parceriaId;
  final VoidCallback aoVoltar;
  final ValueChanged<int> aoSalvo;

  @override
  State<VendaParceriaFormPage> createState() => _VendaParceriaFormPageState();
}

class _VendaParceriaFormPageState extends State<VendaParceriaFormPage> {
  final _data = TextEditingController();
  final _precoKg = TextEditingController(text: BrazilianCurrency.format(0));
  final _frete = TextEditingController(text: BrazilianCurrency.format(0));
  final _comissao = TextEditingController(text: BrazilianCurrency.format(0));
  final _obs = TextEditingController();
  late final MaskTextInputFormatter _maskData = mascaraData();
  List<AnimalParceriaFin> _disponiveis = const [];
  final _animaisEscolhidos = <({AnimalParceriaFin animal, double peso})>[];
  ModoSelecaoAnimaisVenda? _modoAnimais;
  List<ParceiroEntity> _compradores = const [];
  int? _compradorId;
  bool _carregando = true;
  bool _salvando = false;
  ParceriaFin? _parceria;

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    _data.text =
        '${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year}';
    for (final c in [_data, _precoKg]) {
      c.addListener(() {
        if (mounted) setState(() {});
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  bool get _podeSalvar {
    if (_salvando || _carregando) return false;
    if (_compradorId == null) return false;
    if (_data.text.trim().length < 10) return false;
    final preco = BrazilianCurrency.parse(_precoKg.text) ?? 0;
    if (preco <= 0) return false;
    if (_animaisEscolhidos.isEmpty) return false;
    for (final item in _animaisEscolhidos) {
      if (item.peso <= 0) return false;
    }
    return true;
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final loja = FinanceiroEscopo.of(context);
      final parceria = await loja.carregarParceria(widget.parceriaId);
      _disponiveis = [
        for (final animal in parceria?.animaisAtivos ?? const <AnimalParceriaFin>[])
          if (animal.appAnimaisId != null && animal.brinco.trim().isNotEmpty) animal,
      ];
      final user = await SessionStorage.getUserSession();
      if (user != null) {
        final farmId = await Modular.get<ResolveCurrentFarmId>()(userId: user.id);
        if (farmId != null) {
          final lista = await Modular.get<GetParceirosUsecase>()(
            ParceiroFilterEntity(kind: ParceiroKind.comprador, appUsersId: user.id, appFazendasId: farmId),
          );
          _compradores = lista.data;
        }
      }
      if (!mounted) return;
      setState(() {
        _parceria = parceria;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _carregando = false);
    }
  }

  @override
  void dispose() {
    _data.dispose();
    _precoKg.dispose();
    _frete.dispose();
    _comissao.dispose();
    _obs.dispose();
    super.dispose();
  }

  String _peso6(double peso) {
    if (peso <= 0) throw ApiException('Informe o peso de saída de cada animal.');
    return peso.toStringAsFixed(6);
  }

  String get _resumoAnimais {
    if (_animaisEscolhidos.isEmpty) return '';
    if (_modoAnimais == ModoSelecaoAnimaisVenda.todos) {
      return 'Todos · ${_animaisEscolhidos.length} animais';
    }
    return '${_animaisEscolhidos.length} ${_animaisEscolhidos.length == 1 ? 'selecionado' : 'selecionados'}';
  }

  Future<void> _abrirSelecaoAnimais() async {
    if (_disponiveis.isEmpty) {
      AppSnackBar.show(context: context, message: 'Nenhum animal ativo neste contrato.');
      return;
    }
    final iniciais = <int, double>{
      for (final item in _animaisEscolhidos)
        if (item.animal.appAnimaisId != null) item.animal.appAnimaisId!: item.peso,
    };
    final resultado = await Navigator.of(context).push<VendaAnimaisSelecaoResultado>(
      MaterialPageRoute(
        builder: (_) => VendaParceriaAnimaisPage(
          animais: _disponiveis,
          precoKg: BrazilianCurrency.parse(_precoKg.text),
          modoInicial: _modoAnimais,
          selecionadosIniciais: iniciais,
        ),
      ),
    );
    if (resultado == null || !mounted) return;
    setState(() {
      _modoAnimais = resultado.modo;
      _animaisEscolhidos
        ..clear()
        ..addAll(resultado.itens);
    });
  }

  Future<void> _salvar() async {
    final loja = FinanceiroEscopo.of(context);
    final parceria = _parceria ?? loja.parceriaDetalhe;
    if (parceria == null) {
      AppSnackBar.show(context: context, message: 'Contrato não encontrado.');
      return;
    }
    if (_compradorId == null) {
      AppSnackBar.show(context: context, message: 'Selecione o comprador.');
      return;
    }
    final preco = BrazilianCurrency.parse(_precoKg.text) ?? 0;
    if (preco <= 0) {
      AppSnackBar.show(context: context, message: 'Informe o preço por kg.');
      return;
    }
    if (_animaisEscolhidos.isEmpty) {
      AppSnackBar.show(context: context, message: 'Selecione ao menos 1 animal.');
      return;
    }
    if (_salvando) return;
    setState(() => _salvando = true);
    try {
      final animais = <Map<String, dynamic>>[];
      for (final item in _animaisEscolhidos) {
        final pesoEntrada = double.tryParse(item.animal.pesoEntradaKg.replaceAll(',', '.')) ?? 0;
        if (item.peso <= 0) throw ApiException('Informe o peso de saída de cada animal.');
        if (pesoEntrada > 0 && item.peso + 0.000001 < pesoEntrada) {
          throw ApiException('Peso de saída menor que o de entrada (brinco ${item.animal.brinco}).');
        }
        animais.add({
          'id': item.animal.appAnimaisId,
          'peso': _peso6(item.peso),
        });
      }
      final vendaId = await loja.adicionarVendaParceria(
        parceriaId: parceria.id,
        investidorId: parceria.investidorId,
        data: _data.text.trim(),
        valorUnitario: preco.toStringAsFixed(2),
        idComprador: _compradorId!,
        animais: animais,
        valorFrete: (BrazilianCurrency.parse(_frete.text) ?? 0).toStringAsFixed(2),
        valorComissao: (BrazilianCurrency.parse(_comissao.text) ?? 0).toStringAsFixed(2),
        obs: _obs.text.trim().isEmpty ? null : _obs.text.trim(),
      );
      if (!mounted) return;
      AppSnackBar.show(context: context, message: 'Venda registrada.', isError: false);
      widget.aoSalvo(vendaId);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _salvando = false);
      AppSnackBar.show(context: context, message: error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _salvando = false);
      AppSnackBar.show(context: context, message: 'Não foi possível registrar a venda.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: const Text('Registrar venda', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _salvando ? null : widget.aoVoltar),
      ),
      body: _carregando
          ? const LoadingFinanceiro(altura: 280, rotulo: 'Carregando…')
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                if (_parceria != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Contrato ${_parceria!.codigo.isEmpty ? '#${_parceria!.id}' : _parceria!.codigo} · ${_parceria!.investidorNome}',
                      style: const TextStyle(fontFamily: 'Montserrat', color: Color(0xFF8A8A8A), fontSize: 12),
                    ),
                  ),
                CampoFinanceiro(
                  rotulo: 'DATA',
                  child: TextField(
                    controller: _data,
                    inputFormatters: [_maskData],
                    keyboardType: tecladoData,
                    decoration: decoracaoCampo('DD/MM/AAAA'),
                  ),
                ),
                const SizedBox(height: 12),
                CampoFinanceiro(
                  rotulo: 'COMPRADOR',
                  child: CampoEscolhaFinanceiro(
                    valor: _compradores
                            .where((c) => c.id == _compradorId)
                            .map((c) => c.nome)
                            .firstOrNull ??
                        '',
                    placeholder: _compradores.isEmpty ? 'Sem compradores' : 'Selecione o comprador',
                    habilitado: _compradores.isNotEmpty,
                    onTap: () async {
                      final escolhido = await abrirOpcoesFinanceiro<int>(
                        context: context,
                        titulo: 'Comprador',
                        atual: _compradorId,
                        opcoes: [
                          for (final item in _compradores) (value: item.id, label: item.nome),
                        ],
                      );
                      if (escolhido == null || !mounted) return;
                      setState(() => _compradorId = escolhido);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                CampoFinanceiro(
                  rotulo: 'PREÇO POR KG VIVO',
                  child: TextField(
                    controller: _precoKg,
                    keyboardType: tecladoMoeda,
                    inputFormatters: [mascaraMoeda],
                    decoration: decoracaoCampo('R\$ 0,00'),
                  ),
                ),
                const SizedBox(height: 12),
                CampoFinanceiro(
                  rotulo: 'FRETE (OPCIONAL)',
                  child: TextField(
                    controller: _frete,
                    keyboardType: tecladoMoeda,
                    inputFormatters: [mascaraMoeda],
                    decoration: decoracaoCampo('R\$ 0,00'),
                  ),
                ),
                const SizedBox(height: 12),
                CampoFinanceiro(
                  rotulo: 'COMISSÃO (OPCIONAL)',
                  child: TextField(
                    controller: _comissao,
                    keyboardType: tecladoMoeda,
                    inputFormatters: [mascaraMoeda],
                    decoration: decoracaoCampo('R\$ 0,00'),
                  ),
                ),
                const SizedBox(height: 12),
                CampoFinanceiro(
                  rotulo: 'OBS (OPCIONAL)',
                  child: TextField(controller: _obs, decoration: decoracaoCampo('Observações')),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Animais',
                  style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 8),
                CampoEscolhaFinanceiro(
                  valor: _resumoAnimais,
                  placeholder: _disponiveis.isEmpty ? 'Sem animais no contrato' : 'Selecionar animais',
                  habilitado: _disponiveis.isNotEmpty,
                  onTap: _abrirSelecaoAnimais,
                ),
                if (_animaisEscolhidos.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  CartaoBranco(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < _animaisEscolhidos.length && i < 6; i++) ...[
                          if (i > 0) const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _animaisEscolhidos[i].animal.brinco,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Text(
                                '${_animaisEscolhidos[i].peso == _animaisEscolhidos[i].peso.roundToDouble() ? _animaisEscolhidos[i].peso.toInt() : _animaisEscolhidos[i].peso.toStringAsFixed(2)} kg',
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF313131),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (_animaisEscolhidos.length > 6) ...[
                          const SizedBox(height: 6),
                          Text(
                            '+${_animaisEscolhidos.length - 6} ${_animaisEscolhidos.length - 6 == 1 ? 'animal' : 'animais'}…',
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
                const SizedBox(height: 16),
                BotaoPrimarioFinanceiro(
                  rotulo: 'Salvar venda',
                  carregando: _salvando,
                  habilitado: _podeSalvar,
                  onPressed: _salvar,
                ),
              ],
            ),
    );
  }
}
