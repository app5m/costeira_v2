import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/form_accordion.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/input_formatters/brazilian_currency_input_formatter.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_filter_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_kind.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_upsert_entity.dart';
import 'package:costeira/features/cadastros/domain/usecases/create_parceiro_usecase.dart';
import 'package:costeira/features/cadastros/domain/usecases/get_parceiros_usecase.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/financeiro/domain/distribuicao_animais.dart';
import 'package:costeira/features/financeiro/domain/financeiro_catalogo.dart';
import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/pages/contas_page.dart';
import 'package:costeira/features/financeiro/presentation/pages/lancamento_animais_page.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class LancamentoFormPage extends StatefulWidget {
  const LancamentoFormPage({super.key, required this.aoFechar, this.item});

  final VoidCallback aoFechar;
  final LancamentoMock? item;

  @override
  State<LancamentoFormPage> createState() => _LancamentoFormPageState();
}

class _RateioCampo {
  _RateioCampo({this.centroId, this.nome = ''});

  int? centroId;
  String nome;
  final percentual = TextEditingController();
  final valor = TextEditingController();

  void dispose() {
    percentual.dispose();
    valor.dispose();
  }
}

class _AnimalVinculo {
  _AnimalVinculo(this.animal);

  final AnimalEntity animal;
  int? centroId;
  final valor = TextEditingController();

  void dispose() => valor.dispose();
}

class _LancamentoFormPageState extends State<LancamentoFormPage> {
  String? _tipo;
  int? _classificacaoId;
  int? _rubricaId;
  int? _centroId;
  int? _parteId;
  String? _aberto = 'tipo';
  bool _distribuir = false;
  bool _pago = false;
  int? _contaId;
  bool _salvando = false;
  bool _salvandoRascunho = false;
  final _competencia = TextEditingController();
  final _vencimento = TextEditingController();
  final _valor = TextEditingController(text: BrazilianCurrency.format(0));
  final _descricao = TextEditingController();
  final _quantidade = TextEditingController();
  final _unidade = TextEditingController();
  final _documento = TextEditingController();
  final List<_RateioCampo> _rateios = [];
  final List<_AnimalVinculo> _animais = [];
  bool _dividirIgual = true;
  int? _centroAnimais;
  late final MaskTextInputFormatter _mascaraCompetencia = mascaraData();
  late final MaskTextInputFormatter _mascaraVencimento = mascaraData();

