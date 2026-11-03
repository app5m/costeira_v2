import 'package:costeira/core/components/adaptive_selection_modal.dart';
import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_reference_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animals_controller.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class LancamentoAnimaisPage extends StatefulWidget {
  const LancamentoAnimaisPage({
    super.key,
    required this.selecionados,
    this.bloqueados = const {},
    this.motivoBloqueio = 'Animal já vinculado a um contrato.',
    this.ocultarBloqueados = false,
    this.somenteAtivos = false,
    this.somenteComBrinco = false,
    this.embeddedInDialog = false,
  });

  final List<AnimalEntity> selecionados;
  /// IDs que não podem ser escolhidos (ex.: já em parceria).
  final Set<int> bloqueados;
  final String motivoBloqueio;
  /// Se true, não lista bloqueados (só elegíveis).
  final bool ocultarBloqueados;
  /// Se true, remove vendido/morto/abigeato/consumo.
  final bool somenteAtivos;
  /// Se true, esconde animais sem brinco (fluxo investidor/parceria).
  final bool somenteComBrinco;
  final bool embeddedInDialog;

  @override
  State<LancamentoAnimaisPage> createState() => _LancamentoAnimaisPageState();
}

class _LancamentoAnimaisPageState extends State<LancamentoAnimaisPage> {
  late final ListAnimalsController _lista;
  final _busca = TextEditingController();
  late List<AnimalEntity> _escolhidos;
  int? _categoriaId;
  int? _faseId;
  int? _loteId;

  @override
  void initState() {
    super.initState();
    _escolhidos = [
      for (final animal in widget.selecionados)
        if (!widget.bloqueados.contains(animal.id))
          if (!widget.somenteComBrinco || _temBrinco(animal)) animal,
    ];
    _lista = Modular.get<ListAnimalsController>();
    _lista.addListener(_atualizar);
    _busca.addListener(_atualizar);
    _lista.load();
  }

  @override
  void dispose() {
    _lista.removeListener(_atualizar);
    _lista.dispose();
    _busca.dispose();
    super.dispose();
  }

  void _atualizar() {
    if (mounted) setState(() {});
  }

  static const _statusSaida = {'vendido', 'morto', 'abigeato', 'consumo'};

  bool _ativoNoRebanho(AnimalEntity animal) {
    final status = animal.status?.trim().toLowerCase() ?? '';
    if (status.isEmpty) return true;
    return !_statusSaida.contains(status);
  }

  bool _temBrinco(AnimalEntity animal) {
    return (animal.brinco ?? '').trim().isNotEmpty;
  }

  bool get _temFiltrosAtivos => _categoriaId != null || _faseId != null || _loteId != null;

  List<AnimalEntity> get _visiveis {
    final busca = _busca.text.trim().toLowerCase();
    return [
      for (final animal in _lista.animals)
        if (!widget.somenteAtivos || _ativoNoRebanho(animal))
          if (!widget.somenteComBrinco || _temBrinco(animal))
            if (!widget.ocultarBloqueados || !_bloqueado(animal))
              if (_categoriaId == null || animal.appAnimaisCategoriasId == _categoriaId)
                if (_faseId == null || animal.appAnimaisSubcategoriasId == _faseId)
                  if (_loteId == null || animal.appAnimaisLotesId == _loteId)
                    if (busca.isEmpty || (animal.brinco ?? '').toLowerCase().contains(busca)) animal,
    ];
  }

  bool _bloqueado(AnimalEntity animal) => widget.bloqueados.contains(animal.id);

