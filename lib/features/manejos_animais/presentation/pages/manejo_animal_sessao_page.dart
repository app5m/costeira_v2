import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/core/components/form_accordion.dart';
import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/manejos_animais/presentation/page_controllers/manejo_animal_sessao_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ManejoAnimalSessaoPage extends StatefulWidget {
  const ManejoAnimalSessaoPage({super.key});

  @override
  State<ManejoAnimalSessaoPage> createState() => _ManejoAnimalSessaoPageState();
}

class _ManejoAnimalSessaoPageState extends State<ManejoAnimalSessaoPage> {
  late final ManejoAnimalSessaoController _controller;
  bool _verMaisPesagem = false;
  bool _gradeAberta = true;
  ManejoPainel _painel = ManejoPainel.nenhum;

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<ManejoAnimalSessaoController>()..init();
    _controller.addListener(_onChange);
  }

  void _onChange() {
    if (!mounted) {
      return;
    }
    if (_painel != _controller.painel) {
      _verMaisPesagem = false;
      _gradeAberta = _controller.painel == ManejoPainel.nenhum;
      _painel = _controller.painel;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onChange);
    _controller.dispose();
    super.dispose();
  }

  void _voltar() {
    if (_controller.sessionOn) {
      _controller.trocarGrupo();
      setState(() => _gradeAberta = true);
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final titulo = _controller.sessionOn ? 'Sessão de manejo' : 'Seleção do grupo';
    return PopScope(
      canPop: !_controller.sessionOn,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _voltar();
        }
      },
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: IconButton(
          onPressed: _voltar,
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _controller.loading && _controller.animais.isEmpty && !_controller.sessionOn
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              children: [
                if (_controller.error != null) _erro(_controller.error!),
                if (!_controller.sessionOn) ..._grupo() else ..._hub(),
              ],
            ),
    ),
    );
  }

  List<Widget> _grupo() {
    return [
      _dataField('Data'),
      _select(
        'Categoria',
        _controller.categoriaId,
        _controller.categorias
            .map((item) => AppSelectOption(value: item.id, label: item.nome))
            .toList(),
        _controller.setCategoria,
        placeholder: 'Todas',
      ),
      _select(
        'Fase',
        _controller.faseId,
        _controller.fases
            .map((item) => AppSelectOption(value: item.id, label: item.nome))
            .toList(),
        _controller.setFase,
        placeholder: _controller.categoriaId == null ? 'Selecione a categoria' : 'Todas',
        enabled: _controller.categoriaId != null && _controller.fases.isNotEmpty,
      ),
      if (_controller.statusOpcoes.isNotEmpty) ...[
        const _Label('Status'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final status in _controller.statusOpcoes)
              FilterChip(
                label: Text(status),
                selected: _controller.selectedStatuses.contains(status),
                onSelected: (_) => _controller.toggleStatus(status),
                selectedColor: const Color(0xFFD9EDE1),
                checkmarkColor: MyColors.colorPrimary,
              ),
          ],
        ),
        const SizedBox(height: 18),
      ],
      _select(
        'Piquete',
        _controller.piqueteId,
        _controller.piquetes
            .map((item) => AppSelectOption(value: item.id, label: item.nome))
            .toList(),
        _controller.setPiquete,
        placeholder: 'Todos os piquetes',
      ),
      _select(
        'Lote',
        _controller.loteId,
        _controller.lotes
            .map((item) => AppSelectOption(value: item.id, label: item.nome))
            .toList(),
        _controller.setLote,
        placeholder: 'Selecionar lote',
      ),
      _resumo(
        _controller.grupo.isEmpty
            ? 'Nenhum animal neste filtro.'
            : '${_controller.grupo.length} animal(is)'
                  '${_controller.loteNome.isEmpty ? '' : ' · ${_controller.loteNome}'}'
                  '${_controller.piqueteNome.isEmpty ? '' : ' · ${_controller.piqueteNome}'}',
      ),
      CustomButton(
        text: 'Confirmar grupo e iniciar sessão',
        enabled: _controller.podeConfirmar,
        onPressed: _controller.confirmarGrupo,
      ),
    ];
  }

  List<Widget> _hub() {
    final partes = <String>[
      '${_controller.grupo.length} animal(is)',
      if (_controller.loteNome.isNotEmpty) _controller.loteNome,
      if (_controller.piqueteNome.isNotEmpty) _controller.piqueteNome,
      if (_controller.categoriaNome.isNotEmpty) _controller.categoriaNome,
      _controller.data.text,
    ];
    return [
      _resumo(partes.join(' · ')),
      if (_controller.acoes.isEmpty)
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Nenhuma ação registrada ainda.',
            style: TextStyle(color: Color(0xFF8C8C8C), fontSize: 13, fontFamily: 'Montserrat'),
          ),
        )
      else
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            _controller.acoes.map((acao) => acao.titulo).join(' · '),
            style: const TextStyle(
              color: MyColors.colorPrimary,
              fontSize: 13,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      FormAccordion(
        title: _tituloAcao,
        expanded: _gradeAberta,
        complete: _controller.painel == ManejoPainel.nenhum ? null : true,
        onToggle: () => setState(() => _gradeAberta = !_gradeAberta),
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.95,
          children: [
            for (final item in _acoes)
              _AcaoGrade(
                label: item.$2,
                icon: item.$3,
                selected: _controller.painel == item.$1,
                onTap: () {
                  _controller.abrir(item.$1);
                  setState(() => _gradeAberta = false);
                },
              ),
          ],
        ),
      ),
      if (_controller.painel != ManejoPainel.nenhum) ...[
        if (_controller.formError != null) _erro(_controller.formError!),
        ..._painelDe(_controller.painel),
      ],
      const SizedBox(height: 12),
      CustomButton(
        text: 'Finalizar sessão',
        isLoading: _controller.finalizando,
        enabled: _controller.acoes.isNotEmpty &&
            !_controller.saving &&
            !_controller.finalizando,
        onPressed: _finalizar,
        backgroundColor: Colors.white,
        textColor: MyColors.colorPrimary,
        borderColor: MyColors.colorPrimary,
        disabledColor: const Color(0xFFF3F3F3),
        disabledTextColor: const Color(0xFF9E9E9E),
        loaderColor: MyColors.colorPrimary,
      ),
    ];
  }

  String get _tituloAcao {
    for (final item in _acoes) {
      if (item.$1 == _controller.painel) {
        return item.$2;
      }
    }
    return 'Escolher ação';
  }

  static const _acoes = [
    (ManejoPainel.pesagem, 'Pesagem', LucideIcons.scale),
    (ManejoPainel.sanitario, 'Sanitário', LucideIcons.syringe),
    (ManejoPainel.nutricao, 'Nutrição', LucideIcons.wheat),
    (ManejoPainel.veterinario, 'Veterinário', LucideIcons.stethoscope),
    (ManejoPainel.identificacao, 'Identificação', LucideIcons.tag),
    (ManejoPainel.trocaCategoria, 'Categoria', LucideIcons.replace),
    (ManejoPainel.movimentacao, 'Piquete', LucideIcons.mapPin),
  ];

  List<Widget> _painelDe(ManejoPainel painel) {
    return switch (painel) {
      ManejoPainel.pesagem => _pesagem(),
      ManejoPainel.sanitario => _estoque(1, 'Produto', usarUnidade: true),
      ManejoPainel.nutricao => _estoque(2, 'Produto', usarUnidade: true),
      ManejoPainel.veterinario => _veterinario(),
      ManejoPainel.identificacao => _identificacao(),
      ManejoPainel.trocaCategoria => _trocaCategoria(),
      ManejoPainel.movimentacao => _movimentacao(),
      ManejoPainel.nenhum => const <Widget>[],
    };
  }

  List<Widget> _pesagem() {
    final linhas = _controller.linhasPesagem;
    final pesos = linhas
        .where((linha) => (_controller.pesos[linha.animal.id]?.text.trim().isNotEmpty ?? false))
        .map((linha) => linha.pesoAtual)
        .where((peso) => peso > 0)
        .toList();
    final media = pesos.isEmpty ? null : pesos.reduce((a, b) => a + b) / pesos.length;
    return [
      _escopo(),
      const _Label('Score corporal'),
      Row(
        children: [
          for (var nota = 1; nota <= 5; nota++) ...[
            if (nota > 1) const SizedBox(width: 8),
            Expanded(
              child: _AcaoBotao(
                label: '$nota',
                selected: _controller.score == nota,
                onTap: () {
                  _controller.score = _controller.score == nota ? null : nota;
                  _controller.refresh();
                },
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 12),
      const Row(
        children: [
          Expanded(flex: 4, child: _Coluna('Brinco')),
          Expanded(flex: 3, child: _Coluna('Atual')),
          Expanded(flex: 2, child: _Coluna('Ganho')),
        ],
      ),
      const SizedBox(height: 6),
      for (final linha in _fatia(linhas, _verMaisPesagem)) _linhaPesagem(linha),
      _verMais(
        total: linhas.length,
        aberto: _verMaisPesagem,
        onTap: () => setState(() => _verMaisPesagem = !_verMaisPesagem),
      ),
      _resumo(
        'Peso médio ${_fmt(media)} · Pesados ${pesos.length} · Grupo ${_controller.animaisDaAcao.length}',
      ),
      _obs(),
      _registrar('Registrar na sessão'),
    ];
  }

  Widget _linhaPesagem(PesagemLinha linha) {
    final controller = _controller.pesos[linha.animal.id];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  linha.animal.brinco ?? 'Sem brinco',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF313131),
                    fontSize: 13,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _ultimo(linha),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF8C8C8C), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
              decoration: InputDecoration(
                hintText: 'kg',
                isDense: true,
                hintStyle: const TextStyle(color: Color(0xFF8C8C8C), fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFEBEBEB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _fmt(linha.ganho),
                  style: const TextStyle(
                    color: Color(0xFF313131),
                    fontSize: 12,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'gmd ${_fmt(linha.gmd)}',
                  style: const TextStyle(color: Color(0xFF8C8C8C), fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _ultimo(PesagemLinha linha) {
    final ultimo = linha.animal.ultimoPeso;
    if (ultimo == null || !ultimo.temPesagem) {
      return 'sem peso';
    }
    return '${ultimo.peso} kg · ${ultimo.qtdDias ?? 0}d';
  }

  List<Widget> _estoque(
    int categoriaEstoque,
    String titulo, {
    bool comEscopo = true,
    bool comObs = true,
    bool comRegistrar = true,
    bool usarUnidade = false,
  }) {
    final produtos = _controller.insumosDaCategoria(categoriaEstoque);
    if (produtos.isEmpty) {
      final nome = _controller.nomeCategoriaEstoque(categoriaEstoque);
      return [
        Text(
          'Nenhum produto cadastrado na categoria de estoque "$nome". Cadastre em Entrada de Insumo ou no Guia de Nomenclaturas.',
          style: const TextStyle(color: Color(0xFF8C8C8C), fontSize: 13, fontFamily: 'Montserrat'),
        ),
        const SizedBox(height: 18),
      ];
    }
    final produto = _controller.insumoSelecionado;
    return [
      if (comEscopo) _escopo(),
      _select(
        titulo,
        _controller.insumoId,
        produtos.map((item) => AppSelectOption(value: item.id, label: item.nome)).toList(),
        (id) {
          _controller.insumoId = id;
          _controller.refresh();
        },
        placeholder: 'Selecionar',
      ),
      if (produto != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Text(
            'Unidade ${produto.unidade?.nome ?? ''} · Saldo ${produto.qtdTotal ?? 0}',
            style: const TextStyle(color: Color(0xFF313131), fontSize: 13, fontFamily: 'Montserrat'),
          ),
        ),
      _Label(_rotuloQuantidade(produto, usarUnidade)),
      _input(
        controller: _controller.dose,
        hint: '0',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => setState(() {}),
      ),
      if (_controller.saldoInsuficiente)
        _erro('Saldo insuficiente no estoque para esta aplicação.')
      else
        _resumo(
          'Total ${_controller.doseTotal}${_sufixoUnidade(produto, usarUnidade)} · ${_controller.escopoAnimais.length} animal(is)',
        ),
      if (comObs) _obs(),
      if (comRegistrar) _registrar('Registrar na sessão'),
    ];
  }

  String _rotuloQuantidade(InsumoEntity? produto, bool usarUnidade) {
    if (!usarUnidade) {
      return 'Dose por animal';
    }
    final unidade = produto?.unidade?.nome.trim() ?? '';
    if (unidade.isEmpty) {
      return 'Quantidade por animal';
    }
    return '${unidade[0].toUpperCase()}${unidade.substring(1)} por animal';
  }

  String _sufixoUnidade(InsumoEntity? produto, bool usarUnidade) {
    if (!usarUnidade) {
      return '';
    }
    final unidade = produto?.unidade?.nome.trim() ?? '';
    if (unidade.isEmpty) {
      return '';
    }
    return ' $unidade';
  }

  List<Widget> _veterinario() {
    return [
      _escopo(),
      _select(
        'Tipo de procedimento',
        _controller.tipoId,
        _controller.tiposDe(4).map((item) => AppSelectOption(value: item.id, label: item.nome)).toList(),
        (id) {
          _controller.tipoId = id;
          _controller.refresh();
        },
        placeholder: 'Selecionar',
      ),
      const _Label('Responsável'),
      _input(controller: _controller.responsavel, hint: 'Opcional'),
      _obs(label: 'Observações / diagnóstico'),
      const _Label('Produto'),
      _ChoiceRow(
        leftLabel: 'Sem produto',
        rightLabel: 'Usar produto',
        leftSelected: !_controller.usarProduto,
        onLeft: () {
          _controller.usarProduto = false;
          _controller.refresh();
        },
        onRight: () {
          _controller.usarProduto = true;
          _controller.refresh();
        },
      ),
      const SizedBox(height: 18),
      if (_controller.usarProduto) ..._estoque(1, 'Produto', comEscopo: false, comObs: false),
      if (!_controller.usarProduto) _registrar('Registrar na sessão'),
    ];
  }

  List<Widget> _identificacao() {
    final nova = _controller.identificacaoModo == ManejoIdentificacaoModo.nova;
    return [
      _ChoiceRow(
        leftLabel: 'Nova',
        rightLabel: 'Troca de brinco',
        leftSelected: nova,
        onLeft: () => _controller.setModo(ManejoIdentificacaoModo.nova),
        onRight: () => _controller.setModo(ManejoIdentificacaoModo.troca),
      ),
      const SizedBox(height: 18),
      _select(
        'Tipo',
        _controller.tipoId,
        _controller.tiposDe(5).map((item) => AppSelectOption(value: item.id, label: item.nome)).toList(),
        (id) => _controller.setTipo(id),
        placeholder: 'Selecionar',
      ),
      if (nova) ...[
        _escopo(),
        if (_controller.cadastrandoBrinco && _controller.escopoAnimais.isNotEmpty) ..._camposBrinco(),
        _registrar('Registrar na sessão'),
      ] else ...[
        _chipsTroca(),
        const _Label('Novo brinco'),
        _input(controller: _controller.novoBrinco, hint: 'Brinco'),
        const _Label('Motivo'),
        _input(controller: _controller.motivoTroca, hint: 'Opcional'),
        _registrar('Registrar na sessão'),
      ],
    ];
  }

  List<Widget> _trocaCategoria() {
    return [
      _escopo(),
      _resumo(
        'Categoria atual: ${_controller.categoriaNome.isEmpty ? '—' : _controller.categoriaNome}',
      ),
      _select(
        'Nova categoria',
        _controller.novaCategoriaId,
        _controller.categorias
            .map((item) => AppSelectOption(value: item.id, label: item.nome))
            .toList(),
        (id) {
          _controller.novaCategoriaId = id;
          _controller.novaFaseId = null;
          _controller.refresh();
        },
        placeholder: 'Selecionar',
      ),
      _select(
        'Nova fase',
        _controller.novaFaseId,
        _controller.fasesNovas
            .map((item) => AppSelectOption(value: item.id, label: item.nome))
            .toList(),
        (id) {
          _controller.novaFaseId = id;
          _controller.refresh();
        },
        placeholder: 'Selecionar',
        enabled: _controller.novaCategoriaId != null,
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Text(
          'Lote do grupo: ${_controller.loteNome}',
          style: const TextStyle(color: Color(0xFF313131), fontSize: 13, fontFamily: 'Montserrat'),
        ),
      ),
      _dataField('Data da mudança'),
      _registrar('Registrar na sessão'),
    ];
  }

  List<Widget> _movimentacao() {
    final destino = _controller.piqueteDestino;
    final piquete = _controller.destino == ManejoDestino.piquete;
    return [
      _escopo(),
      const _Label('Destino'),
      _ChoiceRow(
        leftLabel: 'Piquete',
        rightLabel: 'Lote',
        leftSelected: piquete,
        onLeft: () {
          _controller.destino = ManejoDestino.piquete;
          _controller.refresh();
        },
        onRight: () {
          _controller.destino = ManejoDestino.lote;
          _controller.refresh();
        },
      ),
      const SizedBox(height: 18),
      if (piquete) ...[
        _select(
          'Piquete de destino',
          _controller.piqueteDestinoId,
          _controller.piquetes
              .map((item) => AppSelectOption(value: item.id, label: item.nome))
              .toList(),
          (id) {
            _controller.piqueteDestinoId = id;
            _controller.refresh();
          },
          placeholder: 'Selecionar',
        ),
        if (destino != null)
          _resumo(
            '${_controller.escopoAnimais.length} cab. · ${destino.areaUtil ?? 0} ha'
            '${destino.lotacaoMedia == null ? '' : ' · lotação média ${destino.lotacaoMedia}'}',
          ),
      ] else
        _select(
          'Lote de destino',
          _controller.loteDestinoId,
          _controller.lotes
              .map((item) => AppSelectOption(value: item.id, label: item.nome))
              .toList(),
          (id) {
            _controller.loteDestinoId = id;
            _controller.refresh();
          },
          placeholder: 'Selecionar',
        ),
      _dataField('Data'),
      _registrar('Confirmar movimentação'),
    ];
  }

  List<T> _fatia<T>(List<T> itens, bool aberto) {
    if (aberto || itens.length <= 6) {
      return itens;
    }
    return itens.take(6).toList(growable: false);
  }

  Widget _verMais({
    required int total,
    required bool aberto,
    required VoidCallback onTap,
  }) {
    if (total <= 6) {
      return const SizedBox(height: 8);
    }
    final resto = total - 6;
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: MyColors.colorPrimary,
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          aberto ? 'Ver menos' : 'Ver mais $resto',
          style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  List<Widget> _camposBrinco() {
    final tipo = _controller.tiposDe(5)
        .where((item) => item.id == _controller.tipoId)
        .map((item) => item.nome)
        .firstOrNull;
    return [
      _Label(tipo == null || tipo.isEmpty ? 'Brinco' : tipo),
      for (final animal in _controller.escopoAnimais)
        if (_controller.brincosNovos[animal.id] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _brinco(animal),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF313131),
                      fontSize: 13,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _controller.brincosNovos[animal.id],
                    style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Digite o brinco',
                      isDense: true,
                      hintStyle: const TextStyle(color: Color(0xFF8C8C8C), fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFFEBEBEB),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      const SizedBox(height: 10),
    ];
  }

  String _brinco(AnimalEntity animal) {
    final brinco = animal.brinco?.trim();
    if (brinco == null || brinco.isEmpty) {
      return '#${animal.id}';
    }
    return brinco;
  }

  Widget _escopo() {
    final lote = _controller.escopo == ManejoEscopo.lote;
    final animals = _controller.animaisDaAcao;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('Escopo da ação'),
        _ChoiceRow(
          leftLabel: 'Lote inteiro',
          rightLabel: 'Parcial',
          leftSelected: lote,
          onLeft: () => _controller.setEscopo(ManejoEscopo.lote),
          onRight: () => _controller.setEscopo(ManejoEscopo.parcial),
        ),
        const SizedBox(height: 12),
        if (animals.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Text(
              _controller.cadastrandoBrinco
                  ? 'Nenhum animal sem brinco neste grupo.'
                  : 'Nenhum animal com brinco neste grupo.',
              style: const TextStyle(color: Color(0xFF8C8C8C), fontSize: 13),
            ),
          )
        else if (lote)
          _chipsLote(animals)
        else
          _chipsParcial(animals),
      ],
    );
  }

  Widget _chipsLote(List<AnimalEntity> animals) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Serão incluídos ${animals.length} animal(is):',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final animal in animals) Chip(label: Text(_brinco(animal))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chipsTroca() {
    final animals = _controller.animaisDaAcao;
    if (animals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 18),
        child: Text(
          'Nenhum animal com brinco neste grupo.',
          style: TextStyle(color: Color(0xFF8C8C8C), fontSize: 13),
        ),
      );
    }
    final selecionado = animals.where((animal) => animal.id == _controller.animalTrocaId).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecione o animal (${animals.length} disponíveis)',
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final animal in animals)
              FilterChip(
                label: Text(_rotuloChip(animal)),
                selected: _controller.animalTrocaId == animal.id,
                onSelected: (_) {
                  _controller.animalTrocaId =
                      _controller.animalTrocaId == animal.id ? null : animal.id;
                  _controller.refresh();
                },
                selectedColor: const Color(0xFFD9EDE1),
                checkmarkColor: MyColors.colorPrimary,
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 18),
          child: Text(
            '$selecionado de ${animals.length} animal(is) selecionado(s)',
            style: const TextStyle(color: Color(0xFF8C8C8C), fontSize: 12),
          ),
        ),
      ],
    );
  }

  String _rotuloChip(AnimalEntity animal) {
    final peso = animal.peso == null ? '' : '  ${animal.peso!.toStringAsFixed(0)}kg';
    return '${_brinco(animal)}$peso';
  }

  Widget _chipsParcial(List<AnimalEntity> animals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Selecione os animais (${animals.length} disponíveis)',
                style: const TextStyle(fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: _controller.selectAllParcial,
              child: const Text('Todos'),
            ),
            TextButton(
              onPressed: _controller.clearParcial,
              child: const Text('Limpar'),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final animal in animals)
              FilterChip(
                label: Text(_rotuloChip(animal)),
                selected: _controller.selecionados.contains(animal.id),
                onSelected: (_) => _controller.toggleAnimal(animal.id),
                selectedColor: const Color(0xFFD9EDE1),
                checkmarkColor: MyColors.colorPrimary,
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 18),
          child: Text(
            '${_controller.escopoAnimais.length} de ${animals.length} animal(is) selecionado(s)',
            style: const TextStyle(color: Color(0xFF8C8C8C), fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _obs({String label = 'Observações'}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        _input(controller: _controller.obs, hint: 'Anotações...', maxLines: 3),
      ],
    );
  }

  Widget _registrar(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CustomButton(
        text: label,
        enabled: _controller.podeRegistrar &&
            !_controller.saving &&
            !_controller.finalizando,
        isLoading: _controller.saving,
        onPressed: _registrarAcao,
      ),
    );
  }

  Widget _dataField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        _input(
          controller: _controller.data,
          hint: '00/00/0000',
          readOnly: true,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _controller.dataAtual,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              _controller.setData(picked);
            }
          },
        ),
      ],
    );
  }

  Widget _select<T>(
    String label,
    T? value,
    List<AppSelectOption<T>> options,
    ValueChanged<T?> onChanged, {
    required String placeholder,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        AppSelectOverlay<T>(
          value: value,
          placeholder: placeholder,
          enabled: enabled,
          options: options,
          onChanged: onChanged,
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    bool readOnly = false,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF8C8C8C), fontSize: 14, fontFamily: 'Montserrat'),
          filled: true,
          fillColor: const Color(0xFFEBEBEB),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _resumo(String texto) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF7F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: const TextStyle(color: Color(0xFF313131), fontSize: 13, fontFamily: 'Montserrat'),
      ),
    );
  }

  Widget _erro(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        texto,
        style: const TextStyle(color: Colors.red, fontSize: 12, fontFamily: 'Montserrat'),
      ),
    );
  }

  String _fmt(double? value) {
    if (value == null) {
      return '—';
    }
    return value.toStringAsFixed(2);
  }

  Future<void> _registrarAcao() async {
    final erro = await _controller.registrarPainel();
    if (!mounted) {
      return;
    }
    if (erro != null) {
      AppSnackBar.show(context: context, message: erro);
      return;
    }
    AppSnackBar.show(context: context, message: 'Ação registrada.', isError: false);
  }

  Future<void> _finalizar() async {
    final erro = await _controller.finalizar();
    if (!mounted) {
      return;
    }
    if (erro != null) {
      AppSnackBar.show(context: context, message: erro);
      return;
    }
    AppSnackBar.show(context: context, message: 'Sessão finalizada.', isError: false);
    Navigator.of(context).pop();
  }
}

