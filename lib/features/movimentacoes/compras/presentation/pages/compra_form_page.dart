import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/form_accordion.dart';
import 'package:costeira/core/input_formatters/brazilian_currency_input_formatter.dart';
import 'package:costeira/core/input_formatters/fixed_two_decimal_input_formatter.dart';
import 'package:costeira/features/animals/presentation/pages/lotes/add_lote.dart';
import 'package:costeira/features/animals/presentation/widgets/animal_lot_selector.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_entity.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/page_controllers/compra_form_page_controller.dart';
import 'package:costeira/features/movimentacoes/domain/entities/compra_entity.dart';
import 'package:costeira/features/potreiros/presentation/pages/potreiros/protreiro_add.dart';
import 'package:costeira/features/potreiros/presentation/widgets/potreiro_selector.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';

class CompraFormPage extends StatefulWidget {
  const CompraFormPage({super.key, this.compra});

  final CompraEntity? compra;

  @override
  State<CompraFormPage> createState() => _CompraFormPageState();
}

class _CompraFormPageState extends State<CompraFormPage> {
  static const _moneyFormatter = BrazilianCurrencyInputFormatter();
  static const _pesoFormatter = FixedTwoDecimalInputFormatter();

  final CompraFormPageController _pageController =
      Modular.get<CompraFormPageController>();

