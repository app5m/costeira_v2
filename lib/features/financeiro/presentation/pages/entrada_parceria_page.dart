import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_params_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_category_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_subcategory_entity.dart';
import 'package:costeira/core/common/get_list/domain/usecases/get_list_usecase.dart';
import 'package:costeira/core/components/adaptive_selection_modal.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/pages/lancamento_animais_page.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

enum _ModoEntrada { existente, novo }

class _AnimalExistenteLinha {
  _AnimalExistenteLinha(this.animal) : peso = TextEditingController(text: _pesoInicial(animal));

  final AnimalEntity animal;
  final TextEditingController peso;

  void dispose() => peso.dispose();
}

class _AnimalNovoLinha {
  _AnimalNovoLinha()
      : brinco = TextEditingController(),
        peso = TextEditingController();

  final TextEditingController brinco;
  final TextEditingController peso;
  int? categoriaId;
  int? faseId;
  int sexo = 2;

  void dispose() {
    brinco.dispose();
    peso.dispose();
  }
}

String _pesoInicial(AnimalEntity animal) {
  final peso = animal.ultimoPeso?.peso ?? animal.peso;
  if (peso == null) return '';
  return peso.toStringAsFixed(peso == peso.roundToDouble() ? 0 : 2);
}

String _peso6(String valor) {
  final n = double.tryParse(valor.trim().replaceAll(',', '.'));
  if (n == null || n <= 0) throw ApiException('Informe o peso de entrada de cada animal.');
  return n.toStringAsFixed(6);
}

class EntradaParceriaPage extends StatefulWidget {
  const EntradaParceriaPage({
    super.key,
    required this.parceriaId,
    required this.aoVoltar,
    required this.aoSalvo,
  });

  final int parceriaId;
  final VoidCallback aoVoltar;
  final VoidCallback aoSalvo;

  @override
  State<EntradaParceriaPage> createState() => _EntradaParceriaPageState();
}

