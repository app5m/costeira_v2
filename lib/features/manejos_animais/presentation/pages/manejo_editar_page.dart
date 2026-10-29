import 'package:costeira/core/common/get_list/domain/entities/list_item_entity.dart';
import 'package:costeira/core/common/get_list/presentation/controllers/get_list_controller.dart';
import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animal_lots_controller.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/insumos/domain/usecases/get_insumos_usecase.dart';
import 'package:costeira/features/manejos_animais/domain/entities/manejo_animal_lista.dart';
import 'package:costeira/features/manejos_animais/domain/usecases/adicionar_manejo_animal_usecase.dart';
import 'package:costeira/features/manejos_animais/presentation/page_controllers/manejo_editar_controller.dart';
import 'package:costeira/features/potreiros/presentation/controllers/list_potreiros_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ManejoEditarPage extends StatefulWidget {
  const ManejoEditarPage({super.key, required this.item});

  final ManejoAnimalListaItem item;

  @override
  State<ManejoEditarPage> createState() => _ManejoEditarPageState();
}

class _ManejoEditarPageState extends State<ManejoEditarPage> {
  late final ManejoEditarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ManejoEditarController(
      item: widget.item,
      adicionar: Modular.get<AdicionarManejoAnimalUsecase>(),
      getList: Modular.get<GetListController>(),
      lots: Modular.get<ListAnimalLotsController>(),
      potreiros: Modular.get<ListPotreirosController>(),
      getInsumos: Modular.get<GetInsumosUsecase>(),
      resolveFarm: Modular.get<ResolveCurrentFarmId>(),
    )..init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: MyColors.colorPrimary,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            title: Text(
              'Editar ${ManejoAnimalCategoria.nomeDe(_controller.categoria)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: _controller.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    if (_controller.error != null) _erro(_controller.error!),
                    _data(),
                    ..._campos(),
                    CustomButton(
                      text: 'Atualizar',
                      enabled: _controller.podeSalvar,
                      isLoading: _controller.saving,
                      onPressed: _salvar,
                    ),
                  ],
                ),
        );
      },
    );
  }

  List<Widget> _campos() {
    return switch (_controller.categoria) {
      1 => [
        _texto('Score', _controller.score, '0'),
        _texto('Observações', _controller.obs, 'Detalhes...', linhas: 3),
      ],
      2 || 3 => [
        _texto('Dosagem', _controller.dosagem, '0', numero: true),
        _texto('Observações', _controller.obs, 'Detalhes...', linhas: 3),
      ],
      4 => [
        _select('Procedimento', _controller.tipoId, _controller.tipos, _controller.setTipo),
        _texto('Responsável', _controller.responsavel, 'Nome'),
        if (_controller.tipoDosagem != null)
          _texto('Dosagem', _controller.dosagem, '0', numero: true),
        _texto('Observações', _controller.obs, 'Detalhes...', linhas: 3),
      ],
      5 => [
        _select('Tipo', _controller.tipoId, _controller.tipos, _controller.setTipo),
        if (_controller.trocaBrinco) ...[
          _texto('Novo brinco', _controller.novoBrinco, 'Brinco'),
          _texto('Motivo', _controller.motivo, 'Motivo da troca', linhas: 2),
        ],
      ],
      6 => [
        _select(
          'Nova categoria',
          _controller.categoriaAnimalId,
          _controller.categoriasAnimais,
          _controller.setCategoriaAnimal,
        ),
        _select('Fase', _controller.faseId, _controller.fases, _controller.setFase),
        _selectLote(),
      ],
      7 => [
        _escolha(
          left: 'Piquete',
          right: 'Lote',
          leftSelected: _controller.destinoPiquete,
          onLeft: () => _controller.setDestinoPiquete(true),
          onRight: () => _controller.setDestinoPiquete(false),
        ),
        const SizedBox(height: 18),
        if (_controller.destinoPiquete) _selectPiquete() else _selectLote(),
      ],
      8 => [
        _select('Raça', _controller.racaId, _controller.racas, _controller.setRaca),
        _selectLote(femeasOnly: true),
        _texto('Duração da estação (dias)', _controller.duracao, '90', numero: true),
      ],
      9 => const [],
      10 => [
        _selectLote(femeasOnly: true),
        _select('Etapa', _controller.tipoId, _controller.tipos, _controller.setTipo),
        _texto('Sêmen', _controller.semen, 'Opcional'),
        _texto('Responsável', _controller.responsavel, 'Opcional'),
      ],
      11 => [
        _selectLote(femeasOnly: true),
        _select('Resultado', _controller.tipoId, _controller.tipos, _controller.setTipo),
        const _Label('Classificação'),
        _escolha(
          left: 'Precoce',
          right: 'Tardia',
          leftSelected: _controller.classificacao == 1,
          onLeft: () => _controller.setClassificacao(1),
          onRight: () => _controller.setClassificacao(2),
        ),
        const SizedBox(height: 18),
      ],
      13 => [
        _selectLote(femeasOnly: true),
        _texto('Motivo', _controller.motivo, 'Motivo', linhas: 3),
      ],
      14 => [
        _selectPiquete(),
        _select('Tipo de manejo', _controller.tipoId, _controller.tipos, _controller.setTipo),
        const _Label('Uso de insumo'),
        _escolha(
          left: 'Sem insumo',
          right: 'Usar produto',
          leftSelected: !_controller.usarProduto,
          onLeft: () => _controller.setUsarProduto(false),
          onRight: () => _controller.setUsarProduto(true),
        ),
        const SizedBox(height: 18),
        if (_controller.usarProduto) ...[
          _select(
            'Produto',
            _controller.estoqueId,
            _controller.insumos
                .map((item) => ListItemEntity(id: item.id, nome: item.nome))
                .toList(),
            _controller.setEstoque,
          ),
          if (_controller.insumoSelecionado != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Text(
                'Unidade ${_controller.insumoSelecionado!.unidade?.nome ?? ''} · Saldo ${_controller.insumoSelecionado!.qtdTotal ?? 0}',
                style: const TextStyle(
                  color: Color(0xFF313131),
                  fontSize: 13,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          const _Label('Modo de dosagem'),
          _escolha(
            left: 'Por hectare',
            right: 'Área total',
            leftSelected: _controller.tipoDosagem != 4,
            onLeft: () => _controller.setTipoDosagem(3),
            onRight: () => _controller.setTipoDosagem(4),
          ),
          const SizedBox(height: 18),
          _texto('Quantidade', _controller.quantidade, '0', numero: true),
          if (_controller.saldoInsuficienteCampo)
            _erro('Saldo insuficiente no estoque para esta aplicação.')
          else if (_controller.quantidade.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Text(
                'Total ${_controller.quantidadeInteiraCampo} ${_controller.insumoSelecionado?.unidade?.nome ?? ''}',
                style: const TextStyle(
                  color: Color(0xFF3D6B4F),
                  fontSize: 13,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
        _texto('Observações', _controller.obs, 'Detalhes...', linhas: 3),
      ],
      _ => [
        _texto('Observações', _controller.obs, 'Detalhes...', linhas: 3),
      ],
    };
  }

  Widget _selectLote({bool femeasOnly = false}) {
    final lotes = femeasOnly ? _controller.lotesFemea : _controller.lotes;
    return _select(
      femeasOnly ? 'Lote (vacas/novilhas)' : 'Lote',
      _controller.loteId,
      lotes.map((item) => ListItemEntity(id: item.id, nome: item.nome)).toList(),
      _controller.setLote,
    );
  }

  Widget _selectPiquete() {
    return _select(
      'Piquete',
      _controller.piqueteId,
      _controller.piquetes.map((item) => ListItemEntity(id: item.id, nome: item.nome)).toList(),
      _controller.setPiquete,
    );
  }

  Widget _data() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('Data'),
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

  Widget _texto(String label, TextEditingController controller, String hint, {int linhas = 1, bool numero = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        _input(
          controller: controller,
          hint: hint,
          maxLines: linhas,
          keyboardType: numero ? const TextInputType.numberWithOptions(decimal: true) : null,
        ),
      ],
    );
  }

  Widget _select(
    String label,
    int? value,
    List<ListItemEntity> itens,
    ValueChanged<int?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        AppSelectOverlay<int>(
          value: value,
          placeholder: 'Selecionar',
          options: itens.map((item) => AppSelectOption(value: item.id, label: item.nome)).toList(),
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
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

  Widget _escolha({
    required String left,
    required String right,
    required bool leftSelected,
    required VoidCallback onLeft,
    required VoidCallback onRight,
  }) {
    return Row(
      children: [
        Expanded(child: _opcao(left, leftSelected, onLeft)),
        const SizedBox(width: 8),
        Expanded(child: _opcao(right, !leftSelected, onRight)),
      ],
    );
  }

  Widget _opcao(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
            color: selected ? MyColors.colorPrimary : const Color(0xFF313131),
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
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

  Future<void> _salvar() async {
    final erro = await _controller.salvar();
    if (!mounted) {
      return;
    }
    if (erro != null) {
      AppSnackBar.show(context: context, message: erro);
      return;
    }
    AppSnackBar.show(context: context, message: 'Manejo atualizado.', isError: false);
    Navigator.of(context).pop(true);
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
        style: const TextStyle(color: Color(0xFF313131), fontSize: 14, fontFamily: 'Montserrat'),
      ),
    );
  }
}