class _Coluna extends StatelessWidget {
  const _Coluna(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF8C8C8C),
        fontSize: 11,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF313131),
          fontSize: 14,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }
}

class _AcaoGrade extends StatelessWidget {
  const _AcaoGrade({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? MyColors.colorPrimary : const Color(0xFF5A5A5A);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFD9EDE1) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? MyColors.colorPrimary : const Color(0xFFE2E2E2),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                height: 1.15,
                fontFamily: 'Montserrat',
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AcaoBotao extends StatelessWidget {
  const _AcaoBotao({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFD9EDE1) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? MyColors.colorPrimary : const Color(0xFFE2E2E2),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? MyColors.colorPrimary : const Color(0xFF5A5A5A),
            fontSize: 13,
            fontFamily: 'Montserrat',
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.leftLabel,
    required this.rightLabel,
    required this.leftSelected,
    this.onLeft,
    this.onRight,
  });

  final String leftLabel;
  final String rightLabel;
  final bool leftSelected;
  final VoidCallback? onLeft;
  final VoidCallback? onRight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _AcaoBotao(label: leftLabel, selected: leftSelected, onTap: onLeft ?? () {})),
        const SizedBox(width: 8),
        Expanded(
          child: _AcaoBotao(label: rightLabel, selected: !leftSelected, onTap: onRight ?? () {}),
        ),
      ],
    );
  }
}
