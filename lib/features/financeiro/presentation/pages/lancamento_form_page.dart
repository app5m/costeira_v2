import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/form_accordion.dart';
import 'package:costeira/features/financeiro/domain/financeiro_catalogo.dart';
import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LancamentoFormPage extends StatefulWidget {
  const LancamentoFormPage({super.key, required this.aoFechar});

  final VoidCallback aoFechar;

  @override
  State<LancamentoFormPage> createState() => _LancamentoFormPageState();
}

class _LancamentoFormPageState extends State<LancamentoFormPage> {
  String? _tipo;
  String? _categoria;
  String? _rubrica;
  String? _categoriaAnimal;
  String? _fase;
  String? _status;
  String? _aberto = 'tipo';
  final _data = TextEditingController(text: '21/10/2026');
  final _valor = TextEditingController(text: '0,00');
  final _descricao = TextEditingController();
  final _quantidade = TextEditingController(text: '0');
  final _unidade = TextEditingController();
  String? _fornecedor;
  String? _comprador;

  @override
  void dispose() {
    _data.dispose();
    _valor.dispose();
    _descricao.dispose();
    _quantidade.dispose();
    _unidade.dispose();
    super.dispose();
  }

  void _alternar(String id) => setState(() => _aberto = _aberto == id ? null : id);

  List<String> get _categorias =>
      _tipo == null ? const [] : categoriasDoTipo(_tipo!);

  List<String> get _rubricas => _tipo == null || _categoria == null
      ? const []
      : rubricasDaCategoria(_tipo!, _categoria!);

  bool get _rebanho =>
      _tipo != null &&
      _categoria != null &&
      categoriaPedeRebanho(_tipo!, _categoria!);

  bool get _classificado {
    if (_tipo == null || _categoria == null) return false;
    if (_rubricas.isNotEmpty && _rubrica == null) return false;
    if (_rebanho &&
        (_categoriaAnimal == null || _fase == null || _status == null)) {
      return false;
    }
    return true;
  }

  void _escolherTipo(String id) {
    final opcao = tiposLancamento.firstWhere((t) => t.id == id);
    if (opcao.travado) {
      avisoDesenvolvimento(context);
      return;
    }
    setState(() {
      _tipo = id;
      _categoria = null;
      _rubrica = null;
      _categoriaAnimal = null;
      _fase = null;
      _status = null;
      _aberto = 'categoria';
    });
  }

  double? _lerValor() {
    final limpo = _valor.text.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(limpo);
  }

  void _salvar({required bool rascunho}) {
    final valor = _lerValor();
    if (!_classificado || _descricao.text.trim().isEmpty || valor == null) {
      AppSnackBar.show(
        context: context,
        message: 'Classifique o lançamento e preencha descrição e valor.',
      );
      return;
    }
    final loja = FinanceiroEscopo.of(context);
    loja.adicionar(
      loja.novo(
        titulo: _descricao.text.trim(),
        tipo: _tipo!,
        categoria: _categoria!,
        rubrica: _rubrica ?? '',
        valor: valor,
        descricao: _descricao.text.trim(),
        fornecedor: _fornecedor,
        comprador: _comprador,
        rascunho: rascunho,
      ),
    );
    AppSnackBar.show(
      context: context,
      message: rascunho ? 'Rascunho salvo.' : 'Lançamento salvo.',
      isError: false,
    );
    widget.aoFechar();
  }