class _EntradaParceriaPageState extends State<EntradaParceriaPage> {
  final _data = TextEditingController();
  final _maskData = MaskTextInputFormatter(mask: '##/##/####', filter: {'#': RegExp(r'[0-9]')});
  _ModoEntrada _modo = _ModoEntrada.existente;
  final _existentes = <_AnimalExistenteLinha>[];
  final _novos = <_AnimalNovoLinha>[_AnimalNovoLinha()];
  final _categoriasPorSexo = <int, List<ListCategoryEntity>>{};
  final _pendenteSexo = <int, Future<void>>{};
  Set<int> _vinculados = {};
  bool _carregandoListas = true;
  String? _erroCategorias;
  bool _salvando = false;
  int? _userId;

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    _data.text =
        '${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _carregarListas();
    });
  }

  Future<void> _carregarListas() async {
    if (!mounted) return;
    setState(() {
      _carregandoListas = true;
      _erroCategorias = null;
    });
    try {
      final loja = FinanceiroEscopo.of(context);
      final user = await SessionStorage.getUserSession();
      if (!mounted) return;
      if (user == null) {
        setState(() {
          _carregandoListas = false;
          _erroCategorias = 'Sessão inválida.';
        });
        return;
      }
      _userId = sessionAccountUserId(user.id);
      await Future.wait([
        _garantirCategorias(1),
        _garantirCategorias(2),
      ]);
      if (!mounted) return;
      final semCats = _categoriasDoSexo(1).isEmpty && _categoriasDoSexo(2).isEmpty;
      setState(() {
        _carregandoListas = false;
        _erroCategorias = semCats ? 'Não foi possível carregar as categorias.' : null;
      });

      // Vínculos em background — não afeta categorias.
      () async {
        try {
          final vinculados = await loja.idsAnimaisVinculadosParceria();
          await loja.carregarParceria(widget.parceriaId);
          if (!mounted) return;
          setState(() => _vinculados = vinculados);
        } catch (_) {}
      }();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _carregandoListas = false;
        if (_categoriasPorSexo.values.every((c) => c.isEmpty)) {
          _erroCategorias = error.message;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _carregandoListas = false;
        if (_categoriasPorSexo.values.every((c) => c.isEmpty)) {
          _erroCategorias = 'Não foi possível carregar as categorias.';
        }
      });
    }
  }

  Future<void> _garantirCategorias(int sexo) {
    final cached = _categoriasPorSexo[sexo];
    if (cached != null && cached.isNotEmpty) return Future.value();
    final pendente = _pendenteSexo[sexo];
    if (pendente != null) return pendente;

    final userId = _userId;
    if (userId == null) return Future.value();

    final future = () async {
      try {
        final lista = await Modular.get<GetListUsecase>()(
          GetListParamsEntity(sexo: sexo, userId: userId),
        );
        if (!mounted) return;
        setState(() {
          _categoriasPorSexo[sexo] = lista.animaisCategorias;
          if (lista.animaisCategorias.isNotEmpty) _erroCategorias = null;
        });
      } finally {
        _pendenteSexo.remove(sexo);
        if (mounted) setState(() {});
      }
    }();
    _pendenteSexo[sexo] = future;
    if (mounted) setState(() {});
    return future;
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

  String? _validarAntesSalvar() {
    final dataTxt = _data.text.trim();
    if (dataTxt.isEmpty) return 'Informe a data da entrada.';
    if (dataTxt.length < 10) return 'Data incompleta. Use dd/mm/aaaa.';
    final data = _parseBr(dataTxt);
    if (data == null) return 'Data inválida.';

    final parceria = FinanceiroEscopo.of(context).parceriaDetalhe;
    if (parceria != null && parceria.id == widget.parceriaId) {
      final inicio = _parseBr(parceria.dataInicio);
      final fimTxt = parceria.dataFim?.trim() ?? '';
      final fim = fimTxt.isEmpty ? null : _parseBr(fimTxt);
      if (inicio != null && data.isBefore(inicio)) {
        return 'Entrada fora da vigência do contrato.';
      }
      if (fim != null && data.isAfter(fim)) {
        return 'Entrada fora da vigência do contrato.';
      }
    }

    if (_modo == _ModoEntrada.existente) {
      if (_existentes.isEmpty) return 'Selecione ao menos 1 animal.';
      final bloqueados = [
        for (final item in _existentes)
          if (_vinculados.contains(item.animal.id)) item.animal.brinco?.trim().isNotEmpty == true
              ? item.animal.brinco!.trim()
              : '#${item.animal.id}',
      ];
      if (bloqueados.isNotEmpty) {
        return 'Animal já vinculado a um contrato: ${bloqueados.join(', ')}.';
      }
    }
    return null;
  }

  @override
  void dispose() {
    _data.dispose();
    for (final item in _existentes) {
      item.dispose();
    }
    for (final item in _novos) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _escolherExistentes() async {
    final atuais = [for (final item in _existentes) item.animal];
    final List<AnimalEntity>? escolhidos;
    if (kIsWeb) {
      escolhidos = await showAdaptiveSelectionModal<List<AnimalEntity>>(
        context: context,
        title: 'Selecionar animais',
        builder: (embeddedInDialog) => LancamentoAnimaisPage(
          selecionados: atuais,
          bloqueados: _vinculados,
          motivoBloqueio: 'Animal já vinculado a um contrato ou com patrimônio próprio.',
          ocultarBloqueados: true,
          somenteAtivos: true,
          somenteComBrinco: true,
          embeddedInDialog: embeddedInDialog,
        ),
      );
    } else {
      escolhidos = await Navigator.of(context).push<List<AnimalEntity>>(
        MaterialPageRoute(
          builder: (_) => LancamentoAnimaisPage(
            selecionados: atuais,
            bloqueados: _vinculados,
            motivoBloqueio: 'Animal já vinculado a um contrato ou com patrimônio próprio.',
            ocultarBloqueados: true,
            somenteAtivos: true,
            somenteComBrinco: true,
          ),
        ),
      );
    }
    if (escolhidos == null || !mounted) return;
    final selecionados = escolhidos;
    final pesos = {
      for (final item in _existentes) item.animal.id: item.peso.text,
    };
    for (final item in _existentes) {
      item.dispose();
    }
    setState(() {
      _existentes
        ..clear()
        ..addAll([
          for (final animal in selecionados)
            if (!_vinculados.contains(animal.id))
              _AnimalExistenteLinha(animal)..peso.text = pesos[animal.id] ?? _pesoInicial(animal),
        ]);
    });
  }

  List<ListCategoryEntity> _categoriasDoSexo(int sexo) {
    // util/lista já filtra por sexo — não refiltrar por cat.sexo (pode vir 0/errado).
    return _categoriasPorSexo[sexo] ?? const <ListCategoryEntity>[];
  }

  List<ListSubcategoryEntity> _fases(int sexo, int? categoriaId) {
    final cat = _categoriasDoSexo(sexo).where((c) => c.id == categoriaId).firstOrNull;
    return cat?.subcategorias ?? const [];
  }

  Future<void> _aoMudarSexo(_AnimalNovoLinha linha, int? valor) async {
    final sexo = valor ?? 2;
    setState(() {
      linha.sexo = sexo;
      linha.categoriaId = null;
      linha.faseId = null;
    });
    await _garantirCategorias(sexo);
  }

  Future<T?> _abrirOpcoes<T>({
    required String titulo,
    required List<({T value, String label})> opcoes,
    T? atual,
  }) {
    if (opcoes.isEmpty) {
      AppSnackBar.show(context: context, message: 'Nenhuma opção disponível para $titulo.');
      return Future.value(null);
    }
    return abrirOpcoesFinanceiro<T>(
      context: context,
      titulo: titulo,
      opcoes: opcoes,
      atual: atual,
    );
  }

  Widget _campoEscolha({
    required String valor,
    required String placeholder,
    required bool habilitado,
    required VoidCallback? onTap,
  }) {
    final vazio = valor.isEmpty;
    return Material(
      color: habilitado ? Colors.white : const Color(0xFFF3F3F3),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: habilitado ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE6E6E6)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  vazio ? placeholder : valor,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: vazio ? FontWeight.w500 : FontWeight.w600,
                    color: !habilitado || vazio ? const Color(0xFF8A8A8A) : const Color(0xFF313131),
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: habilitado ? MyColors.colorPrimary : const Color(0xFFB0B0B0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    if (_salvando) return;
    final erro = _validarAntesSalvar();
    if (erro != null) {
      AppSnackBar.show(context: context, message: erro);
      return;
    }
    try {
      final animais = <Map<String, dynamic>>[];
      if (_modo == _ModoEntrada.existente) {
        for (final item in _existentes) {
          animais.add({
            'app_animais_id': item.animal.id,
            'peso_entrada_kg': _peso6(item.peso.text),
          });
        }
      } else {
        final preenchidos = _novos.where((n) => n.brinco.text.trim().isNotEmpty).toList();
        if (preenchidos.isEmpty) {
          AppSnackBar.show(context: context, message: 'Informe ao menos 1 animal novo.');
          return;
        }
        for (final item in preenchidos) {
          if (item.categoriaId == null || item.faseId == null) {
            AppSnackBar.show(context: context, message: 'Categoria e fase são obrigatórias.');
            return;
          }
          animais.add({
            'brinco': item.brinco.text.trim(),
            'categoria_animal_id': item.categoriaId,
            'fase_animal_id': item.faseId,
            'sexo': item.sexo,
            'peso_entrada_kg': _peso6(item.peso.text),
          });
        }
      }
      setState(() => _salvando = true);
      await FinanceiroEscopo.of(context).adicionarEntradaParceria(
        parceriaId: widget.parceriaId,
        data: _data.text.trim(),
        animais: animais,
      );
      if (!mounted) return;
      AppSnackBar.show(context: context, message: 'Entrada registrada.', isError: false);
      widget.aoSalvo();
    } on ApiException catch (error) {
      if (!mounted) return;
      final msg = error.message;
      final patrimonio = msg.toLowerCase().contains('patrimônio') ||
          msg.toLowerCase().contains('patrimonio') ||
          msg.toLowerCase().contains('vinculado');
      AppSnackBar.show(
        context: context,
        message: patrimonio
            ? '$msg Use “Novo” para animal do investidor, ou escolha animal livre (sem contrato e sem capital próprio).'
            : msg,
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = kIsWeb ? 24.0 : 16.0;
    return Scaffold(
      backgroundColor: kIsWeb ? Colors.white : fundoFinanceiro,
      appBar: kIsWeb
          ? null
          : AppBar(
              backgroundColor: MyColors.colorPrimary,
              foregroundColor: Colors.white,
              title: const Text(
                'Registrar entrada',
                style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
              ),
              leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.aoVoltar),
            ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              primary: false,
              padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 16),
              children: [
                _cabecalhoFormulario(),
                const SizedBox(height: 16),
                if (_modo == _ModoEntrada.existente) ..._blocoExistente() else ..._blocoNovo(),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: kIsWeb ? Colors.white : fundoFinanceiro,
              border: const Border(top: BorderSide(color: Color(0xFFE8E8E8))),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, kIsWeb ? 16 : 12),
                child: BotaoPrimarioFinanceiro(
                  rotulo: 'Salvar entrada',
                  carregando: _salvando,
                  onPressed: _salvar,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cabecalhoFormulario() {
    final dataCampo = CampoFinanceiro(
      rotulo: 'DATA',
      child: TextField(
        controller: _data,
        keyboardType: TextInputType.number,
        inputFormatters: [_maskData],
        decoration: decoracaoCampo('dd/mm/aaaa'),
      ),
    );
    final origem = CampoFinanceiro(
      rotulo: 'ORIGEM',
      child: GrupoChips(
        opcoes: const ['Existente', 'Novo'],
        selecionado: _modo == _ModoEntrada.existente ? 'Existente' : 'Novo',
        aoEscolher: (v) => setState(() {
          _modo = v == 'Existente' ? _ModoEntrada.existente : _ModoEntrada.novo;
        }),
      ),
    );

    if (!kIsWeb) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dataCampo,
          const SizedBox(height: 14),
          origem,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 168, child: dataCampo),
            const SizedBox(width: 20),
            Expanded(child: origem),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _modo == _ModoEntrada.existente
              ? 'Vincule animais livres do rebanho a este contrato.'
              : 'Cadastre animais novos do investidor neste contrato.',
          style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
        ),
      ],
    );
  }

  List<Widget> _blocoExistente() {
    return [
      _cardSelecaoAnimais(),
      if (_existentes.isNotEmpty) ...[
        const SizedBox(height: 14),
        Row(
          children: [
            const Text(
              'Animais selecionados',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Text(
              '${_existentes.length}',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: MyColors.colorPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final item in _existentes) ...[
          _linhaAnimalExistente(item),
          const SizedBox(height: 6),
        ],
      ],
    ];
  }

  Widget _cardSelecaoAnimais() {
    final vazio = _existentes.isEmpty;
    return Material(
      color: const Color(0xFFF7FAF8),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: _escolherExistentes,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: MyColors.colorPrimary.withValues(alpha: 0.35),
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: MyColors.colorPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.pets_outlined, color: MyColors.colorPrimary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vazio
                          ? 'Selecionar animais'
                          : '${_existentes.length} ${_existentes.length == 1 ? 'animal' : 'animais'} · alterar seleção',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: MyColors.colorPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Só entram livres do rebanho (sem contrato e sem patrimônio próprio).',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: MyColors.colorPrimary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _linhaAnimalExistente(_AnimalExistenteLinha item) {
    final brinco = item.animal.brinco?.trim().isNotEmpty == true
        ? item.animal.brinco!.trim()
        : 'Animal #${item.animal.id}';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE6E6E6)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                brinco,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 110,
              child: TextField(
                controller: item.peso,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
                decoration: decoracaoCampo('Peso kg').copyWith(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  hintText: 'kg',
                ),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              onPressed: () => setState(() {
                item.dispose();
                _existentes.remove(item);
              }),
              icon: const Icon(Icons.close, size: 18, color: Color(0xFF8A8A8A)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _blocoNovo() {
    if (_carregandoListas && _categoriasPorSexo.isEmpty) {
      return [const LoadingFinanceiro(altura: 120, rotulo: 'Carregando categorias…')];
    }
    return [
      if (_erroCategorias != null) ...[
        CartaoBranco(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _erroCategorias!,
                style: const TextStyle(fontFamily: 'Montserrat', color: Color(0xFFC62828), fontSize: 13),
              ),
              TextButton(
                onPressed: _carregarListas,
                child: const Text('Tentar de novo', style: TextStyle(fontFamily: 'Montserrat')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
      Row(
        children: [
          const Text(
            'Novos animais',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            '${_novos.length}',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: MyColors.colorPrimary,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      for (var i = 0; i < _novos.length; i++) ...[
        Builder(
          builder: (context) {
            final linha = _novos[i];
            final categorias = _categoriasDoSexo(linha.sexo);
            final fases = _fases(linha.sexo, linha.categoriaId);
            final carregandoSexo = _pendenteSexo.containsKey(linha.sexo);
            return CartaoBranco(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Animal ${i + 1}',
                        style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      if (_novos.length > 1)
                        IconButton(
                          onPressed: () => setState(() {
                            _novos.removeAt(i).dispose();
                          }),
                          icon: const Icon(Icons.close, size: 18, color: Color(0xFF8A8A8A)),
                        ),
                    ],
                  ),
                  if (kIsWeb)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: CampoFinanceiro(
                            rotulo: 'BRINCO',
                            child: TextField(
                              controller: linha.brinco,
                              textCapitalization: TextCapitalization.characters,
                              decoration: decoracaoCampo('Ex.: ERG1010'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: CampoFinanceiro(
                            rotulo: 'PESO (KG)',
                            child: TextField(
                              controller: linha.peso,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                              decoration: decoracaoCampo('0,00'),
                            ),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    CampoFinanceiro(
                      rotulo: 'BRINCO',
                      child: TextField(
                        controller: linha.brinco,
                        textCapitalization: TextCapitalization.characters,
                        decoration: decoracaoCampo('Ex.: ERG1010'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CampoFinanceiro(
                      rotulo: 'PESO ENTRADA (KG)',
                      child: TextField(
                        controller: linha.peso,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                        decoration: decoracaoCampo('0,00'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  CampoFinanceiro(
                    rotulo: 'SEXO',
                    child: _campoEscolha(
                      valor: linha.sexo == 1 ? 'Macho' : 'Fêmea',
                      placeholder: 'Sexo',
                      habilitado: true,
                      onTap: () async {
                        final escolhido = await _abrirOpcoes<int>(
                          titulo: 'Sexo',
                          atual: linha.sexo,
                          opcoes: const [
                            (value: 1, label: 'Macho'),
                            (value: 2, label: 'Fêmea'),
                          ],
                        );
                        if (escolhido != null) await _aoMudarSexo(linha, escolhido);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (kIsWeb)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CampoFinanceiro(
                            rotulo: 'CATEGORIA',
                            child: carregandoSexo
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: LinearProgressIndicator(),
                                  )
                                : _campoEscolha(
                                    valor: categorias
                                            .where((c) => c.id == linha.categoriaId)
                                            .map((c) => c.nome)
                                            .firstOrNull ??
                                        '',
                                    placeholder: categorias.isEmpty ? 'Sem categorias' : 'Categoria',
                                    habilitado: categorias.isNotEmpty,
                                    onTap: () async {
                                      final escolhido = await _abrirOpcoes<int>(
                                        titulo: 'Categoria',
                                        atual: linha.categoriaId,
                                        opcoes: [
                                          for (final cat in categorias) (value: cat.id, label: cat.nome),
                                        ],
                                      );
                                      if (escolhido == null || !mounted) return;
                                      setState(() {
                                        linha.categoriaId = escolhido;
                                        linha.faseId = null;
                                      });
                                    },
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CampoFinanceiro(
                            rotulo: 'FASE',
                            child: _campoEscolha(
                              valor: fases.where((f) => f.id == linha.faseId).map((f) => f.nome).firstOrNull ?? '',
                              placeholder: linha.categoriaId == null
                                  ? 'Selecione a categoria'
                                  : (fases.isEmpty ? 'Sem fases' : 'Fase'),
                              habilitado: fases.isNotEmpty,
                              onTap: () async {
                                final escolhido = await _abrirOpcoes<int>(
                                  titulo: 'Fase',
                                  atual: linha.faseId,
                                  opcoes: [
                                    for (final fase in fases) (value: fase.id, label: fase.nome),
                                  ],
                                );
                                if (escolhido == null || !mounted) return;
                                setState(() => linha.faseId = escolhido);
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    CampoFinanceiro(
                      rotulo: 'CATEGORIA',
                      child: carregandoSexo
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: LinearProgressIndicator(),
                            )
                          : _campoEscolha(
                              valor: categorias
                                      .where((c) => c.id == linha.categoriaId)
                                      .map((c) => c.nome)
                                      .firstOrNull ??
                                  '',
                              placeholder: categorias.isEmpty ? 'Sem categorias' : 'Categoria',
                              habilitado: categorias.isNotEmpty,
                              onTap: () async {
                                final escolhido = await _abrirOpcoes<int>(
                                  titulo: 'Categoria',
                                  atual: linha.categoriaId,
                                  opcoes: [
                                    for (final cat in categorias) (value: cat.id, label: cat.nome),
                                  ],
                                );
                                if (escolhido == null || !mounted) return;
                                setState(() {
                                  linha.categoriaId = escolhido;
                                  linha.faseId = null;
                                });
                              },
                            ),
                    ),
                    if (!carregandoSexo && categorias.isEmpty) ...[
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: () => _garantirCategorias(linha.sexo),
                        child: const Text('Recarregar categorias', style: TextStyle(fontFamily: 'Montserrat', fontSize: 12)),
                      ),
                    ],
                    const SizedBox(height: 10),
                    CampoFinanceiro(
                      rotulo: 'FASE',
                      child: _campoEscolha(
                        valor: fases.where((f) => f.id == linha.faseId).map((f) => f.nome).firstOrNull ?? '',
                        placeholder: linha.categoriaId == null
                            ? 'Selecione a categoria'
                            : (fases.isEmpty ? 'Sem fases' : 'Fase'),
                        habilitado: fases.isNotEmpty,
                        onTap: () async {
                          final escolhido = await _abrirOpcoes<int>(
                            titulo: 'Fase',
                            atual: linha.faseId,
                            opcoes: [
                              for (final fase in fases) (value: fase.id, label: fase.nome),
                            ],
                          );
                          if (escolhido == null || !mounted) return;
                          setState(() => linha.faseId = escolhido);
                        },
                      ),
                    ),
                  ],
                  if (kIsWeb && !carregandoSexo && categorias.isEmpty) ...[
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => _garantirCategorias(linha.sexo),
                      child: const Text('Recarregar categorias', style: TextStyle(fontFamily: 'Montserrat', fontSize: 12)),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
      ],
      if (_novos.length < 100)
        TextButton.icon(
          onPressed: () => setState(() => _novos.add(_AnimalNovoLinha())),
          icon: const Icon(Icons.add),
          label: const Text('Adicionar outro animal', style: TextStyle(fontFamily: 'Montserrat')),
        ),
    ];
  }
}
