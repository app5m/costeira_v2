import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/core/components/form_accordion.dart';
import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/manejos_animais/domain/entities/manejo_animal_lista.dart';
import 'package:costeira/features/manejos_animais/presentation/page_controllers/manejo_reprodutivo_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ManejoReprodutivoPage extends StatefulWidget {
  const ManejoReprodutivoPage({super.key});

  @override
  State<ManejoReprodutivoPage> createState() => _ManejoReprodutivoPageState();
}

class _ManejoReprodutivoPageState extends State<ManejoReprodutivoPage> {
  late final ManejoReprodutivoController _controller;
  bool _gradeAberta = true;

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<ManejoReprodutivoController>()..init();
    _controller.addListener(_sync);
  }

  void _sync() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_sync);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Manejo reprodutivo',
          style: TextStyle(
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
                FormAccordion(
                  title: _titulo,
                  expanded: _gradeAberta,
                  complete: _controller.painel == ManejoReprodutivoPainel.nenhum ? null : true,
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
                        _Acao(
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
                if (_controller.painel == ManejoReprodutivoPainel.entrada) ..._entrada(),
                if (_controller.painel == ManejoReprodutivoPainel.retirada) ..._retirada(),
                if (_controller.painel == ManejoReprodutivoPainel.iatf) ..._iatf(),
                if (_controller.painel == ManejoReprodutivoPainel.diagnostico) ..._diagnostico(),
                if (_controller.painel == ManejoReprodutivoPainel.aborto) ..._aborto(),
              ],
            ),
    );
  }

  String get _titulo {
    for (final item in _acoes) {
      if (item.$1 == _controller.painel) {
        return item.$2;
      }
    }
    return 'Escolher ação';
  }

  static const _acoes = [
    (ManejoReprodutivoPainel.entrada, 'Entrada de touro', LucideIcons.logIn),
    (ManejoReprodutivoPainel.retirada, 'Retirada de touro', LucideIcons.logOut),
    (ManejoReprodutivoPainel.iatf, 'IATF', LucideIcons.syringe),
    (ManejoReprodutivoPainel.diagnostico, 'Diagnóstico', LucideIcons.stethoscope),
    (ManejoReprodutivoPainel.aborto, 'Aborto', LucideIcons.heartOff),
  ];

  List<Widget> _entrada() {
    final lotes = _controller.lotesFemea;
    return [
      const SizedBox(height: 8),
      _data(),
      const _Label('Brinco do touro'),
      _input(controller: _controller.brinco, hint: 'Ex: 1500'),
      if (_controller.buscando)
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: LinearProgressIndicator(minHeight: 2),
        ),
      if (_controller.touros.isNotEmpty) _touros(),
      _select(
        'Raça',
        _controller.racaId,
        _controller.racas.map((item) => AppSelectOption(value: item.id, label: item.nome)).toList(),
        _controller.setRaca,
      ),
      _select(
        'Lote (vacas/novilhas)',
        _controller.loteId,
        lotes
            .map((lote) => AppSelectOption(value: lote.id, label: _controller.rotuloLote(lote)))
            .toList(),
        _controller.setLote,
      ),
      if (lotes.isEmpty)
        const Padding(
          padding: EdgeInsets.only(bottom: 18),
          child: Text(
            'Nenhum lote de fêmeas.',
            style: TextStyle(color: Color(0xFF8C8C8C), fontSize: 13, fontFamily: 'Montserrat'),
          ),
        ),
      const _Label('Duração da estação (dias)'),
      _input(
        controller: _controller.dias,
        hint: '90',
        keyboardType: TextInputType.number,
      ),
      CustomButton(
        text: 'Iniciar estação',
        enabled: _controller.podeRegistrarEntrada,
        isLoading: _controller.saving,
        onPressed: _registrar,
      ),
    ];
  }

  List<Widget> _retirada() {
    return [
      const SizedBox(height: 8),
      _data(),
      if (_controller.carregandoEstacoes)
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: LinearProgressIndicator(minHeight: 2),
        ),
      if (!_controller.carregandoEstacoes && _controller.estacoes.isEmpty)
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Nenhuma estação de monta ativa nesta data.',
            style: TextStyle(color: Color(0xFF8C8C8C), fontSize: 13, fontFamily: 'Montserrat'),
          ),
        ),
      for (final estacao in _controller.estacoes) _cardEstacao(estacao),
    ];
  }

  Widget _cardEstacao(ManejoAnimalListaItem estacao) {
    final linhas = <String>[
      if (estacao.data.isNotEmpty) 'Entrada: ${estacao.data}',
      if (estacao.lote.isNotEmpty) 'Lote: ${estacao.lote}',
      if (estacao.duracao.isNotEmpty) 'Duração: ${estacao.duracao} dias',
      if (estacao.brinco.isNotEmpty) 'Brinco: ${estacao.brinco}',
      if (estacao.lote.isEmpty &&
          estacao.duracao.isEmpty &&
          estacao.brinco.isEmpty &&
          estacao.detalhe.isNotEmpty)
        estacao.detalhe,
    ];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final linha in linhas)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                linha,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  color: Color(0xFF313131),
                ),
              ),
            ),
          if (estacao.id != null)
            CustomButton(
              text: 'Encerrar estação',
              enabled: !_controller.saving,
              isLoading: _controller.saving,
              onPressed: () => _salvar(
                () => _controller.encerrarEstacao(estacao.id!),
                'Estação encerrada.',
                reabrir: false,
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _iatf() {
    return [
      const SizedBox(height: 8),
      _data(),
      ..._lote(aviso: true),
      _select(
        'Etapa',
        _controller.etapaId,
        _controller.etapasIatf
            .map((item) => AppSelectOption(value: item.id, label: item.nome))
            .toList(),
        _controller.setEtapa,
      ),
      if (_controller.etapasIatf.isEmpty)
        const Padding(
          padding: EdgeInsets.only(bottom: 18),
          child: Text(
            'Nenhuma etapa de IATF na lista.',
            style: TextStyle(color: Color(0xFF8C8C8C), fontSize: 13, fontFamily: 'Montserrat'),
          ),
        ),
      const _Label('Sêmen utilizado (touro genético)'),
      _input(controller: _controller.semen, hint: 'Ex: Touro PO 0099 — Angus'),
      const _Label('Responsável'),
      _input(controller: _controller.responsavel, hint: 'Nome do veterinário/inseminador'),
      CustomButton(
        text: 'Registrar etapa',
        enabled: _controller.podeRegistrarIatf,
        isLoading: _controller.saving,
        onPressed: () => _salvar(_controller.registrarIatf, 'Etapa registrada.'),
      ),
    ];
  }

  List<Widget> _diagnostico() {
    return [
      const SizedBox(height: 8),
      _data(),
      ..._lote(aviso: true),
      const _Label('Quantidade de animais avaliados'),
      _input(
        controller: _controller.quantidade,
        hint: 'Ex: 10',
        keyboardType: TextInputType.number,
      ),
      const _Label('Resultado'),
      if (_controller.resultadosDiagnostico.isEmpty)
        const Padding(
          padding: EdgeInsets.only(bottom: 18),
          child: Text(
            'Nenhum resultado na lista.',
            style: TextStyle(color: Color(0xFF8C8C8C), fontSize: 13, fontFamily: 'Montserrat'),
          ),
        )
      else
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tipo in _controller.resultadosDiagnostico)
                ChoiceChip(
                  label: Text(tipo.nome),
                  selected: _controller.resultadoId == tipo.id,
                  onSelected: (_) => _controller.setResultado(tipo.id),
                  selectedColor: const Color(0xFFD9EDE1),
                ),
            ],
          ),
        ),
      if (_controller.resultadoPrenha) ...[
        _select(
          'Classificação',
          _controller.classificacao,
          const [
            AppSelectOption(value: 1, label: 'Precoce (~30 dias)'),
            AppSelectOption(value: 2, label: 'Tardia (~60 dias)'),
          ],
          _controller.setClassificacao,
        ),
        if (_controller.mesPrevisto != null) ...[
          const _Label('Mês previsto do parto'),
          _leitura(_controller.mesPrevisto!),
        ],
      ],
      CustomButton(
        text: 'Registrar diagnóstico',
        enabled: _controller.podeRegistrarDiagnostico,
        isLoading: _controller.saving,
        onPressed: () => _salvar(_controller.registrarDiagnostico, 'Diagnóstico registrado.'),
      ),
    ];
  }

  List<Widget> _aborto() {
    return [
      const SizedBox(height: 8),
      _data(),
      ..._lote(),
      const _Label('Brinco do animal (opcional)'),
      _input(controller: _controller.brinco, hint: 'Ex: 0432'),
      if (_controller.buscando)
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: LinearProgressIndicator(minHeight: 2),
        ),
      if (_controller.touros.isNotEmpty) _animaisAborto(),
      const _Label('Motivo'),
      _input(controller: _controller.motivo, hint: 'Ex: Trauma, doença infecciosa, estresse térmico'),
      CustomButton(
        text: 'Registrar aborto',
        enabled: _controller.podeRegistrarAborto,
        isLoading: _controller.saving,
        onPressed: () => _salvar(_controller.registrarAborto, 'Aborto registrado.'),
      ),
    ];
  }

  List<Widget> _lote({bool aviso = false}) {
    final lotes = _controller.lotesFemea;
    return [
      _select(
        'Lote (vacas/novilhas)',
        _controller.loteId,
        lotes
            .map((lote) => AppSelectOption(value: lote.id, label: _controller.rotuloLote(lote)))
            .toList(),
        _controller.setLote,
      ),
      if (lotes.isEmpty)
        const Padding(
          padding: EdgeInsets.only(bottom: 18),
          child: Text(
            'Nenhum lote de fêmeas.',
            style: TextStyle(color: Color(0xFF8C8C8C), fontSize: 13, fontFamily: 'Montserrat'),
          ),
        ),
      if (aviso) _avisoLote(),
    ];
  }

  Widget _avisoLote() {
    final lote = _controller.loteSelecionado;
    if (lote == null || lote.temBrinco || lote.animalsCount == 0) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9EDE1)),
      ),
      child: Text(
        'Este lote não possui identificação individual por brinco. O manejo será aplicado ao lote inteiro (${lote.animalsCount} animal(is)).',
        style: const TextStyle(color: Color(0xFF313131), fontSize: 13, fontFamily: 'Montserrat'),
      ),
    );
  }

  Widget _animaisAborto() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final animal in _controller.touros)
            FilterChip(
              label: Text(_rotuloTouro(animal)),
              selected: _controller.animalId == animal.id,
              onSelected: (_) => _controller.selecionarAnimal(animal),
              selectedColor: const Color(0xFFD9EDE1),
              checkmarkColor: MyColors.colorPrimary,
            ),
        ],
      ),
    );
  }

  Widget _leitura(String texto) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: const TextStyle(color: Color(0xFF8C8C8C), fontSize: 14, fontFamily: 'Montserrat'),
      ),
    );
  }

  Widget _touros() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final animal in _controller.touros)
            FilterChip(
              label: Text(_rotuloTouro(animal)),
              selected: _controller.touroId == animal.id,
              onSelected: (_) => _controller.selecionarTouro(animal),
              selectedColor: const Color(0xFFD9EDE1),
              checkmarkColor: MyColors.colorPrimary,
            ),
        ],
      ),
    );
  }

  String _rotuloTouro(AnimalEntity animal) {
    final brinco = animal.brinco?.trim();
    final nome = (brinco == null || brinco.isEmpty) ? '#${animal.id}' : brinco;
    final categoria = animal.categoria?.nome.trim() ?? '';
    if (categoria.isEmpty) {
      return nome;
    }
    return '$nome · $categoria';
  }

  Future<void> _registrar() {
    return _salvar(_controller.registrarEntrada, 'Entrada de touro registrada.');
  }

  Future<void> _salvar(
    Future<String?> Function() acao,
    String sucesso, {
    bool reabrir = true,
  }) async {
    final erro = await acao();
    if (!mounted) {
      return;
    }
    if (erro != null) {
      AppSnackBar.show(context: context, message: erro);
      return;
    }
    if (reabrir) {
      setState(() => _gradeAberta = true);
    }
    AppSnackBar.show(context: context, message: sucesso, isError: false);
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

  Widget _select(
    String label,
    int? value,
    List<AppSelectOption<int>> options,
    ValueChanged<int?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        AppSelectOverlay<int>(
          value: value,
          placeholder: 'Selecionar',
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
    bool readOnly = false,
    TextInputType? keyboardType,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
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

  Widget _erro(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        texto,
        style: const TextStyle(color: Colors.red, fontSize: 12, fontFamily: 'Montserrat'),
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
        style: const TextStyle(color: Color(0xFF313131), fontSize: 14, fontFamily: 'Montserrat'),
      ),
    );
  }
}

class _Acao extends StatelessWidget {
  const _Acao({
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