  @override
  Widget build(BuildContext context) {
    final tipoRotulo = _tipo == null
        ? null
        : tiposLancamento.firstWhere((t) => t.id == _tipo).rotulo;
    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: const Text(
          'Novo lançamento',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.aoFechar,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _accordion(
            id: 'tipo',
            titulo: _titulo('Tipo', tipoRotulo),
            completo: _tipo != null,
            child: Column(
              children: [
                for (final tipo in tiposLancamento)
                  _opcao(
                    tipo.rotulo,
                    _tipo == tipo.id,
                    () => _escolherTipo(tipo.id),
                  ),
              ],
            ),
          ),
          if (_tipo != null)
            _accordion(
              id: 'categoria',
              titulo: _titulo('Categoria', _categoria),
              completo: _categoria != null,
              child: Column(
                children: [
                  for (final item in _categorias)
                    _opcao(item, _categoria == item, () {
                      setState(() {
                        _categoria = item;
                        _rubrica = null;
                        _categoriaAnimal = null;
                        _fase = null;
                        _status = null;
                        _aberto = _rubricas.isEmpty
                            ? 'dados'
                            : 'rubrica';
                      });
                    }),
                ],
              ),
            ),
          if (_categoria != null && _rubricas.isNotEmpty)
            _accordion(
              id: 'rubrica',
              titulo: _titulo('Rubrica', _rubrica),
              completo: _rubrica != null,
              child: Column(
                children: [
                  for (final item in _rubricas)
                    _opcao(item, _rubrica == item, () {
                      setState(() {
                        _rubrica = item;
                        _aberto = _rebanho ? 'animal' : 'dados';
                      });
                    }),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => AppSnackBar.show(
                        context: context,
                        message: 'Nomenclaturas em desenvolvimento.',
                        isError: false,
                      ),
                      child: const Text(
                        '+ Adicionar rubrica nova em Nomenclaturas',
                        style: TextStyle(fontFamily: 'Montserrat', fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_rebanho && _rubrica != null) ...[
            _accordion(
              id: 'animal',
              titulo: _titulo('Categoria do animal', _categoriaAnimal),
              completo: _categoriaAnimal != null,
              child: Column(
                children: [
                  for (final item in categoriasAnimal)
                    _opcao(item, _categoriaAnimal == item, () {
                      setState(() {
                        _categoriaAnimal = item;
                        _aberto = 'fase';
                      });
                    }),
                ],
              ),
            ),
            if (_categoriaAnimal != null)
              _accordion(
                id: 'fase',
                titulo: _titulo('Fase', _fase),
                completo: _fase != null,
                child: Column(
                  children: [
                    for (final item in fasesAnimal)
                      _opcao(item, _fase == item, () {
                        setState(() {
                          _fase = item;
                          _aberto = 'status';
                        });
                      }),
                  ],
                ),
              ),
            if (_fase != null)
              _accordion(
                id: 'status',
                titulo: _titulo('Status', _status),
                completo: _status != null,
                child: Column(
                  children: [
                    for (final item in statusAnimal)
                      _opcao(item, _status == item, () {
                        setState(() {
                          _status = item;
                          _aberto = 'dados';
                        });
                      }),
                  ],
                ),
              ),
          ],
          if (_classificado) ...[
            _accordion(
              id: 'dados',
              titulo: 'Dados',
              completo: _descricao.text.trim().isNotEmpty,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CampoFinanceiro(
                          rotulo: 'DATA *',
                          child: TextField(
                            controller: _data,
                            style: _estiloCampo,
                            decoration: decoracaoCampo(''),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CampoFinanceiro(
                          rotulo: 'VALOR (R\$) *',
                          child: TextField(
                            controller: _valor,
                            onChanged: (_) => setState(() {}),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                            ],
                            style: _estiloCampo,
                            decoration: decoracaoCampo('0,00'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CampoFinanceiro(
                    rotulo: 'DESCRIÇÃO *',
                    child: TextField(
                      controller: _descricao,
                      onChanged: (_) => setState(() {}),
                      style: _estiloCampo,
                      decoration: decoracaoCampo('Descreva o lançamento...'),
                    ),
                  ),
                  if (_rebanho) ...[
                    const SizedBox(height: 12),
                    const SecaoRotulo('QUANTIDADE + UNIDADE  OPCIONAL'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        SizedBox(
                          width: 72,
                          child: TextField(
                            controller: _quantidade,
                            keyboardType: TextInputType.number,
                            style: _estiloCampo,
                            decoration: decoracaoCampo('0'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _unidade,
                            style: _estiloCampo,
                            decoration: decoracaoCampo('kg, doses...'),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _botaoFantasma('Selecionar existente')),
                      const SizedBox(width: 8),
                      Expanded(child: _botaoFantasma('Cadastrar novo')),
                    ],
                  ),
                ],
              ),
            ),
            _accordion(
              id: 'parceiros',
              titulo: _tituloParceiros(),
              completo: _fornecedor != null || _comprador != null ? true : null,
              child: Column(
                children: [
                  CampoFinanceiro(
                    rotulo: 'FORNECEDOR',
                    child: _select(
                      valor: _fornecedor,
                      aoMudar: (v) => setState(() => _fornecedor = v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CampoFinanceiro(
                    rotulo: 'COMPRADOR',
                    child: _select(
                      valor: _comprador,
                      aoMudar: (v) => setState(() => _comprador = v),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => _salvar(rascunho: false),
              style: FilledButton.styleFrom(
                backgroundColor: MyColors.colorPrimary,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Salvar lançamento',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _salvar(rascunho: true),
              style: OutlinedButton.styleFrom(
                foregroundColor: MyColors.colorPrimary,
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: Color(0xFFE6E6E6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Salvar rascunho',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          TextButton(
            onPressed: widget.aoFechar,
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: MyColors.colorBtnNo,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _titulo(String nome, String? valor) {
    if (valor == null || valor.isEmpty) return nome;
    return '$nome · $valor';
  }

  String _tituloParceiros() {
    final partes = [
      if (_fornecedor != null) _fornecedor!,
      if (_comprador != null) _comprador!,
    ];
    if (partes.isEmpty) return 'Fornecedor e comprador';
    return 'Fornecedor e comprador · ${partes.join(' · ')}';
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

  Widget _opcao(String label, bool selecionado, VoidCallback aoToque) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        label,
        style: TextStyle(
          color: selecionado ? MyColors.colorPrimary : const Color(0xFF313131),
          fontFamily: 'Montserrat',
          fontWeight: selecionado ? FontWeight.w600 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      trailing: selecionado
          ? const Icon(Icons.check_rounded, color: MyColors.colorPrimary)
          : null,
      onTap: aoToque,
    );
  }

  Widget _select({
    required String? valor,
    required ValueChanged<String?> aoMudar,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: valor,
      decoration: decoracaoCampo('Selecione...'),
      items: [
        for (final nome in parceirosMock)
          DropdownMenuItem(value: nome, child: Text(nome, style: _estiloCampo)),
      ],
      onChanged: aoMudar,
    );
  }

  Widget _botaoFantasma(String rotulo) {
    return OutlinedButton(
      onPressed: () => AppSnackBar.show(
        context: context,
        message: 'Layout ilustrativo.',
        isError: false,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF3D5346),
        side: const BorderSide(color: Color(0xFFE6E6E6)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        rotulo,
        style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12),
      ),
    );
  }
}

const _estiloCampo = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 13,
  fontWeight: FontWeight.w600,
  color: Color(0xFF313131),
);