  void _alternar(AnimalEntity animal) {
    if (_bloqueado(animal)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.motivoBloqueio)),
      );
      return;
    }
    final ja = _escolhidos.any((item) => item.id == animal.id);
    if (!ja && _escolhidos.length >= 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No máximo 100 animais.')),
      );
      return;
    }
    setState(() {
      _escolhidos = ja
          ? _escolhidos.where((item) => item.id != animal.id).toList()
          : [..._escolhidos, animal];
    });
  }

  Future<void> _abrirFiltros() async {
    final categorias = _opcoes((animal) => animal.categoria);
    var categoriaId = _categoriaId;
    var faseId = _faseId;
    var loteId = _loteId;

    Widget conteudo(BuildContext modal, void Function(VoidCallback) setSheet, bool embedded) {
      final fases = _opcoes(
        (animal) => animal.subcategoria,
        onde: (animal) =>
            categoriaId == null || animal.appAnimaisCategoriasId == categoriaId,
      );
      final lotes = _opcoes((animal) => animal.lote);
      return Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          embedded ? 8 : 12,
          16,
          16 + MediaQuery.of(modal).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!embedded) ...[
              const Text(
                'Filtros',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
            ],
            _Filtro(
              rotulo: 'Categoria',
              valor: categoriaId,
              opcoes: categorias,
              aoMudar: (valor) => setSheet(() {
                categoriaId = valor;
                faseId = null;
              }),
            ),
            const SizedBox(height: 8),
            _Filtro(
              rotulo: 'Fase',
              valor: faseId,
              opcoes: fases,
              aoMudar: (valor) => setSheet(() => faseId = valor),
            ),
            const SizedBox(height: 8),
            _Filtro(
              rotulo: 'Lote',
              valor: loteId,
              opcoes: lotes,
              aoMudar: (valor) => setSheet(() => loteId = valor),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      categoriaId = null;
                      faseId = null;
                      loteId = null;
                      Navigator.pop(modal, true);
                    },
                    child: const Text('Limpar', style: TextStyle(fontFamily: 'Montserrat')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(modal, true),
                    style: FilledButton.styleFrom(backgroundColor: MyColors.colorPrimary),
                    child: const Text('Aplicar', style: TextStyle(fontFamily: 'Montserrat')),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final bool? aplicado;
    if (kIsWeb || widget.embeddedInDialog) {
      aplicado = await showAdaptiveSelectionModal<bool>(
        context: context,
        title: 'Filtros',
        builder: (embeddedInDialog) => StatefulBuilder(
          builder: (modal, setSheet) => conteudo(modal, setSheet, embeddedInDialog),
        ),
      );
    } else {
      aplicado = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheet) => StatefulBuilder(
          builder: (sheet, setSheet) => conteudo(sheet, setSheet, false),
        ),
      );
    }

    if (aplicado != true || !mounted) return;
    setState(() {
      _categoriaId = categoriaId;
      _faseId = faseId;
      _loteId = loteId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildBody(context);
    if (widget.embeddedInDialog) return body;

    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: Text('Selecionar animais', style: estiloTituloAppBarPilha()),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: body,
    );
  }

  Widget _buildBody(BuildContext context) {
    final embedded = widget.embeddedInDialog;
    final listMaxHeight = embedded ? 420.0 : double.infinity;
    final horizontal = embedded ? 24.0 : 16.0;

    final lista = _lista.isLoading
        ? const Center(child: CircularProgressIndicator())
        : _visiveis.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    widget.somenteComBrinco
                        ? 'Nenhum animal com brinco elegível. Cadastre o brinco antes de vincular à parceria.'
                        : widget.ocultarBloqueados
                            ? 'Nenhum animal elegível. Use “Novo” para cadastrar animal do investidor, ou escolha um que ainda não esteja em contrato e sem patrimônio próprio.'
                            : 'Nenhum animal nesta fazenda.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: embedded,
                physics: embedded
                    ? const AlwaysScrollableScrollPhysics()
                    : null,
                padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 16),
                itemCount: _visiveis.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final animal = _visiveis[index];
                  final bloqueado = _bloqueado(animal);
                  final marcado =
                      !bloqueado && _escolhidos.any((item) => item.id == animal.id);
                  return Material(
                    color: bloqueado ? const Color(0xFFF3F3F3) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _alternar(animal),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: marcado
                                ? MyColors.colorPrimary
                                : bloqueado
                                    ? const Color(0xFFD0D0D0)
                                    : const Color(0xFFE6E6E6),
                          ),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: marcado,
                              activeColor: MyColors.colorPrimary,
                              onChanged: bloqueado ? null : (_) => _alternar(animal),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _brinco(animal),
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w700,
                                      color: bloqueado ? const Color(0xFF9A9A9A) : null,
                                    ),
                                  ),
                                  Text(
                                    bloqueado ? widget.motivoBloqueio : _rotulo(animal),
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 12,
                                      color: bloqueado
                                          ? const Color(0xFFC62828)
                                          : const Color(0xFF8A8A8A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );

    return Column(
      mainAxisSize: embedded ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(horizontal, embedded ? 8 : 12, horizontal, 0),
          child: Column(
            children: [
              TextField(
                controller: _busca,
                decoration: decoracaoCampo('Buscar por brinco'),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: _pillFiltrar(
                  ativo: _temFiltrosAtivos,
                  onTap: _abrirFiltros,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _escolhidos.length == 1
                      ? '1 selecionado'
                      : '${_escolhidos.length} selecionados',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    color: MyColors.colorPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_lista.errorMessage != null)
          Padding(
            padding: EdgeInsets.all(horizontal),
            child: Text(
              _lista.errorMessage!,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                color: Color(0xFFC62828),
              ),
            ),
          ),
        if (embedded)
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: listMaxHeight),
            child: SizedBox(width: double.infinity, child: lista),
          )
        else
          Expanded(child: lista),
        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontal,
              8,
              horizontal,
              embedded ? 20 : 12,
            ),
            child: FilledButton(
              onPressed: () => Navigator.pop(context, _escolhidos),
              style: FilledButton.styleFrom(
                backgroundColor: MyColors.colorPrimary,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(
                _escolhidos.length == 1
                    ? 'Confirmar 1 animal'
                    : 'Confirmar ${_escolhidos.length} animais',
                style: const TextStyle(fontFamily: 'Montserrat'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pillFiltrar({required bool ativo, required VoidCallback onTap}) {
    return Material(
      color: ativo ? const Color(0x14128977) : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ativo ? MyColors.colorPrimary : const Color(0xFFE6E6E6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 16,
                color: ativo ? MyColors.colorPrimary : const Color(0xFF8C8C8C),
              ),
              const SizedBox(width: 6),
              Text(
                ativo ? 'Filtros ativos' : 'Filtrar',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ativo ? MyColors.colorPrimary : const Color(0xFF8C8C8C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<({int id, String nome})> _opcoes(
    AnimalReferenceEntity? Function(AnimalEntity animal) ler, {
    bool Function(AnimalEntity animal)? onde,
  }) {
    final vistos = <int>{};
    final saida = <({int id, String nome})>[];
    for (final animal in _lista.animals) {
      if (onde != null && !onde(animal)) continue;
      final ref = ler(animal);
      final nome = ref?.nome.trim() ?? '';
      if (ref == null || nome.isEmpty || !vistos.add(ref.id)) continue;
      saida.add((id: ref.id, nome: nome));
    }
    saida.sort((a, b) => a.nome.compareTo(b.nome));
    return saida;
  }
}

class _Filtro extends StatelessWidget {
  const _Filtro({
    required this.rotulo,
    required this.valor,
    required this.opcoes,
    required this.aoMudar,
  });

  final String rotulo;
  final int? valor;
  final List<({int id, String nome})> opcoes;
  final ValueChanged<int?> aoMudar;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      key: ValueKey('$rotulo-$valor-${opcoes.length}'),
      initialValue: opcoes.any((item) => item.id == valor) ? valor : null,
      decoration: decoracaoCampo(rotulo),
      items: [
        DropdownMenuItem(value: null, child: Text('Todas', style: _estilo)),
        for (final item in opcoes)
          DropdownMenuItem(value: item.id, child: Text(item.nome, style: _estilo)),
      ],
      onChanged: aoMudar,
    );
  }

  static const _estilo = TextStyle(fontFamily: 'Montserrat', fontSize: 14);
}

String _brinco(AnimalEntity animal) {
  final brinco = animal.brinco?.trim() ?? '';
  return brinco.isEmpty ? 'Sem brinco' : brinco;
}

String _rotulo(AnimalEntity animal) {
  final categoria = animal.categoria?.nome.trim() ?? '';
  final fase = animal.subcategoria?.nome.trim() ?? '';
  final lote = animal.lote?.nome.trim() ?? '';
  final categoriaFase = [categoria, fase].where((parte) => parte.isNotEmpty).join(' / ');
  return [categoriaFase, lote].where((parte) => parte.isNotEmpty).join(' · ');
}
