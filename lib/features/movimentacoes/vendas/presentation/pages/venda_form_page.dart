import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/form_accordion.dart';
import 'package:costeira/core/input_formatters/brazilian_currency_input_formatter.dart';
import 'package:costeira/core/input_formatters/fixed_two_decimal_input_formatter.dart';
import 'package:costeira/features/animals/presentation/widgets/animal_lot_selector.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/presentation/page_controllers/venda_form_page_controller.dart';
import 'package:costeira/features/potreiros/presentation/widgets/potreiro_selector.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';

class VendaFormPage extends StatefulWidget {
  const VendaFormPage({super.key, this.venda});

  final VendaEntity? venda;

  @override
  State<VendaFormPage> createState() => _VendaFormPageState();
}

class _VendaFormPageState extends State<VendaFormPage> {
  static const _moneyFormatter = BrazilianCurrencyInputFormatter();
  static const _pesoFormatter = FixedTwoDecimalInputFormatter();

  final VendaFormPageController _pageController =
      Modular.get<VendaFormPageController>();

  @override
  void initState() {
    super.initState();
    _pageController.init(venda: widget.venda);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final result = await _pageController.submit();
    if (!mounted) {
      return;
    }
    if (result.isSuccess) {
      Navigator.pop(context, {'success': true, 'message': result.message});
      return;
    }
    AppSnackBar.show(context: context, message: result.message, isError: true);
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null) {
      return;
    }
    _pageController.dataController.text =
        '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
  }

  Future<void> _openPotreiroSelection() async {
    final result = await showModalBottomSheet<PotreiroSelectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        top: false,
        child: PotreiroSelectionSheet(
          potreiros: _pageController.potreiros,
          initialSelectedPotreiroId: _pageController.selectedPotreiroId,
          isLoading: _pageController.isLoading,
          errorMessage: _pageController.errorMessage,
        ),
      ),
    );
    if (!mounted || result == null || result.shouldAddPotreiro) {
      return;
    }
    _pageController.onPotreiroChanged(result.selectedPotreiroId);
  }

  Future<void> _openLotSelection() async {
    if (_pageController.selectedPotreiroId == null) {
      AppSnackBar.show(
        context: context,
        message: 'Selecione o piquete primeiro.',
        isError: true,
      );
      return;
    }

    final result = await showModalBottomSheet<AnimalLotSelectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        top: false,
        child: AnimalLotSelectionSheet(
          lots: _pageController.lots,
          initialSelectedLotId: _pageController.selectedLotId,
          isLoading: _pageController.isLoading,
          errorMessage: _pageController.errorMessage,
        ),
      ),
    );
    if (!mounted || result == null || result.shouldAddLot) {
      return;
    }
    _pageController.onLotChanged(result.selectedLotId);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pageController,
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
              _pageController.isEdit ? 'Editar venda' : 'Saída · Venda',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_pageController.showFarmSelector)
                          _buildFarmSelector()
                        else if (_pageController.fazendas.isEmpty &&
                            !_pageController.isLoadingFarms)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Cadastre uma fazenda antes de lançar a venda.',
                              style: TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ),
                        FormAccordion(
                          title: 'Comprador',
                          complete: _pageController.isCompradorComplete,
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _pageController.dataController,
                                label: 'Data da venda',
                                hint: '00/00/0000',
                                readOnly: true,
                                onTap: _selectDate,
                              ),
                              _ChoiceRow(
                                leftLabel: 'Selecionar existente',
                                rightLabel: 'Cadastrar novo',
                                leftSelected:
                                    _pageController.compradorMode ==
                                    VendaCompradorMode.existente,
                                onLeft: () =>
                                    _pageController.onCompradorModeChanged(
                                      VendaCompradorMode.existente,
                                    ),
                                onRight: () =>
                                    _pageController.onCompradorModeChanged(
                                      VendaCompradorMode.novo,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              if (_pageController.compradorMode ==
                                  VendaCompradorMode.existente)
                                _buildCompradorSelect()
                              else
                                _buildNovoComprador(),
                            ],
                          ),
                        ),
                        if (!_pageController.isEdit)
                          FormAccordion(
                            title: 'Grupo',
                            initiallyExpanded: false,
                            complete: _pageController.isGrupoComplete,
                            child: Column(
                              children: [
                                _buildCategory(),
                                _buildFase(),
                                _buildStatus(),
                                if (_pageController.canListAnimals)
                                  _buildGroupBadge(),
                              ],
                            ),
                          ),
                        if (!_pageController.isEdit)
                          FormAccordion(
                            title: 'Escopo e pesagem',
                            initiallyExpanded: true,
                            complete: _pageController.isEscopoComplete,
                            child: Column(
                              children: [
                                PotreiroSelectorField(
                                  label: 'Piquete',
                                  value: _pageController.selectedPotreiroLabel,
                                  onTap: _openPotreiroSelection,
                                  isLoading: _pageController.isLoading,
                                  errorMessage: _pageController.errorMessage,
                                ),
                                AnimalLotSelectorField(
                                  label: 'Lote',
                                  value: _pageController.selectedLotLabel,
                                  onTap: _openLotSelection,
                                  isLoading: _pageController.isLoading,
                                  errorMessage: _pageController.errorMessage,
                                ),
                                _ChoiceRow(
                                  leftLabel: 'Loteiro',
                                  rightLabel: 'Parcial',
                                  leftSelected: _pageController.isLoteiro,
                                  onLeft: () => _pageController.onEscopoChanged(
                                    VendaEscopo.loteiro,
                                  ),
                                  onRight: () => _pageController
                                      .onEscopoChanged(VendaEscopo.parcial),
                                ),
                                const SizedBox(height: 12),
                                if (_pageController.isLoteiro)
                                  _buildLoteiroPreview()
                                else
                                  _buildParcialPicker(),
                                _buildPesagem(),
                              ],
                            ),
                          ),
                        FormAccordion(
                          title: 'Valores',
                          initiallyExpanded: false,
                          complete: _pageController.isValoresComplete,
                          child: Column(
                            children: [
                              if (!_pageController.isEdit) _buildTipoValor(),
                              _buildTextField(
                                controller:
                                    _pageController.valorUnitarioController,
                                label: _pageController.valorUnitarioLabel,
                                hint: 'R\$ 0,00',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: const [_moneyFormatter],
                              ),
                              if (!_pageController.isEdit)
                                _buildReadOnlyValue(
                                  label: 'Peso médio (kg)',
                                  value: _pageController.pesoMedioSaida <= 0
                                      ? '—'
                                      : _pageController.pesoMedioSaida
                                            .toStringAsFixed(1)
                                            .replaceAll('.', ','),
                                ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller:
                                          _pageController.valorFreteController,
                                      label: 'Frete total (R\$)',
                                      hint: 'R\$ 0,00',
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: const [_moneyFormatter],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _pageController
                                          .valorComissaoController,
                                      label: 'Comissão total (R\$)',
                                      hint: 'R\$ 0,00',
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: const [_moneyFormatter],
                                    ),
                                  ),
                                ],
                              ),
                              _buildTextField(
                                controller: _pageController.obsController,
                                label: 'Observações',
                                hint: 'Anotações gerais...',
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                        if (_pageController.errorMessage != null)
                          Text(
                            _pageController.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                FormStickyFooter(
                  lines: _footerLines(),
                  buttonText: _pageController.isEdit
                      ? 'Salvar'
                      : 'Confirmar venda',
                  enabled: _pageController.isFormValid,
                  isLoading: _pageController.isLoading,
                  onSubmit: _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFarmSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fazenda',
          style: TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 6),
        AppSelectOverlay<int>(
          value: _pageController.selectedFarmId,
          placeholder: 'Selecione a fazenda',
          options: [
            for (final FazendaEntity farm in _pageController.fazendas)
              AppSelectOption(
                value: farm.id,
                label: farm.nome.isEmpty ? 'Fazenda ${farm.id}' : farm.nome,
              ),
          ],
          onChanged: _pageController.onFarmChanged,
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildCompradorSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comprador',
          style: TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 6),
        if (_pageController.compradores.isEmpty)
          const Text(
            'Nenhum comprador cadastrado. Cadastre um novo.',
            style: TextStyle(color: Color(0xFF8C8C8C), fontSize: 13),
          )
        else
          AppSelectOverlay<int>(
            value: _pageController.selectedCompradorId,
            placeholder: 'Selecione...',
            options: _pageController.compradores
                .map(
                  (item) => AppSelectOption(value: item.id, label: item.nome),
                )
                .toList(growable: false),
            onChanged: _pageController.onCompradorChanged,
          ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildNovoComprador() {
    return Column(
      children: [
        _buildTextField(
          controller: _pageController.novoNomeController,
          label: 'Nome',
          hint: 'Nome do novo cadastro',
        ),
        _buildTextField(
          controller: _pageController.novoDocumentoController,
          label: 'CPF/CNPJ',
          hint: 'Opcional',
          keyboardType: TextInputType.number,
        ),
        _buildTextField(
          controller: _pageController.novoContatoController,
          label: 'Contato',
          hint: 'Telefone / e-mail',
        ),
      ],
    );
  }

  Widget _buildCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoria',
          style: TextStyle(color: Color(0xFF313131), fontSize: 14),
        ),
        const SizedBox(height: 6),
        AppSelectOverlay<int>(
          value: _pageController.selectedCategoryId,
          placeholder: 'Todas as categorias',
          options: [
            const AppSelectOption(value: -1, label: 'Todas as categorias'),
            ..._pageController.animalCategories.map(
              (item) =>
                  AppSelectOption(value: item.id, label: item.nome.trim()),
            ),
          ],
          onChanged: (value) => _pageController.onCategoryChanged(
            value == null || value < 0 ? null : value,
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildFase() {
    final hasCategory = _pageController.selectedCategoryId != null;
    final hasFase = _pageController.hasAnimalSubcategories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fase',
          style: TextStyle(color: Color(0xFF313131), fontSize: 14),
        ),
        const SizedBox(height: 6),
        AppSelectOverlay<int>(
          value: _pageController.selectedSubcategoryId,
          enabled: hasCategory && hasFase,
          placeholder: !hasCategory
              ? 'Selecione a categoria e fase'
              : hasFase
              ? 'Todas as fases'
              : 'Sem fase',
          options: [
            if (hasFase)
              const AppSelectOption(value: -1, label: 'Todas as fases'),
            ..._pageController.animalSubcategories.map(
              (item) =>
                  AppSelectOption(value: item.id, label: item.nome.trim()),
            ),
          ],
          onChanged: (value) => _pageController.onSubcategoryChanged(
            value == null || value < 0 ? null : value,
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status (múltiplo)',
          style: TextStyle(color: Color(0xFF313131), fontSize: 14),
        ),
        const SizedBox(height: 6),
        if (!_pageController.canSelectStatus)
          const Text(
            'Selecione categoria e fase',
            style: TextStyle(color: Color(0xFF8C8C8C), fontSize: 13),
          )
        else if (!_pageController.hasStatusOptions)
          const Text(
            'Sem status para esta combinação',
            style: TextStyle(color: Color(0xFF8C8C8C), fontSize: 13),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final status in _pageController.availableStatuses)
                FilterChip(
                  label: Text(status),
                  selected: _pageController.selectedStatuses.contains(status),
                  onSelected: (_) => _pageController.toggleStatus(status),
                  selectedColor: const Color(0xFFD9EDE1),
                  checkmarkColor: MyColors.colorPrimary,
                ),
            ],
          ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildGroupBadge() {
    final qtd = _pageController.groupedAnimals.length;
    final cats = _pageController.categoryCounts.entries
        .map((item) => '${item.key} (${item.value})')
        .join(', ');
    final fases = _pageController.faseCounts.entries
        .map((item) => '${item.key} (${item.value})')
        .join(', ');
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF7F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$qtd animal(is) disponível(is)'
        '${cats.isEmpty ? '' : ' · $cats'}'
        '${fases.isEmpty ? '' : ' · $fases'}'
        '${_pageController.selectedLot == null ? '' : ' · ${_pageController.selectedLot!.nome}'}'
        '${_pageController.selectedPotreiro == null ? '' : ' · ${_pageController.selectedPotreiro!.nome}'}'
        '${_pageController.allBrincados ? ' · Todos brincados' : ''}',
        style: const TextStyle(color: Color(0xFF313131), fontSize: 13),
      ),
    );
  }

  Widget _buildLoteiroPreview() {
    if (!_pageController.canListAnimals) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 18),
        child: Text(
          'Selecione piquete e lote acima para listar os animais.',
          style: TextStyle(color: Color(0xFF8C8C8C), fontSize: 13),
        ),
      );
    }
    final animals = _pageController.groupedAnimals;
    if (animals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 18),
        child: Text(
          'Nenhum animal com brinco neste piquete/lote'
          ' (ou filtros do Grupo excluíram todos).',
          style: TextStyle(color: Color(0xFF8C8C8C), fontSize: 13),
        ),
      );
    }
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
            'Serão incluídos ${animals.length} animal(is) identificado(s):',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final animal in animals)
                Chip(
                  label: Text(
                    animal.brinco?.trim().isNotEmpty == true
                        ? animal.brinco!
                        : '#${animal.id}',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParcialPicker() {
    if (!_pageController.canListAnimals) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 18),
        child: Text(
          'Selecione piquete e lote acima para listar os animais.',
          style: TextStyle(color: Color(0xFF8C8C8C), fontSize: 13),
        ),
      );
    }
    final animals = _pageController.groupedAnimals;
    if (animals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 18),
        child: Text(
          'Nenhum animal com brinco neste piquete/lote'
          ' (ou filtros do Grupo excluíram todos).',
          style: TextStyle(color: Color(0xFF8C8C8C), fontSize: 13),
        ),
      );
    }
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
              onPressed: _pageController.selectAllParcial,
              child: const Text('Todos'),
            ),
            TextButton(
              onPressed: _pageController.clearParcial,
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
                label: Text(
                  '${animal.brinco?.trim().isNotEmpty == true ? animal.brinco : '#${animal.id}'}'
                  '${animal.peso == null ? '' : '  ${animal.peso!.toStringAsFixed(0)}kg'}',
                ),
                selected: _pageController.isParcialSelected(animal.id),
                onSelected: (_) =>
                    _pageController.toggleParcialAnimal(animal.id),
                selectedColor: const Color(0xFFD9EDE1),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 18),
          child: Text(
            '${_pageController.scopedAnimals.length} de ${animals.length} animal(is) selecionado(s)',
            style: const TextStyle(color: Color(0xFF8C8C8C), fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildPesagem() {
    final rows = _pageController.pesagemRows;
    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 18),
        child: Text(
          'Selecione os animais acima para registrar os pesos.',
          style: TextStyle(color: Color(0xFF8C8C8C), fontSize: 13),
        ),
      );
    }
    return Column(
      children: [
        const Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'Brinco',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
            Expanded(
              child: Text(
                'Últ. peso',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Peso saída',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
            SizedBox(
              width: 44,
              child: Text(
                'GMD',
                textAlign: TextAlign.right,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final row in rows) _buildPesagemRow(row),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPesagemRow(VendaPesagemRow row) {
    final gmd = _pageController.gmdLabel(row);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              row.animal.brinco?.trim().isNotEmpty == true
                  ? row.animal.brinco!
                  : '#${row.animal.id}',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              row.animal.peso == null
                  ? '—'
                  : '${row.animal.peso!.toStringAsFixed(1)} kg',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6C7278)),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: row.pesoSaidaController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: const [_pesoFormatter],
              decoration: _compactDecoration('kg'),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              gmd ?? '—',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipoValor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de valor',
          style: TextStyle(color: Color(0xFF313131), fontSize: 14),
        ),
        const SizedBox(height: 6),
        AppSelectOverlay<String>(
          value: _pageController.selectedTipoValor,
          placeholder: 'Selecione',
          options: const [
            AppSelectOption(value: 'cabeça', label: 'Por cabeça (R\$)'),
            AppSelectOption(value: 'kg', label: 'Por kg vivo (R\$/kg)'),
          ],
          onChanged: _pageController.onTipoValorChanged,
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  List<(String, String)> _footerLines() {
    final qtd = _pageController.scopedAnimals.length;
    final peso = _pageController.pesoTotalSaida;
    final total = _pageController.valorTotalEstimado;
    return [
      ('Qtd', qtd <= 0 ? '—' : '$qtd'),
      (
        'Peso',
        peso <= 0 ? '—' : '${peso.toStringAsFixed(1).replaceAll('.', ',')} kg',
      ),
      ('Total', total <= 0 ? '—' : BrazilianCurrency.format(total)),
    ];
  }

  Widget _buildReadOnlyValue({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEBEBEB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(color: Color(0xFF313131), fontSize: 14),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  InputDecoration _compactDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFEBEBEB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFEBEBEB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
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
        Expanded(
          child: _ChoiceChip(
            label: leftLabel,
            selected: leftSelected,
            onTap: onLeft,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ChoiceChip(
            label: rightLabel,
            selected: !leftSelected,
            onTap: onRight,
          ),
        ),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selected) ...[
              const Icon(Icons.check, size: 16, color: MyColors.colorPrimary),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected
                      ? MyColors.colorPrimary
                      : const Color(0xFF5A5A5A),
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
