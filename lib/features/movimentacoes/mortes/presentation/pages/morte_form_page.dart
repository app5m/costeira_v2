import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/features/movimentacoes/domain/entities/morte_entity.dart';
import 'package:costeira/features/movimentacoes/mortes/presentation/page_controllers/morte_form_page_controller.dart';
import 'package:costeira/features/movimentacoes/mortes/presentation/pages/morte_animais_vinculados_page.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class MorteFormPage extends StatefulWidget {
  const MorteFormPage({super.key, this.morte});

  final MorteEntity? morte;

  @override
  State<MorteFormPage> createState() => _MorteFormPageState();
}

class _MorteFormPageState extends State<MorteFormPage> {
  final MorteFormPageController _pageController =
      Modular.get<MorteFormPageController>();

  @override
  void initState() {
    super.initState();
    _pageController.init(morte: widget.morte);
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
    final day = picked.day.toString().padLeft(2, '0');
    final month = picked.month.toString().padLeft(2, '0');
    _pageController.dataController.text = '$day/$month/${picked.year}';
  }

  Future<void> _openLinkedAnimals() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MorteAnimaisVinculadosPage(
          animais: widget.morte?.animais ?? const [],
        ),
      ),
    );
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
              _pageController.isEdit ? 'Editar baixa' : 'Baixa',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateField(),
                  _buildTipo(),
                  if (!_pageController.isEdit) ...[
                    _buildCategory(),
                    _buildFase(),
                    _buildStatus(),
                    _buildPotreiro(),
                    _buildLote(),
                    if (_pageController.selectedCategoryId != null)
                      _buildGroupBadge(),
                    if (_pageController.canShowEscopo) ...[
                      const Text(
                        'Escopo da ação',
                        style: TextStyle(
                          color: Color(0xFF313131),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _ChoiceRow(
                        leftLabel: 'Lote inteiro',
                        rightLabel: 'Parcial',
                        leftSelected: _pageController.isLoteInteiro,
                        onLeft: () => _pageController.onEscopoChanged(
                          MorteEscopo.loteInteiro,
                        ),
                        onRight: () => _pageController.onEscopoChanged(
                          MorteEscopo.parcial,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_pageController.isLoteInteiro)
                        _buildLoteInteiro()
                      else
                        _buildParcial(),
                    ],
                  ],
                  _buildTextField(
                    controller: _pageController.obsController,
                    label: 'Causa / observações',
                    hint: 'Ex: Tristeza parasitária, causa desconhecida...',
                    maxLines: 3,
                  ),
                  if (_pageController.isEdit) _buildLinkedAnimals(),
                  if (_pageController.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _pageController.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 20),
                  CustomButton(
                    onPressed: _submit,
                    text: _pageController.isEdit ? 'Salvar' : 'Confirmar baixa',
                    enabled:
                        !_pageController.isLoading &&
                        _pageController.isFormValid,
                    isLoading: _pageController.isLoading,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateField() {
    return _buildTextField(
      controller: _pageController.dataController,
      label: 'Data',
      hint: '00/00/0000',
      readOnly: true,
      onTap: _selectDate,
    );
  }

  Widget _buildTipo() {
    return _buildSelect<int>(
      label: 'Tipo de baixa',
      value: _pageController.idCategoria,
      placeholder: 'Selecionar',
      options: MorteFormPageController.tipos
          .map((tipo) => AppSelectOption<int>(value: tipo.id, label: tipo.nome))
          .toList(growable: false),
      onChanged: _pageController.onTipoChanged,
    );
  }

  Widget _buildCategory() {
    return _buildSelect<int>(
      label: 'Categoria',
      value: _pageController.selectedCategoryId ?? -1,
      placeholder: 'Todas',
      options: [
        const AppSelectOption<int>(value: -1, label: 'Todas'),
        ..._pageController.animalCategories.map(
          (item) =>
              AppSelectOption<int>(value: item.id, label: item.nome.trim()),
        ),
      ],
      onChanged: (value) => _pageController.onCategoryChanged(
        value == null || value < 0 ? null : value,
      ),
    );
  }

  Widget _buildFase() {
    final hasCategory = _pageController.selectedCategoryId != null;
    final hasFase = _pageController.hasAnimalSubcategories;
    return _buildSelect<int>(
      label: 'Fase',
      value: _pageController.selectedSubcategoryId ?? -1,
      enabled: hasCategory && hasFase,
      placeholder: !hasCategory
          ? 'Selecione a categoria'
          : hasFase
          ? 'Todas'
          : 'Sem fase',
      options: [
        if (hasFase) const AppSelectOption<int>(value: -1, label: 'Todas'),
        ..._pageController.animalSubcategories.map(
          (item) =>
              AppSelectOption<int>(value: item.id, label: item.nome.trim()),
        ),
      ],
      onChanged: (value) => _pageController.onSubcategoryChanged(
        value == null || value < 0 ? null : value,
      ),
    );
  }

  Widget _buildStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
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

  Widget _buildPotreiro() {
    return _buildSelect<int>(
      label: 'Piquete',
      value: _pageController.selectedPotreiroId ?? -1,
      placeholder: 'Todos os piquetes',
      options: [
        const AppSelectOption<int>(value: -1, label: 'Todos os piquetes'),
        ..._pageController.potreiros.map(
          (item) => AppSelectOption<int>(value: item.id, label: item.nome),
        ),
      ],
      onChanged: (value) => _pageController.onPotreiroChanged(
        value == null || value < 0 ? null : value,
      ),
    );
  }

  Widget _buildLote() {
    return _buildSelect<int>(
      label: 'Lote',
      value: _pageController.selectedLotId,
      placeholder: 'Selecionar lote',
      options: _pageController.lots
          .map((item) => AppSelectOption<int>(value: item.id, label: item.nome))
          .toList(growable: false),
      onChanged: _pageController.onLotChanged,
    );
  }

  Widget _buildGroupBadge() {
    final qtd = _pageController.groupedAnimals.length;
    final cats = _pageController.categoryCounts.entries
        .map((item) => '${item.key} (${item.value})')
        .join(' · ');
    final fases = _pageController.faseCounts.entries
        .map((item) => '${item.key} (${item.value})')
        .join(' · ');
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF7F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$qtd animal(is) disponíveis'
        '${cats.isEmpty ? '' : ' · $cats'}'
        '${fases.isEmpty ? '' : ' · $fases'}'
        '${_pageController.selectedLot == null ? '' : ' · ${_pageController.selectedLot!.nome}'}'
        '${_pageController.selectedPotreiro == null ? '' : ' · ${_pageController.selectedPotreiro!.nome}'}'
        '${_pageController.allBrincados ? ' · Todos brincados' : ''}',
        style: const TextStyle(color: Color(0xFF313131), fontSize: 13),
      ),
    );
  }

  Widget _buildLoteInteiro() {
    final animals = _pageController.groupedAnimals;
    if (animals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 18),
        child: Text(
          'Nenhum animal com brinco neste piquete/lote.',
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
              for (final animal in animals) Chip(label: Text(animal.brinco!)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParcial() {
    final animals = _pageController.groupedAnimals;
    if (animals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 18),
        child: Text(
          'Nenhum animal com brinco neste piquete/lote.',
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
                  '${animal.brinco}'
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

  Widget _buildLinkedAnimals() {
    final count = widget.morte?.qtdAnimais ?? widget.morte?.animais.length ?? 0;
    final hasLinked = widget.morte?.animais.isNotEmpty == true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: hasLinked ? _openLinkedAnimals : null,
        child: Text(
          '$count animais vinculados',
          style: const TextStyle(
            color: MyColors.colorPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSelect<T>({
    required String label,
    required T? value,
    required String placeholder,
    required List<AppSelectOption<T>> options,
    required ValueChanged<T?> onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF313131), fontSize: 14),
        ),
        const SizedBox(height: 6),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
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
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF8C8C8C), fontSize: 14),
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
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? MyColors.colorPrimary : const Color(0xFF5A5A5A),
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
