import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/input_formatters/brazilian_currency_input_formatter.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_filter_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_kind.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_upsert_entity.dart';
import 'package:costeira/features/cadastros/domain/usecases/create_parceiro_usecase.dart';
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

  DateTime? _parseBr(String texto) {
    final m = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(texto.trim());
    if (m == null) return null;
    final dia = int.tryParse(m.group(1)!);
    final mes = int.tryParse(m.group(2)!);
    final ano = int.tryParse(m.group(3)!);
    if (dia == null || mes == null || ano == null) return null;
    final data = DateTime(ano, mes, dia);
    if (data.year != ano || data.month != mes || data.day != dia) return null;
    return data;
  }

  String _fmtBr(DateTime data) {
    final d = data.day.toString().padLeft(2, '0');
    final m = data.month.toString().padLeft(2, '0');
    return '$d/$m/${data.year}';
  }

  Future<void> _escolherData() async {
    final atual = _parseBr(_data.text) ?? DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: atual,
      firstDate: DateTime(atual.year - 10),
      lastDate: DateTime(atual.year + 10),
      helpText: 'Data da venda',
    );
    if (escolhida == null || !mounted) return;
    setState(() => _data.text = _fmtBr(escolhida));
  }

  Future<void> _carregarCompradores() async {
    final user = await SessionStorage.getUserSession();
    if (user == null) return;
    final farmId = await Modular.get<ResolveCurrentFarmId>()(userId: user.id);
    if (farmId == null) return;
    final lista = await Modular.get<GetParceirosUsecase>()(
      ParceiroFilterEntity(kind: ParceiroKind.comprador, appUsersId: user.id, appFazendasId: farmId),
    );
    if (!mounted) return;
    setState(() => _compradores = lista.data);
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
      await _carregarCompradores();
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

  Future<void> _escolherComprador() async {
    final opcoes = <({int value, String label})>[
      for (final item in _compradores) (value: item.id, label: item.nome),
      (value: -1, label: 'Cadastrar comprador'),
    ];
    final escolhido = await abrirOpcoesFinanceiro<int>(
      context: context,
      titulo: 'Comprador',
      atual: _compradorId,
      opcoes: opcoes,
    );
    if (escolhido == null || !mounted) return;
    if (escolhido == -1) {
      await _modalNovoComprador();
      return;
    }
    setState(() => _compradorId = escolhido);
  }

  Future<void> _modalNovoComprador() async {
    final nome = TextEditingController();
    final celular = TextEditingController();
    var salvando = false;
    String? erro;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) {
        return StatefulBuilder(
          builder: (sheet, setSheet) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.of(sheet).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cadastrar comprador',
                    style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  if (erro != null) ...[
                    Text(erro!, style: const TextStyle(fontFamily: 'Montserrat', color: Color(0xFFC62828), fontSize: 13)),
                    const SizedBox(height: 8),
                  ],
                  CampoFinanceiro(
                    rotulo: 'NOME',
                    child: TextField(
                      controller: nome,
                      decoration: decoracaoCampo('Nome do comprador'),
                      onChanged: (_) => setSheet(() => erro = null),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CampoFinanceiro(
                    rotulo: 'CELULAR (OPCIONAL)',
                    child: TextField(
                      controller: celular,
                      keyboardType: TextInputType.phone,
                      decoration: decoracaoCampo('(00) 00000-0000'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: salvando
                        ? null
                        : () async {
                            if (nome.text.trim().isEmpty) {
                              setSheet(() => erro = 'Informe o nome.');
                              return;
                            }
                            setSheet(() {
                              salvando = true;
                              erro = null;
                            });
                            try {
                              final user = await SessionStorage.getUserSession();
                              if (user == null) throw ApiException('Usuário não autenticado.');
                              final farmId = await Modular.get<ResolveCurrentFarmId>()(userId: user.id);
                              if (farmId == null) throw ApiException('Selecione uma fazenda.');
                              final criado = await Modular.get<CreateParceiroUsecase>()(
                                ParceiroUpsertEntity(
                                  kind: ParceiroKind.comprador,
                                  appUsersId: user.id,
                                  appFazendasId: farmId,
                                  tipoPessoa: WSConstantes.tipoPessoaFisica,
                                  nome: nome.text.trim(),
                                  email: '',
                                  celular: celular.text.trim(),
                                  documento: '',
                                  endereco: '-',
                                  numero: 'S/N',
                                ),
                              );
                              if (!criado.isSuccess) throw ApiException(criado.message);
                              var cadastroId = criado.resourceId;
                              if (cadastroId == null || cadastroId <= 0) {
                                final lista = await Modular.get<GetParceirosUsecase>()(
                                  ParceiroFilterEntity(
                                    kind: ParceiroKind.comprador,
                                    appUsersId: user.id,
                                    appFazendasId: farmId,
                                    nome: nome.text.trim(),
                                  ),
                                );
                                cadastroId = lista.data
                                    .where((p) => p.nome.trim().toLowerCase() == nome.text.trim().toLowerCase())
                                    .firstOrNull
                                    ?.id;
                              }
                              if (cadastroId == null || cadastroId <= 0) {
                                throw ApiException('Cadastro criado, mas o id não voltou.');
                              }
                              if (!sheet.mounted) return;
                              Navigator.pop(sheet, true);
                              if (!mounted) return;
                              await _carregarCompradores();
                              if (!mounted) return;
                              setState(() => _compradorId = cadastroId);
                              AppSnackBar.show(context: context, message: 'Comprador cadastrado.', isError: false);
                            } on ApiException catch (error) {
                              setSheet(() {
                                salvando = false;
                                erro = error.message;
                              });
                            } catch (error) {
                              setSheet(() {
                                salvando = false;
                                erro = error.toString();
                              });
                            }
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: MyColors.colorPrimary,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: salvando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                          )
                        : const Text('Salvar', style: TextStyle(fontFamily: 'Montserrat')),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    nome.dispose();
    celular.dispose();
    if (ok != true) return;
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
        title: Text('Registrar venda', style: estiloTituloAppBarPilha()),
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
                    decoration: decoracaoCampo('DD/MM/AAAA').copyWith(
                      suffixIcon: IconButton(
                        onPressed: _escolherData,
                        icon: const Icon(Icons.calendar_today_outlined, size: 18),
                      ),
                    ),
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
                    placeholder: 'Selecione ou cadastre o comprador',
                    habilitado: true,
                    onTap: _escolherComprador,
                  ),
                ),
                if (_compradores.isEmpty) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _modalNovoComprador,
                      icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                      label: const Text('Cadastrar comprador', style: TextStyle(fontFamily: 'Montserrat')),
                    ),
                  ),
                ],
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