  @override
  void initState() {
    super.initState();
    _pageController.init(compra: widget.compra);
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

    if (!mounted || result == null) {
      return;
    }

    if (result.shouldAddPotreiro) {
      final created = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(builder: (_) => const PotreiroAdd()),
      );
      if (!mounted) {
        return;
      }
      try {
        await _pageController.reloadPotreiros();
      } catch (_) {}
      if (!mounted) {
        return;
      }
      if (created?['success'] == true) {
        _pageController.selectNewestPotreiro();
        return;
      }
      await _openPotreiroSelection();
      return;
    }
    _pageController.onPotreiroChanged(result.selectedPotreiroId);
  }

  Future<void> _openLotSelection() async {
    if (_pageController.selectedPotreiroId == null) {
      AppSnackBar.show(
        context: context,
        message: 'Selecione o piquete de destino primeiro.',
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

    if (!mounted || result == null) {
      return;
    }

    if (result.shouldAddLot) {
      final created = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(builder: (_) => const AddLote()),
      );
      if (!mounted) {
        return;
      }
      try {
        await _pageController.reloadLots();
      } catch (_) {}
      if (!mounted) {
        return;
      }
      if (created?['success'] == true) {
        _pageController.selectNewestLot();
        return;
      }
      await _openLotSelection();
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
              _pageController.isEdit ? 'Editar compra' : 'Adicionar compra',
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
                              'Cadastre uma fazenda antes de lançar a compra.',
                              style: TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ),
                        FormAccordion(
                          title: 'Identificação',
                          complete: _pageController.isIdentificacaoComplete,
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _pageController.dataController,
                                label: 'Data da compra',
                                hint: '00/00/0000',
                                readOnly: true,
                                onTap: _selectDate,
                              ),
                              if (!_pageController.isEdit) ...[
                                _buildSexo(),
                                _buildCategory(),
                                _buildFase(),
                                _buildRaca(),
                              ],
                            ],
                          ),
                        ),
                        FormAccordion(
                          title: 'Destino',
                          initiallyExpanded: false,
                          complete: _pageController.isDestinoComplete,
                          child: Column(
                            children: [
                              PotreiroSelectorField(
                                label: 'Piquete de destino',
                                value: _pageController.selectedPotreiroLabel,
                                onTap: _openPotreiroSelection,
                                isLoading: _pageController.isLoading,
                                errorMessage: _pageController.errorMessage,
                              ),
                              AnimalLotSelectorField(
                                label: 'Lote de destino',
                                value: _pageController.selectedLotLabel,
                                onTap: _openLotSelection,
                                isLoading: _pageController.isLoading,
                                errorMessage: _pageController.errorMessage,
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
                        FormAccordion(
                          title: 'Fornecedor',
                          initiallyExpanded: false,
                          complete: _pageController.isFornecedorComplete,
                          child: Column(
                            children: [
                              _ChoiceRow(
                                leftLabel: 'Selecionar existente',
                                rightLabel: 'Cadastrar novo',
                                leftSelected:
                                    _pageController.fornecedorMode ==
                                    CompraFornecedorMode.existente,
                                onLeft: () =>
                                    _pageController.onFornecedorModeChanged(
                                      CompraFornecedorMode.existente,
                                    ),
                                onRight: () =>
                                    _pageController.onFornecedorModeChanged(
                                      CompraFornecedorMode.novo,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              if (_pageController.fornecedorMode ==
                                  CompraFornecedorMode.existente)
                                _buildFornecedorSelect()
                              else
                                _buildNovoFornecedor(),
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
                            ],
                          ),
                        ),
                        if (!_pageController.isEdit)
                          FormAccordion(
                            title: 'Cadastro',
                            initiallyExpanded: false,
                            complete: _pageController.isCadastroComplete,
                            child: Column(
                              children: [
                                const _ChoiceRow(
                                  leftLabel: 'Fazenda própria',
                                  rightLabel: 'Terceiro (investidor)',
                                  leftSelected: true,
                                  rightEnabled: false,
                                ),
                                const SizedBox(height: 18),
                                _ChoiceRow(
                                  leftLabel: 'Individual (por brinco)',
                                  rightLabel: 'Lote (sem brincos)',
                                  leftSelected: _pageController.isIndividual,
                                  onLeft: () =>
                                      _pageController.onTipoCadastroChanged(
                                        CompraFormPageController
                                            .tipoCadastroIndividual,
                                      ),
                                  onRight: () =>
                                      _pageController.onTipoCadastroChanged(
                                        CompraFormPageController
                                            .tipoCadastroLote,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                if (_pageController.isIndividual)
                                  _buildIndividualSection()
                                else
                                  _buildLoteSection(),
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
                      : 'Salvar entrada',
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

  Widget _buildSexo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sexo',
          style: TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 6),
        _ChoiceRow(
          leftLabel: 'Fêmea',
          rightLabel: 'Macho',
          leftSelected: _pageController.selectedSexo == 2,
          rightSelected: _pageController.selectedSexo == 1,
          onLeft: () => _pageController.onAnimalSexoChanged(2),
          onRight: () => _pageController.onAnimalSexoChanged(1),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildCategory() {
    final hasSexo = _pageController.selectedSexo != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoria',
          style: TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 6),
        AppSelectOverlay<int>(
          value: _pageController.selectedAnimalCategoryId,
          enabled: hasSexo,
          placeholder: hasSexo
              ? 'Selecione a categoria'
              : 'Selecione o sexo primeiro',
          options: _pageController.animalCategories
              .map(
                (item) =>
                    AppSelectOption(value: item.id, label: item.nome.trim()),
              )
              .toList(growable: false),
          onChanged: _pageController.onAnimalCategoryChanged,
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildFase() {
    final hasCategory = _pageController.selectedAnimalCategoryId != null;
    final hasFase = _pageController.hasAnimalSubcategories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fase do animal',
          style: TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 6),
        AppSelectOverlay<int>(
          value: _pageController.selectedAnimalSubcategoryId,
          enabled: hasCategory && hasFase,
          placeholder: !hasCategory
              ? 'Selecione a categoria primeiro'
              : hasFase
              ? 'Selecione a fase'
              : 'Sem fase',
          options: _pageController.animalSubcategories
              .map(
                (item) =>
                    AppSelectOption(value: item.id, label: item.nome.trim()),
              )
              .toList(growable: false),
          onChanged: _pageController.onAnimalSubcategoryChanged,
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildRaca() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Raça',
          style: TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 6),
        AppSelectOverlay<int>(
          value: _pageController.selectedAnimalBaseRacialId,
          placeholder: 'Selecione...',
          options: _pageController.basesRaciais
              .map(
                (item) =>
                    AppSelectOption(value: item.id, label: item.nome.trim()),
              )
              .toList(growable: false),
          onChanged: _pageController.onAnimalBaseRacialChanged,
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildFornecedorSelect() {
    final empty = _pageController.fornecedores.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fornecedor',
          style: TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 6),
        if (empty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Nenhum fornecedor cadastrado nesta fazenda.',
              style: TextStyle(
                color: Color(0xFF8C8C8C),
                fontSize: 13,
                fontFamily: 'Montserrat',
              ),
            ),
          )
        else
          AppSelectOverlay<int>(
            value: _pageController.selectedFornecedorId,
            placeholder: 'Selecione...',
            options: _pageController.fornecedores
                .map(
                  (item) => AppSelectOption(value: item.id, label: item.nome),
                )
                .toList(growable: false),
            onChanged: _pageController.onFornecedorChanged,
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _pageController.onFornecedorModeChanged(
              CompraFornecedorMode.novo,
            ),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Adicionar fornecedor'),
            style: OutlinedButton.styleFrom(
              foregroundColor: MyColors.colorPrimary,
              side: const BorderSide(color: MyColors.colorPrimary),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildNovoFornecedor() {
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

  Widget _buildTipoValor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de valor',
          style: TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 6),
        AppSelectOverlay<String>(
          value: _pageController.selectedTipoCompra,
          placeholder: 'Selecione',
          options: const [
            AppSelectOption(value: 'cabeça', label: 'Por cabeça (R\$)'),
            AppSelectOption(value: 'kg', label: 'Por kg (R\$)'),
          ],
          onChanged: _pageController.onTipoCompraChanged,
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  List<(String, String)> _footerLines() {
    final summary = _pageController.summary;
    final qtd = _pageController.isIndividual
        ? _pageController.animalRows.length
        : int.tryParse(_pageController.loteQtdController.text.trim()) ?? 0;
    final peso = summary.pesoMedio <= 0
        ? '—'
        : '${summary.pesoMedio.toStringAsFixed(1).replaceAll('.', ',')} kg';
    final total = summary.custoRealAnimal <= 0 || qtd <= 0
        ? '—'
        : BrazilianCurrency.format(summary.custoRealAnimal * qtd);
    return [
      ('Qtd', qtd <= 0 ? '—' : '$qtd'),
      ('Peso méd.', peso),
      ('Total', total),
    ];
  }

  Widget _buildIndividualSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _pageController.quantidadeController,
          label: 'Quantidade de animais',
          hint: 'Ex: 5',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        if (_pageController.animalRows.isNotEmpty) ...[
          const Row(
            children: [
              SizedBox(
                width: 28,
                child: Text('#', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Expanded(
                child: Text(
                  'Brinco',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Peso (kg)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                width: 88,
                child: Text(
                  'Valor',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < _pageController.animalRows.length; i++)
            _buildAnimalRow(i),
        ],
      ],
    );
  }

  Widget _buildAnimalRow(int index) {
    final row = _pageController.animalRows[index];
    final value = _pageController.animalLineValue(row);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text('${index + 1}')),
          Expanded(
            child: TextField(
              controller: row.brincoController,
              decoration: _compactDecoration('0001'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: row.pesoController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: const [_pesoFormatter],
              decoration: _compactDecoration('kg'),
            ),
          ),
          SizedBox(
            width: 88,
            child: Text(
              value <= 0 ? '—' : BrazilianCurrency.format(value),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoteSection() {
    return Column(
      children: [
        _buildTextField(
          controller: _pageController.loteQtdController,
          label: 'Nº de cabeças',
          hint: 'Ex: 30',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        _buildTextField(
          controller: _pageController.lotePesoTotalController,
          label: 'Peso total (kg)',
          hint: 'Calculado',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: const [_pesoFormatter],
        ),
        _buildTextField(
          controller: _pageController.lotePesoMedioController,
          label: 'Peso médio (kg)',
          hint: 'Calculado',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: const [_pesoFormatter],
        ),
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
            fontWeight: FontWeight.w400,
            height: 1.50,
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
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
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
    this.rightSelected,
    this.rightEnabled = true,
    this.onLeft,
    this.onRight,
  });

  final String leftLabel;
  final String rightLabel;
  final bool leftSelected;
  final bool? rightSelected;
  final bool rightEnabled;
  final VoidCallback? onLeft;
  final VoidCallback? onRight;

  @override
  Widget build(BuildContext context) {
    final rightIsSelected = rightSelected ?? !leftSelected;
    return Row(
      children: [
        Expanded(
          child: _ChoiceChip(
            label: leftLabel,
            selected: leftSelected,
            enabled: true,
            onTap: onLeft,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ChoiceChip(
            label: rightLabel,
            selected: rightIsSelected,
            enabled: rightEnabled,
            onTap: onRight,
          ),
        ),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.enabled,
    this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final background = !enabled
        ? const Color(0xFFF3F3F3)
        : selected
        ? const Color(0xFFD9EDE1)
        : const Color(0xFFF5F5F5);
    final border = !enabled
        ? const Color(0xFFE0E0E0)
        : selected
        ? MyColors.colorPrimary
        : const Color(0xFFE2E2E2);
    final textColor = !enabled
        ? const Color(0xFFB0B0B0)
        : selected
        ? MyColors.colorPrimary
        : const Color(0xFF5A5A5A);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: selected ? 2 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selected) ...[
              Icon(Icons.check, size: 16, color: textColor),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
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
