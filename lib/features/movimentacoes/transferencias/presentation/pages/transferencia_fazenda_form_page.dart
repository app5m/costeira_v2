import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_fazenda_list_item.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/page_controllers/transferencia_fazenda_form_page_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TransferenciaFazendaFormPage extends StatefulWidget {
  const TransferenciaFazendaFormPage({super.key, this.item});

  final TransferenciaFazendaListItem? item;

  @override
  State<TransferenciaFazendaFormPage> createState() =>
      _TransferenciaFazendaFormPageState();
}

class _TransferenciaFazendaFormPageState
    extends State<TransferenciaFazendaFormPage> {
  final TransferenciaFazendaFormPageController _pageController =
      Modular.get<TransferenciaFazendaFormPageController>();

  @override
  void initState() {
    super.initState();
    _pageController.init(item: widget.item);
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
    final initial = _parseDate(_pageController.dataController.text) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
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

  DateTime? _parseDate(String value) {
    final parts = value.split('/');
    if (parts.length != 3) {
      return null;
    }
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return null;
    }
    return DateTime(year, month, day);
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
              _pageController.isEdit
                  ? 'Editar transferência'
                  : 'Transferência enviada',
              style: TextStyle(
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
                  Text(
                    _pageController.isEdit
                        ? 'Altera data, GTA e fazenda de destino. Os animais ficam os mesmos.'
                        : 'O animal vai para outra fazenda do mesmo titular. O caixa não muda. O custo continua no histórico.',
                    style: const TextStyle(color: Color(0xFF3D6B4F), fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  _buildDestino(),
                  _buildDocumento(),
                  _buildTextField(
                    controller: _pageController.dataController,
                    label: 'Data da transferência',
                    hint: '00/00/0000',
                    readOnly: true,
                    onTap: _selectDate,
                  ),
                  _buildTextField(
                    controller: _pageController.gtaController,
                    label: 'GTA / documento de transporte',
                    hint: 'Ex: GTA 12345/2026',
                  ),
                  if (!_pageController.isEdit) ...[
                    const Text(
                      'Selecionar animais',
                      style: TextStyle(
                        color: Color(0xFF313131),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                          TransferenciaFazendaEscopo.loteInteiro,
                        ),
                        onRight: () => _pageController.onEscopoChanged(
                          TransferenciaFazendaEscopo.parcial,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_pageController.isLoteInteiro)
                        _buildLoteInteiro()
                      else
                        _buildParcial(),
                    ],
                    _buildCusto(),
                  ],
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
                    text: _pageController.isEdit
                        ? 'Salvar'
                        : 'Confirmar transferência',
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

  AppSelectOption<int>? get _missingDestinoOption {
    final item = _pageController.editing;
    final id = _pageController.selectedDestinoId;
    if (item == null || id == null) {
      return null;
    }
    if (_pageController.fazendasDestino.any((farm) => farm.id == id)) {
      return null;
    }
    final nome = item.fazendaDestino?.nome ?? 'Destino';
    return AppSelectOption<int>(value: id, label: nome);
  }

  Widget _buildDestino() {
    return _buildSelect<int>(
      label: 'Fazenda de destino',
      value: _pageController.selectedDestinoId,
      placeholder: 'Selecionar fazenda do mesmo titular',
      options: [
        ..._pageController.fazendasDestino.map(
          (farm) => AppSelectOption<int>(value: farm.id, label: farm.nome),
        ),
        if (_missingDestinoOption != null) _missingDestinoOption!,
      ],
      onChanged: _pageController.onDestinoChanged,
    );
  }

  Widget _buildDocumento() {
    final documento = _pageController.selectedDestinoDocumento;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CPF / CNPJ do titular',
            style: TextStyle(color: Color(0xFF313131), fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            documento.isEmpty
                ? 'Deve ser o mesmo titular desta fazenda'
                : documento,
            style: const TextStyle(color: Color(0xFF313131), fontSize: 15),
          ),
        ],
      ),
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
          (item) => AppSelectOption<int>(value: item.id, label: item.nome.trim()),
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
          (item) => AppSelectOption<int>(value: item.id, label: item.nome.trim()),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Selecione os animais', style: TextStyle(fontSize: 13)),
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
                label: Text(animal.brinco ?? ''),
                selected: _pageController.isParcialSelected(animal.id),
                onSelected: (_) => _pageController.toggleParcialAnimal(animal.id),
              ),
          ],
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildCusto() {
    final qtd = _pageController.scopedAnimals.length;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF7F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Custo',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            'Custo por animal ${_pageController.custoPorAnimalLabel} · Total ${_pageController.custoTotalLabel} · $qtd cab.',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sem custo por animal. Enviamos R\$ 0,00.',
            style: TextStyle(color: Color(0xFF8C8C8C), fontSize: 12),
          ),
        ],
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
        Text(label, style: const TextStyle(color: Color(0xFF313131), fontSize: 14)),
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
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF313131), fontSize: 14)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
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
        Expanded(child: _chip(leftLabel, leftSelected, onLeft)),
        const SizedBox(width: 8),
        Expanded(child: _chip(rightLabel, !leftSelected, onRight)),
      ],
    );
  }

  Widget _chip(String label, bool selected, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFD9EDE1) : const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? MyColors.colorPrimary : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
