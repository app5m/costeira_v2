import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AnimalLotSelectionResult {
  const AnimalLotSelectionResult._({
    this.selectedLotId,
    this.shouldAddLot = false,
  });

  const AnimalLotSelectionResult.selected(int? selectedLotId)
    : this._(selectedLotId: selectedLotId);

  const AnimalLotSelectionResult.addLot() : this._(shouldAddLot: true);

  final int? selectedLotId;
  final bool shouldAddLot;
}

class AnimalLotSelectorField extends StatelessWidget {
  const AnimalLotSelectorField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.isLoading = false,
    this.errorMessage,
  });

  final String label;
  final String value;
  final Future<void> Function() onTap;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
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
            letterSpacing: 0.10,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: value == 'Selecionar lote'
                          ? const Color(0xFF8C8C8C)
                          : const Color(0xFF313131),
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                      letterSpacing: 0.10,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.keyboard_arrow_right,
                        color: Color(0xFF8C8C8C),
                      ),
              ],
            ),
          ),
        ),
        if ((errorMessage ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
        const SizedBox(height: 18),
      ],
    );
  }
}

class AnimalLotSelectionSheet extends StatefulWidget {
  const AnimalLotSelectionSheet({
    super.key,
    required this.lots,
    required this.initialSelectedLotId,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<AnimalLotEntity> lots;
  final int? initialSelectedLotId;
  final bool isLoading;
  final String? errorMessage;

  @override
  State<AnimalLotSelectionSheet> createState() =>
      _AnimalLotSelectionSheetState();
}

class _AnimalLotSelectionSheetState extends State<AnimalLotSelectionSheet> {
  late int? _selectedLotId;
  final TextEditingController _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _selectedLotId = widget.initialSelectedLotId;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<AnimalLotEntity> get _filteredLots {
    final query = _normalize(_search);
    if (query.isEmpty) {
      return widget.lots;
    }

    return widget.lots
        .where((lot) => _normalize(lot.nome).contains(query))
        .toList(growable: false);
  }

  void _onSearchChanged() {
    setState(() {
      _search = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 72,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E2E2),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Selecionar lote',
              style: TextStyle(
                color: Color(0xFF313131),
                fontSize: 20,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Escolha um lote já cadastrado ou adicione um novo.',
              style: TextStyle(
                color: Color(0xFF8C8C8C),
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
            if (!widget.isLoading &&
                (widget.errorMessage ?? '').trim().isEmpty &&
                widget.lots.isNotEmpty) ...[
              _buildSearchField('Buscar lote'),
              const SizedBox(height: 16),
            ],
            Flexible(child: _buildBody(context)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openAddLotPage,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Adicionar lote'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF128977),
                  side: const BorderSide(color: Color(0xFF128977)),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            if (widget.lots.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Modular.to.pop(
                      AnimalLotSelectionResult.selected(_selectedLotId),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF128977),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF128977)),
      );
    }

    if ((widget.errorMessage ?? '').trim().isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(widget.errorMessage!, textAlign: TextAlign.center),
        ),
      );
    }

    if (widget.lots.isEmpty) {
      return const Center(
        child: Text(
          'Você ainda não possui lotes cadastrados.',
          textAlign: TextAlign.center,
        ),
      );
    }

    final lots = _filteredLots;
    if (lots.isEmpty) {
      return const Center(
        child: Text('Nenhum lote encontrado.', textAlign: TextAlign.center),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: lots.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final lot = lots[index];
        final isSelected = _selectedLotId == lot.id;

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _selectedLotId = isSelected ? null : lot.id;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF128977) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEBEBEB)),
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 24),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    lot.nome,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF313131),
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.white : const Color(0xFF8C8C8C),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchField(String hint) {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: Color(0xFF8C8C8C)),
        suffixIcon: _search.trim().isEmpty
            ? null
            : IconButton(
                onPressed: _searchController.clear,
                icon: const Icon(Icons.close, color: Color(0xFF8C8C8C)),
              ),
        filled: true,
        fillColor: const Color(0xFFEBEBEB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  String _normalize(String value) {
    return value.trim().toLowerCase();
  }

  void _openAddLotPage() {
    Modular.to.pop(const AnimalLotSelectionResult.addLot());
  }
}