  static const _estiloCampo = TextStyle(fontFamily: 'Montserrat', fontSize: 14, color: Color(0xFF313131));

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item == null) {
      _competencia.text = _hojeData();
      return;
    }
    _tipo = item.tipo == 'recebimento' ? 'Recebimento' : 'Pagamento';
    _classificacaoId = item.classificacaoId;
    _rubricaId = item.categoriaId;
    _competencia.text = item.competencia.isEmpty ? _hojeData() : item.competencia;
    _descricao.text = item.descricao;
    _valor.text = BrazilianCurrency.format(item.valor);
  }

  DateTime? _parseDataBr(String texto) {
    final m = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(texto.trim());
    if (m == null) return null;
    final dia = int.tryParse(m.group(1)!);
    final mes = int.tryParse(m.group(2)!);
    final ano = int.tryParse(m.group(3)!);
    if (dia == null || mes == null || ano == null) return null;
    if (mes < 1 || mes > 12 || dia < 1 || dia > 31) return null;
    final data = DateTime(ano, mes, dia);
    if (data.year != ano || data.month != mes || data.day != dia) return null;
    return data;
  }

  String? _erroCompetencia() {
    final texto = _competencia.text.trim();
    if (texto.isEmpty) return 'Informe a data de competência.';
    final data = _parseDataBr(texto);
    if (data == null) return 'Competência inválida. Use dd/MM/aaaa.';
    final hoje = DateTime.now();
    final fimHoje = DateTime(hoje.year, hoje.month, hoje.day);
    if (data.isAfter(fimHoje)) {
      return 'Competência não pode ser posterior à data atual.';
    }
    return null;
  }

  Future<void> _escolherCompetencia() async {
    final atual = _parseDataBr(_competencia.text) ?? DateTime.now();
    final hoje = DateTime.now();
    final fim = DateTime(hoje.year, hoje.month, hoje.day);
    final escolhida = await showDatePicker(
      context: context,
      initialDate: atual.isAfter(fim) ? fim : atual,
      firstDate: DateTime(hoje.year - 10),
      lastDate: fim,
      helpText: 'Competência',
      cancelText: 'Cancelar',
      confirmText: 'Ok',
    );
    if (escolhida == null || !mounted) return;
    final d = escolhida.day.toString().padLeft(2, '0');
    final m = escolhida.month.toString().padLeft(2, '0');
    setState(() => _competencia.text = '$d/$m/${escolhida.year}');
  }

  @override
  void dispose() {
    _competencia.dispose();
    _vencimento.dispose();
    _valor.dispose();
    _descricao.dispose();
    _quantidade.dispose();
    _unidade.dispose();
    _documento.dispose();
    for (final item in _rateios) {
      item.dispose();
    }
    for (final item in _animais) {
      item.dispose();
    }
    super.dispose();
  }

  void _alternar(String id) => setState(() => _aberto = _aberto == id ? null : id);

  String? get _tipoApi {
    if (_tipo == 'Recebimento') return 'recebimento';
    if (_tipo == 'Pagamento') return 'pagamento';
    return null;
  }

  double get _valorNumero => BrazilianCurrency.parse(_valor.text) ?? 0;

  void _limparRateios() {
    for (final item in _rateios) {
      item.dispose();
    }
    _rateios.clear();
  }

  void _adicionarRateio(FinanceiroLoja loja) {
    final usados = {for (final item in _rateios) if (item.centroId != null) item.centroId!};
    final livre = loja.centros.where((c) => !usados.contains(c.id)).toList();
    if (livre.isEmpty) {
      AppSnackBar.show(context: context, message: 'Todos os centros já foram adicionados.');
      return;
    }
    setState(() {
      _rateios.add(_RateioCampo(centroId: livre.first.id, nome: livre.first.nome));
    });
  }

  void _removerRateio(int index) {
    setState(() {
      _rateios.removeAt(index).dispose();
    });
  }

  double get _somaPercentualRateio {
    var soma = 0.0;
    for (final item in _rateios) {
      soma += double.tryParse(item.percentual.text.replaceAll(',', '.')) ?? 0;
    }
    return soma;
  }

  void _aoPercentual(_RateioCampo item, String texto) {
    final total = _valorNumero;
    final percentual = double.tryParse(texto.replaceAll(',', '.')) ?? 0;
    item.valor.text = BrazilianCurrency.format(total * percentual / 100);
    setState(() {});
  }

  void _aoValorRateio(_RateioCampo item, String texto) {
    final total = _valorNumero;
    final valor = BrazilianCurrency.parse(texto) ?? 0;
    item.percentual.text = total == 0 ? '0' : (valor / total * 100).toStringAsFixed(2);
    setState(() {});
  }

  int? _centroEfetivo(_AnimalVinculo item) {
    if (_distribuir) return item.centroId;
    return _centroId ?? _centroAnimais;
  }

  Map<int, int> _centavosPorCentro() {
    final mapa = <int, int>{};
    for (final item in _rateios) {
      final centro = item.centroId;
      final centavos = _centavosDe(item.valor.text);
      if (centro == null || centavos == null || centavos == 0) continue;
      mapa[centro] = (mapa[centro] ?? 0) + centavos;
    }
    return mapa;
  }

  List<int?> _centrosAnimais() => [for (final item in _animais) _centroEfetivo(item)];

  List<int?> _valoresAnimais() {
    if (_dividirIgual) {
      return DistribuicaoAnimais.centavosIguais(
        totalCentavos: (_valorNumero * 100).round(),
        centros: _centrosAnimais(),
        porCentro: _distribuir,
        totaisPorCentro: _centavosPorCentro(),
      );
    }
    return [for (final item in _animais) _centavosDe(item.valor.text)];
  }

  int? _centavosDe(String texto) {
    final numero = BrazilianCurrency.parse(texto);
    if (numero == null) return null;
    return (numero * 100).round();
  }

  String? _erroAnimais() {
    if (_animais.isEmpty) return null;
    return DistribuicaoAnimais.validar(
      totalCentavos: (_valorNumero * 100).round(),
      valores: _valoresAnimais(),
      centros: _centrosAnimais(),
      porCentro: _distribuir,
      totaisPorCentro: _centavosPorCentro(),
    );
  }

  Future<void> _escolherAnimais() async {
    final escolhidos = await Navigator.of(context).push<List<AnimalEntity>>(
      MaterialPageRoute(builder: (_) => LancamentoAnimaisPage(selecionados: [for (final item in _animais) item.animal])),
    );
    if (escolhidos == null || !mounted) return;
    final anteriores = {for (final item in _animais) item.animal.id: item};
    final proximos = <_AnimalVinculo>[];
    for (final animal in escolhidos) {
      final antigo = anteriores.remove(animal.id);
      proximos.add(antigo ?? _AnimalVinculo(animal));
    }
    for (final sobra in anteriores.values) {
      sobra.dispose();
    }
    setState(() {
      _animais
        ..clear()
        ..addAll(proximos);
    });
  }

  Future<void> _salvar({required bool rascunho}) async {
    final loja = FinanceiroEscopo.of(context);
    final classificacao = loja.classificacoes.where((c) => c.id == _classificacaoId).firstOrNull;
    if (_tipoApi == null || classificacao == null || _rubricaId == null) {
      AppSnackBar.show(context: context, message: 'Preencha classificação e rubrica.');
      return;
    }
    if (_descricao.text.trim().isEmpty) {
      setState(() => _aberto = 'dados');
      AppSnackBar.show(context: context, message: 'Informe a descrição.');
      return;
    }
    final erroCompetencia = _erroCompetencia();
    if (erroCompetencia != null) {
      setState(() => _aberto = 'dados');
      AppSnackBar.show(context: context, message: erroCompetencia);
      return;
    }
    final rateios = <Map<String, dynamic>>[];
    int? centroId = _centroId;
    if (_distribuir) {
      var soma = 0.0;
      for (final item in _rateios) {
        final percentual = double.tryParse(item.percentual.text.replaceAll(',', '.')) ?? 0;
        final valor = BrazilianCurrency.parse(item.valor.text) ?? 0;
        if (item.centroId == null || (percentual == 0 && valor == 0)) continue;
        soma += percentual;
        rateios.add({
          'centro_id': item.centroId,
          'percentual': percentual.toStringAsFixed(6),
          'valor': valor.toStringAsFixed(2),
        });
      }
      if (classificacao.exigeCentro && rateios.isEmpty) {
        AppSnackBar.show(context: context, message: 'Informe a alocação por centro.');
        return;
      }
      if (rateios.isNotEmpty && (soma - 100).abs() > 0.05) {
        AppSnackBar.show(context: context, message: 'A distribuição precisa fechar 100%.');
        return;
      }
      centroId = null;
    } else if (classificacao.exigeCentro && centroId == null) {
      AppSnackBar.show(context: context, message: 'Selecione o centro de custo.');
      return;
    }
    ContaMock? conta;
    for (final item in loja.contas) {
      if (item.id == _contaId) conta = item;
    }
    if (!rascunho && _pago) {
      if (conta == null) {
        AppSnackBar.show(context: context, message: 'Selecione a conta do pagamento.');
        return;
      }
      if (_tipoApi == 'pagamento' && conta.saldo + 0.001 < _valorNumero) {
        AppSnackBar.show(context: context, message: 'Saldo da conta insuficiente.');
        return;
      }
    }
    final erroAnimais = _erroAnimais();
    if (erroAnimais != null) {
      AppSnackBar.show(context: context, message: erroAnimais);
      return;
    }
    final valoresAnimais = _valoresAnimais();
    final animais = _animais.isEmpty
        ? null
        : [
            for (var i = 0; i < _animais.length; i++)
              {
                'app_animais_id': _animais[i].animal.id,
                'centro_id': _centroEfetivo(_animais[i]),
                'valor': ((valoresAnimais[i] ?? 0) / 100).toStringAsFixed(2),
              },
          ];
    if (_salvando || _salvandoRascunho) return;
    setState(() {
      _salvando = !rascunho;
      _salvandoRascunho = rascunho;
    });
    try {
      await loja.salvarLancamento(
        rascunho: rascunho,
        id: widget.item?.id,
        classificacaoId: classificacao.id,
        categoriaId: _rubricaId!,
        centroId: centroId,
        parteId: _parteId,
        competencia: _competencia.text.trim(),
        vencimento: _vencimento.text.trim().isEmpty ? null : _vencimento.text.trim(),
        descricao: _descricao.text.trim(),
        documento: _documento.text.trim().isEmpty ? null : _documento.text.trim(),
        valor: _valorNumero.toStringAsFixed(2),
        quantidade: _quantidade.text.trim().isEmpty ? null : _quantidade.text.trim(),
        unidade: _unidade.text.trim().isEmpty ? null : _unidade.text.trim(),
        rateios: rateios,
        animais: animais,
        pago: _pago,
        contaId: conta?.id,
        dataBaixa: _competencia.text.trim(),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      final msg = error.message;
      setState(() {
        _salvando = false;
        _salvandoRascunho = false;
        if (msg.toLowerCase().contains('competencia') || msg.toLowerCase().contains('competência')) {
          _aberto = 'dados';
        } else if (msg.toLowerCase().contains('percentual') || msg.toLowerCase().contains('centro')) {
          _aberto = 'alocacao';
        }
      });
      AppSnackBar.show(context: context, message: msg);
      return;
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _salvando = false;
        _salvandoRascunho = false;
      });
      AppSnackBar.show(context: context, message: error.toString());
      return;
    }
    if (!mounted) return;
    widget.aoFechar();
  }

  @override
  Widget build(BuildContext context) {
    final loja = FinanceiroEscopo.of(context);
    final manuais = loja.classificacoes.where((c) => c.manual && c.tipo == _tipoApi).toList();
    final rubricas = loja.rubricas.where((r) => r.classificacaoId == _classificacaoId).toList();
    final partes = loja.partes.toList();
    final contasAtivas = loja.contas.where((c) => c.ativa).toList();
    final classificacao = loja.classificacoes.where((c) => c.id == _classificacaoId).firstOrNull;
    final rubrica = rubricas.where((r) => r.id == _rubricaId).firstOrNull;
    final parteAtual = partes.where((p) => p.id == _parteId).firstOrNull;
    final ocupado = _salvando || _salvandoRascunho;
    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: Text(widget.item == null ? 'Novo lançamento' : 'Editar rascunho', style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 17)),
        leading: IconButton(onPressed: ocupado ? null : widget.aoFechar, icon: const Icon(Icons.arrow_back)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          if (loja.erro != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(loja.erro!, style: const TextStyle(fontFamily: 'Montserrat', color: Color(0xFFC62828), fontSize: 12)),
            ),
          _accordion(
            id: 'tipo',
            titulo: _tipo == null ? 'Classificação' : 'Classificação · $_tipo',
            completo: _tipo != null,
            child: Column(
              children: [
                for (final tipo in tiposLancamento)
                  OpcaoCartaoFinanceiro(
                    titulo: tipo.rotulo,
                    subtitulo: tipo.travado ? 'Em breve' : null,
                    icone: iconeTipoLancamento(tipo.id),
                    corAccent: corTipoLancamento(tipo.id),
                    selecionado: _tipo == tipo.rotulo,
                    travado: tipo.travado,
                    aoToque: tipo.travado
                        ? () => avisoDesenvolvimento(context)
                        : () => setState(() {
                            _tipo = tipo.rotulo;
                            _classificacaoId = null;
                            _rubricaId = null;
                            _aberto = 'categoria';
                          }),
                  ),
              ],
            ),
          ),
          _accordion(
            id: 'categoria',
            titulo: classificacao == null ? 'Categoria' : 'Categoria · ${classificacao.nome}',
            completo: _classificacaoId != null,
            child: Column(
              children: [
                if (_tipoApi == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Escolha a classificação primeiro.',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF8A8A8A)),
                    ),
                  )
                else if (manuais.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Nenhuma categoria disponível para este tipo.',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF8A8A8A)),
                    ),
                  )
                else
                  for (final item in manuais)
                    OpcaoCartaoFinanceiro(
                      titulo: item.nome,
                      subtitulo: item.exigeCentro ? 'Exige centro de custo' : null,
                      icone: iconePorTextoFinanceiro(item.nome),
                      selecionado: _classificacaoId == item.id,
                      aoToque: () {
                        setState(() {
                          _classificacaoId = item.id;
                          _rubricaId = null;
                          _distribuir = false;
                          _centroId = null;
                          _limparRateios();
                          _aberto = 'rubrica';
                        });
                      },
                    ),
              ],
            ),
          ),
          _accordion(
            id: 'rubrica',
            titulo: rubrica == null ? 'Rubrica' : 'Rubrica · ${rubrica.nome}',
            completo: _rubricaId != null,
            child: Column(
              children: [
                if (_classificacaoId == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Escolha a categoria primeiro.',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF8A8A8A)),
                    ),
                  )
                else if (rubricas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Nenhuma rubrica nesta categoria.',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF8A8A8A)),
                    ),
                  )
                else
                  for (final item in rubricas)
                    OpcaoCartaoFinanceiro(
                      titulo: item.nome,
                      icone: iconePorTextoFinanceiro(item.nome),
                      selecionado: _rubricaId == item.id,
                      aoToque: () => setState(() {
                        _rubricaId = item.id;
                        _aberto = 'dados';
                      }),
                    ),
              ],
            ),
          ),
          _accordion(
            id: 'dados',
            titulo: 'Dados do lançamento',
            completo: _descricao.text.trim().isNotEmpty && _erroCompetencia() == null,
            child: Column(
              children: [
                CampoFinanceiro(
                  rotulo: 'COMPETÊNCIA',
                  child: TextField(
                    controller: _competencia,
                    keyboardType: tecladoData,
                    inputFormatters: [_mascaraCompetencia],
                    decoration: decoracaoCampo('dd/MM/aaaa').copyWith(
                      suffixIcon: IconButton(
                        tooltip: 'Escolher data',
                        onPressed: _escolherCompetencia,
                        icon: const Icon(Icons.calendar_today_outlined, size: 18),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(height: 12),
                CampoFinanceiro(
                  rotulo: 'VENCIMENTO',
                  child: TextField(
                    controller: _vencimento,
                    keyboardType: tecladoData,
                    inputFormatters: [_mascaraVencimento],
                    decoration: decoracaoCampo('dd/MM/aaaa'),
                  ),
                ),
                const SizedBox(height: 12),
                CampoFinanceiro(
                  rotulo: 'VALOR',
                  child: TextField(
                    controller: _valor,
                    keyboardType: tecladoMoeda,
                    inputFormatters: const [mascaraMoeda],
                    decoration: decoracaoCampo(r'R$ 0,00'),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(height: 12),
                CampoFinanceiro(rotulo: 'DESCRIÇÃO', child: TextField(controller: _descricao, decoration: decoracaoCampo(''))),
                const SizedBox(height: 12),
                CampoFinanceiro(rotulo: 'DOCUMENTO', child: TextField(controller: _documento, decoration: decoracaoCampo('Opcional'))),
                const SizedBox(height: 12),
                CampoFinanceiro(
                  rotulo: 'QUANTIDADE',
                  child: TextField(
                    controller: _quantidade,
                    keyboardType: tecladoMoeda,
                    inputFormatters: [mascaraPercentual],
                    decoration: decoracaoCampo('Opcional'),
                  ),
                ),
                const SizedBox(height: 12),
                CampoFinanceiro(rotulo: 'UNIDADE', child: TextField(controller: _unidade, decoration: decoracaoCampo('Opcional'))),
              ],
            ),
          ),
          _accordion(
            id: 'parte',
            titulo: parteAtual == null ? 'Fornecedor ou comprador' : 'Parte · ${parteAtual.nome}',
            completo: _parteId != null ? true : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (partes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Nenhum fornecedor ou comprador vinculado. Cadastre um para este lançamento.',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF8A8A8A)),
                    ),
                  )
                else
                  for (final parte in partes)
                    OpcaoCartaoFinanceiro(
                      titulo: parte.nome,
                      subtitulo: parte.papel.isEmpty
                          ? null
                          : '${parte.papel[0].toUpperCase()}${parte.papel.substring(1)}',
                      icone: parte.papel.toLowerCase().contains('comprador')
                          ? Icons.storefront_outlined
                          : Icons.local_shipping_outlined,
                      selecionado: _parteId == parte.id,
                      aoToque: () => setState(() => _parteId = parte.id),
                    ),
                if (partes.isEmpty)
                  BotaoPrimarioFinanceiro(
                    rotulo: 'Cadastrar fornecedor ou comprador',
                    onPressed: () => _modalNovaParte(loja),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => _modalNovaParte(loja),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      side: const BorderSide(color: MyColors.colorPrimary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add, color: MyColors.colorPrimary, size: 18),
                    label: const Text(
                      'Adicionar outro',
                      style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, color: MyColors.colorPrimary),
                    ),
                  ),
              ],
            ),
          ),
          if (_classificacaoId != null)
            _accordion(
              id: 'alocacao',
              titulo: _distribuir ? 'Alocação · Distribuir' : 'Alocação · Um centro',
              completo: classificacao?.exigeCentro != true
                  ? null
                  : (_distribuir ? _somaPercentualRateio > 99.9 && _rateios.isNotEmpty : _centroId != null),
              child: _secaoAlocacao(loja),
            ),
          _secaoAnimais(loja),
          _accordion(
            id: 'pagamento',
            titulo: _pago ? 'Pagamento · Já foi pago' : 'Pagamento · Pendente',
            completo: !_pago || _contaId != null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Já foi pago?', style: TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
                  subtitle: Text(
                    _pago ? 'A baixa entra junto com o salvamento.' : 'Sem pagamento, ficará pendente.',
                    style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12),
                  ),
                  value: _pago,
                  activeThumbColor: MyColors.colorPrimary,
                  onChanged: (valor) => setState(() => _pago = valor),
                ),
                if (_pago) ...[
                  if (contasAtivas.isEmpty) ...[
                    const Text(
                      'Nenhuma conta ativa nesta fazenda.',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF8A8A8A)),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => _modalNovaConta(loja),
                      style: FilledButton.styleFrom(backgroundColor: MyColors.colorPrimary),
                      child: const Text('Adicionar conta', style: TextStyle(fontFamily: 'Montserrat')),
                    ),
                  ] else ...[
                    SeletorContaFinanceiro(
                      contas: contasAtivas,
                      selecionada: contasAtivas.where((c) => c.id == _contaId).firstOrNull,
                      onChanged: (conta) => setState(() => _contaId = conta.id),
                    ),
                    TextButton(
                      onPressed: () => _modalNovaConta(loja),
                      child: const Text('Adicionar outra conta', style: TextStyle(fontFamily: 'Montserrat')),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: RodapeAcoesFinanceiro(
        filhos: [
          BotaoPrimarioFinanceiro(
            rotulo: 'Salvar lançamento',
            carregando: _salvando,
            habilitado: !ocupado,
            onPressed: () => _salvar(rascunho: false),
          ),
        ],
      ),
    );
  }

  Widget _secaoAlocacao(FinanceiroLoja loja) {
    final somaPct = _somaPercentualRateio;
    final somaValor = _rateios.fold<double>(0, (total, item) => total + (BrazilianCurrency.parse(item.valor.text) ?? 0));
    final totalOk = (somaPct - 100).abs() < 0.05;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _modoAlocacao(
                rotulo: 'Um centro',
                ativo: !_distribuir,
                aoToque: () => setState(() {
                  _distribuir = false;
                  _limparRateios();
                }),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _modoAlocacao(
                rotulo: 'Distribuir',
                ativo: _distribuir,
                aoToque: () {
                  setState(() {
                    _distribuir = true;
                    _centroId = null;
                  });
                  if (_rateios.isEmpty) _adicionarRateio(loja);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!_distribuir)
          Column(
            children: [
              if (loja.centros.isEmpty)
                const Text(
                  'Nenhum centro de custo disponível.',
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF8A8A8A)),
                )
              else
                for (final centro in loja.centros)
                  OpcaoCartaoFinanceiro(
                    titulo: centro.nome,
                    icone: Icons.hub_outlined,
                    selecionado: _centroId == centro.id,
                    aoToque: () => setState(() => _centroId = centro.id),
                  ),
            ],
          )
        else ...[
          for (var i = 0; i < _rateios.length; i++) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7F3),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8E4DA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Centro ${i + 1}',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B6B6B),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        onPressed: () => _removerRateio(i),
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFC62828), size: 20),
                      ),
                    ],
                  ),
                  DropdownButtonFormField<int>(
                    key: ValueKey('rateio-${_rateios[i].hashCode}-${_rateios[i].centroId}'),
                    isExpanded: true,
                    initialValue: loja.centros.any((c) => c.id == _rateios[i].centroId) ? _rateios[i].centroId : null,
                    decoration: decoracaoCampo('Selecione o centro'),
                    items: [
                      for (final centro in loja.centros)
                        DropdownMenuItem(
                          value: centro.id,
                          child: Text(
                            centro.nome,
                            style: _estiloCampo,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (valor) {
                      final nome = loja.centros.where((c) => c.id == valor).firstOrNull?.nome ?? '';
                      setState(() {
                        _rateios[i].centroId = valor;
                        _rateios[i].nome = nome;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CampoFinanceiro(
                          rotulo: '%',
                          child: TextField(
                            controller: _rateios[i].percentual,
                            decoration: decoracaoCampo('0'),
                            keyboardType: tecladoMoeda,
                            inputFormatters: [mascaraPercentual],
                            onChanged: (texto) => _aoPercentual(_rateios[i], texto),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: CampoFinanceiro(
                          rotulo: 'VALOR',
                          child: TextField(
                            controller: _rateios[i].valor,
                            decoration: decoracaoCampo(r'R$ 0,00'),
                            keyboardType: tecladoMoeda,
                            inputFormatters: const [mascaraMoeda],
                            onChanged: (texto) => _aoValorRateio(_rateios[i], texto),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          TextButton.icon(
            onPressed: () => _adicionarRateio(loja),
            icon: const Icon(Icons.add, color: MyColors.colorPrimary),
            label: const Text('Adicionar centro', style: TextStyle(fontFamily: 'Montserrat', color: MyColors.colorPrimary)),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: totalOk ? const Color(0xFFE7F6EC) : const Color(0xFFFDECEC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Total ${somaPct.toStringAsFixed(0)}% · ${reais(somaValor)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: totalOk ? MyColors.colorPrimary : const Color(0xFFC62828),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _modoAlocacao({required String rotulo, required bool ativo, required VoidCallback aoToque}) {
    return Material(
      color: ativo ? MyColors.colorPrimary : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: aoToque,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MyColors.colorPrimary),
          ),
          child: Text(
            rotulo,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              color: ativo ? Colors.white : MyColors.colorPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _modalNovaParte(FinanceiroLoja loja) async {
    final nome = TextEditingController();
    final celular = TextEditingController();
    final motivo = TextEditingController(text: 'Vinculação no lançamento');
    var papel = _tipoApi == 'recebimento' ? 'comprador' : 'fornecedor';
    var modoNovo = true;
    int? existenteId;
    var carregando = true;
    var salvando = false;
    var iniciouCarga = false;
    var parceiros = <ParceiroEntity>[];
    String? erroLista;
    String? erroSalvar;

    Future<void> carregarCadastro(void Function(VoidCallback) setSheet) async {
      setSheet(() {
        carregando = true;
        erroLista = null;
        erroSalvar = null;
        existenteId = null;
      });
      try {
        final user = await SessionStorage.getUserSession();
        if (user == null) throw ApiException('Usuário não autenticado.');
        final farmId = await Modular.get<ResolveCurrentFarmId>()(userId: user.id);
        if (farmId == null) throw ApiException('Selecione uma fazenda.');
        final kind = papel == 'comprador' ? ParceiroKind.comprador : ParceiroKind.fornecedor;
        final lista = await Modular.get<GetParceirosUsecase>()(
          ParceiroFilterEntity(kind: kind, appUsersId: user.id, appFazendasId: farmId),
        );
        setSheet(() {
          parceiros = lista.data;
          carregando = false;
          if (parceiros.isEmpty) modoNovo = true;
        });
      } catch (error) {
        setSheet(() {
          carregando = false;
          erroLista = error is ApiException ? error.message : error.toString();
          modoNovo = true;
        });
      }
    }

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) {
        return StatefulBuilder(
          builder: (sheet, setSheet) {
            if (!iniciouCarga) {
              iniciouCarga = true;
              WidgetsBinding.instance.addPostFrameCallback((_) => carregarCadastro(setSheet));
            }
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.of(sheet).viewInsets.bottom),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Fornecedor ou comprador', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 16),
                    if (erroSalvar != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDECEC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFC62828).withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFC62828), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                erroSalvar!,
                                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFFC62828), fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SecaoRotulo('PAPEL'),
                    const SizedBox(height: 6),
                    GrupoChips(
                      opcoes: const ['Fornecedor', 'Comprador'],
                      selecionado: papel == 'comprador' ? 'Comprador' : 'Fornecedor',
                      aoEscolher: (valor) {
                        setSheet(() {
                          papel = valor == 'Comprador' ? 'comprador' : 'fornecedor';
                          erroSalvar = null;
                        });
                        carregarCadastro(setSheet);
                      },
                    ),
                    const SizedBox(height: 12),
                    const SecaoRotulo('ORIGEM'),
                    const SizedBox(height: 6),
                    GrupoChips(
                      opcoes: const ['Cadastrar novo', 'Já cadastrado'],
                      selecionado: modoNovo ? 'Cadastrar novo' : 'Já cadastrado',
                      aoEscolher: (valor) => setSheet(() {
                        modoNovo = valor == 'Cadastrar novo';
                        existenteId = null;
                        erroSalvar = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    if (carregando)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (!modoNovo) ...[
                      if (erroLista != null)
                        Text(erroLista!, style: const TextStyle(fontFamily: 'Montserrat', color: Color(0xFFC62828), fontSize: 12))
                      else if (parceiros.isEmpty)
                        const Text(
                          'Nenhum cadastro nesse papel. Use Cadastrar novo.',
                          style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF8A8A8A)),
                        )
                      else
                        DropdownButtonFormField<int>(
                          key: ValueKey('$papel-${parceiros.length}'),
                          initialValue: existenteId,
                          decoration: decoracaoCampo('Selecione no cadastro'),
                          items: [
                            for (final item in parceiros)
                              DropdownMenuItem(value: item.id, child: Text(item.nome, style: _estiloCampo)),
                          ],
                          onChanged: (valor) => setSheet(() {
                            existenteId = valor;
                            erroSalvar = null;
                          }),
                        ),
                    ] else ...[
                      CampoFinanceiro(
                        rotulo: 'NOME',
                        child: TextField(
                          controller: nome,
                          decoration: decoracaoCampo('Nome'),
                          onChanged: (_) => setSheet(() => erroSalvar = null),
                        ),
                      ),
                      const SizedBox(height: 12),
                      CampoFinanceiro(
                        rotulo: 'CELULAR (OPCIONAL)',
                        child: TextField(
                          controller: celular,
                          keyboardType: TextInputType.phone,
                          decoration: decoracaoCampo('(00) 00000-0000'),
                          onChanged: (_) => setSheet(() => erroSalvar = null),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    CampoFinanceiro(rotulo: 'MOTIVO', child: TextField(controller: motivo, decoration: decoracaoCampo(''))),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: salvando
                          ? null
                          : () async {
                              if (modoNovo && nome.text.trim().isEmpty) {
                                setSheet(() => erroSalvar = 'Informe o nome.');
                                return;
                              }
                              if (!modoNovo && existenteId == null) {
                                setSheet(() => erroSalvar = 'Selecione um cadastro.');
                                return;
                              }
                              setSheet(() {
                                salvando = true;
                                erroSalvar = null;
                              });
                              try {
                                final user = await SessionStorage.getUserSession();
                                if (user == null) throw ApiException('Usuário não autenticado.');
                                final farmId = await Modular.get<ResolveCurrentFarmId>()(userId: user.id);
                                if (farmId == null) throw ApiException('Selecione uma fazenda.');
                                var cadastroId = existenteId;
                                if (modoNovo) {
                                  final kind = papel == 'comprador' ? ParceiroKind.comprador : ParceiroKind.fornecedor;
                                  final criado = await Modular.get<CreateParceiroUsecase>()(
                                    ParceiroUpsertEntity(
                                      kind: kind,
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
                                  if (!criado.isSuccess) {
                                    throw ApiException(criado.message);
                                  }
                                  cadastroId = criado.resourceId;
                                  if (cadastroId == null || cadastroId <= 0) {
                                    final lista = await Modular.get<GetParceirosUsecase>()(
                                      ParceiroFilterEntity(
                                        kind: kind,
                                        appUsersId: user.id,
                                        appFazendasId: farmId,
                                        nome: nome.text.trim(),
                                      ),
                                    );
                                    cadastroId = lista.data.where((p) => p.nome.trim().toLowerCase() == nome.text.trim().toLowerCase()).firstOrNull?.id;
                                  }
                                  if (cadastroId == null || cadastroId <= 0) {
                                    throw ApiException('Cadastro criado, mas o id não voltou. Abra de novo e use Já cadastrado.');
                                  }
                                }
                                final parteId = await loja.vincularParte(
                                  papel: papel,
                                  fornecedorId: papel == 'fornecedor' ? cadastroId : null,
                                  compradorId: papel == 'comprador' ? cadastroId : null,
                                  motivo: motivo.text.trim().isEmpty ? 'Vinculação no lançamento' : motivo.text.trim(),
                                );
                                if (!sheet.mounted) return;
                                Navigator.pop(sheet, true);
                                if (!mounted) return;
                                setState(() => _parteId = parteId);
                                AppSnackBar.show(context: context, message: 'Parte vinculada.', isError: false);
                              } on ApiException catch (error) {
                                setSheet(() {
                                  salvando = false;
                                  erroSalvar = error.message;
                                });
                              } catch (error) {
                                setSheet(() {
                                  salvando = false;
                                  erroSalvar = error.toString();
                                });
                              }
                            },
                      style: FilledButton.styleFrom(backgroundColor: MyColors.colorPrimary, minimumSize: const Size.fromHeight(48)),
                      child: Text(salvando ? 'Salvando...' : 'Salvar', style: const TextStyle(fontFamily: 'Montserrat')),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    nome.dispose();
    celular.dispose();
    motivo.dispose();
    if (ok != true) return;
  }

  Future<void> _modalNovaConta(FinanceiroLoja loja) async {
    final nome = TextEditingController();
    final motivo = TextEditingController(text: 'Conta criada no lançamento');
    final dataSaldo = TextEditingController(text: _hojeData());
    final valorSaldo = TextEditingController(text: BrazilianCurrency.format(0));
    final docSaldo = TextEditingController();
    final motivoSaldo = TextEditingController(text: 'Saldo conferido no início do controle');
    final mascaraDataSaldo = mascaraData();
    var tipo = 'Banco';
    var etapa = 0;
    var salvando = false;
    var positivo = true;
    ContaMock? criada;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) {
        return StatefulBuilder(
          builder: (sheet, setSheet) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(sheet).viewInsets.bottom),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      etapa == 0 ? 'Adicionar conta' : (etapa == 1 ? 'Conta criada' : 'Saldo inicial'),
                      style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    if (etapa == 0) ...[
                      CampoFinanceiro(rotulo: 'NOME', child: TextField(controller: nome, decoration: decoracaoCampo('Banco principal'))),
                      const SizedBox(height: 12),
                      const SecaoRotulo('TIPO'),
                      const SizedBox(height: 6),
                      GrupoChips(
                        opcoes: const ['Caixa', 'Banco'],
                        selecionado: tipo,
                        aoEscolher: (valor) => setSheet(() => tipo = valor),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Escolha um nome para identificar onde o dinheiro entra e sai.',
                        style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
                      ),
                      const SizedBox(height: 12),
                      CampoFinanceiro(rotulo: 'MOTIVO', child: TextField(controller: motivo, decoration: decoracaoCampo(''))),
                      const SizedBox(height: 16),
                      BotaoPrimarioFinanceiro(
                        rotulo: 'Salvar conta',
                        carregando: salvando,
                        onPressed: () async {
                          if (nome.text.trim().isEmpty) return;
                          setSheet(() => salvando = true);
                          try {
                            final id = await loja.salvarConta(
                              nome: nome.text.trim(),
                              tipo: tipo,
                              motivo: motivo.text.trim().isEmpty ? 'Conta criada no lançamento' : motivo.text.trim(),
                            );
                            final conta = loja.contas.where((c) => c.id == id).firstOrNull ??
                                loja.contas.where((c) => c.nome == nome.text.trim()).firstOrNull;
                            if (conta == null) throw ApiException('Conta criada, mas não voltou na lista.');
                            setSheet(() {
                              criada = conta;
                              etapa = 1;
                              salvando = false;
                            });
                          } on ApiException catch (error) {
                            setSheet(() => salvando = false);
                            if (!sheet.mounted) return;
                            AppSnackBar.show(context: sheet, message: error.message);
                          }
                        },
                      ),
                    ] else if (etapa == 1 && criada != null) ...[
                      ContaPosCriacao(
                        nome: criada!.nome,
                        aoInformarSaldo: () => setSheet(() => etapa = 2),
                        aoSaldoZero: () => Navigator.pop(sheet, true),
                      ),
                    ] else if (criada != null) ...[
                      CampoFinanceiro(
                        rotulo: 'DATA DE ABERTURA',
                        child: TextField(
                          controller: dataSaldo,
                          keyboardType: tecladoData,
                          inputFormatters: [mascaraDataSaldo],
                          decoration: decoracaoCampo('dd/MM/aaaa'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const SecaoRotulo('SITUAÇÃO DO SALDO'),
                      const SizedBox(height: 6),
                      GrupoChips(
                        opcoes: const ['Positivo', 'Negativo'],
                        selecionado: positivo ? 'Positivo' : 'Negativo',
                        aoEscolher: (valor) => setSheet(() => positivo = valor == 'Positivo'),
                      ),
                      const SizedBox(height: 12),
                      CampoFinanceiro(
                        rotulo: 'VALOR',
                        child: TextField(
                          controller: valorSaldo,
                          keyboardType: tecladoMoeda,
                          inputFormatters: const [mascaraMoeda],
                          decoration: decoracaoCampo(r'R$ 0,00'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      CampoFinanceiro(rotulo: 'DOCUMENTO (OPCIONAL)', child: TextField(controller: docSaldo, decoration: decoracaoCampo(''))),
                      const SizedBox(height: 12),
                      CampoFinanceiro(rotulo: 'MOTIVO', child: TextField(controller: motivoSaldo, decoration: decoracaoCampo(''))),
                      const SizedBox(height: 16),
                      BotaoPrimarioFinanceiro(
                        rotulo: 'Registrar saldo inicial',
                        carregando: salvando,
                        onPressed: () async {
                          setSheet(() => salvando = true);
                          try {
                            await loja.registrarSaldoInicial(
                              contaId: criada!.id,
                              data: dataSaldo.text.trim(),
                              positivo: positivo,
                              valor: (BrazilianCurrency.parse(valorSaldo.text) ?? 0).toStringAsFixed(2),
                              documento: docSaldo.text.trim().isEmpty ? null : docSaldo.text.trim(),
                              motivo: motivoSaldo.text.trim().isEmpty ? 'Saldo inicial' : motivoSaldo.text.trim(),
                            );
                            if (!sheet.mounted) return;
                            Navigator.pop(sheet, true);
                          } on ApiException catch (error) {
                            setSheet(() => salvando = false);
                            if (!sheet.mounted) return;
                            AppSnackBar.show(context: sheet, message: error.message);
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    final contaId = criada?.id;
    nome.dispose();
    motivo.dispose();
    dataSaldo.dispose();
    valorSaldo.dispose();
    docSaldo.dispose();
    motivoSaldo.dispose();
    if (ok != true || !mounted || contaId == null) return;
    setState(() => _contaId = contaId);
    AppSnackBar.show(context: context, message: 'Conta pronta para o pagamento.', isError: false);
  }

  String _hojeData() {
    final agora = DateTime.now();
    final d = agora.day.toString().padLeft(2, '0');
    final m = agora.month.toString().padLeft(2, '0');
    return '$d/$m/${agora.year}';
  }

  Widget _secaoAnimais(FinanceiroLoja loja) {
    final valores = _animais.isEmpty ? const <int?>[] : _valoresAnimais();
    final soma = valores.fold<int>(0, (total, valor) => total + (valor ?? 0));
    final erro = _animais.isEmpty ? null : _erroAnimais();
    final centrosRateio = [
      for (final item in _rateios)
        if (item.centroId != null && (_centavosDe(item.valor.text) ?? 0) > 0) item,
    ];
    return _accordion(
      id: 'animais',
      titulo: _animais.isEmpty ? 'Vincular animais — opcional' : 'Animais vinculados · ${_animais.length}',
      completo: _animais.isEmpty ? null : erro == null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Identifique os animais relacionados a este lançamento.',
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
          ),
          if (_animais.isEmpty) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _escolherAnimais,
              child: const Text('Selecionar animais', style: TextStyle(fontFamily: 'Montserrat')),
            ),
          ] else ...[
            RadioListTile<bool>(
              contentPadding: EdgeInsets.zero,
              value: true,
              groupValue: _dividirIgual,
              activeColor: MyColors.colorPrimary,
              title: const Text('Dividir igualmente', style: TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
              onChanged: (valor) => setState(() => _dividirIgual = valor ?? true),
            ),
            RadioListTile<bool>(
              contentPadding: EdgeInsets.zero,
              value: false,
              groupValue: _dividirIgual,
              activeColor: MyColors.colorPrimary,
              title: const Text('Informar valor por animal', style: TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
              onChanged: (valor) => setState(() => _dividirIgual = valor ?? false),
            ),
            if (!_distribuir && _centroId == null) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                key: ValueKey(_centroAnimais),
                initialValue: _centroAnimais,
                decoration: decoracaoCampo('Centro dos animais'),
                items: [
                  for (final centro in loja.centros)
                    DropdownMenuItem(value: centro.id, child: Text(centro.nome, style: _estiloCampo)),
                ],
                onChanged: (valor) => setState(() => _centroAnimais = valor),
              ),
            ],
            const SizedBox(height: 8),
            for (var i = 0; i < _animais.length; i++) ...[
              Text(_linhaAnimal(_animais[i].animal), style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 13)),
              if (_distribuir)
                DropdownButtonFormField<int>(
                  key: ValueKey('${_animais[i].animal.id}-${_animais[i].centroId}'),
                  initialValue: centrosRateio.any((item) => item.centroId == _animais[i].centroId) ? _animais[i].centroId : null,
                  decoration: decoracaoCampo('Centro'),
                  items: [
                    for (final centro in centrosRateio)
                      DropdownMenuItem(value: centro.centroId!, child: Text(centro.nome, style: _estiloCampo)),
                  ],
                  onChanged: (valor) => setState(() => _animais[i].centroId = valor),
                ),
              if (_dividirIgual)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    valores[i] == null ? '—' : reais(valores[i]! / 100),
                    style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
                  ),
                )
              else
                TextField(
                  controller: _animais[i].valor,
                  keyboardType: tecladoMoeda,
                  inputFormatters: const [mascaraMoeda],
                  decoration: decoracaoCampo(r'R$ 0,00'),
                  onChanged: (_) => setState(() {}),
                ),
              const SizedBox(height: 8),
            ],
            Text('Total atribuído  ${reais(soma / 100)}', style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700)),
            Text('Valor do lançamento  ${reais(_valorNumero)}', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A))),
            if (erro != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(erro, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFFC62828))),
              ),
            TextButton(onPressed: _escolherAnimais, child: const Text('Alterar animais')),
          ],
        ],
      ),
    );
  }

  String _linhaAnimal(AnimalEntity animal) {
    final brinco = animal.brinco?.trim();
    final categoria = animal.categoria?.nome.trim() ?? '';
    final fase = animal.subcategoria?.nome.trim() ?? '';
    final categoriaFase = [categoria, fase].where((parte) => parte.isNotEmpty).join(' / ');
    return [if (brinco != null && brinco.isNotEmpty) brinco else 'Sem brinco', categoriaFase].where((parte) => parte.isNotEmpty).join(' · ');
  }

  Widget _accordion({
    required String id,
    required String titulo,
    required bool? completo,
    required Widget child,
  }) {
    return FormAccordion(
      title: titulo,
      expanded: _aberto == id,
      onToggle: () => _alternar(id),
      complete: completo,
      child: child,
    );
  }

}
