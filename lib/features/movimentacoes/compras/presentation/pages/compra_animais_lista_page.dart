import 'package:costeira/features/movimentacoes/domain/entities/compra_animal_entity.dart';
import 'package:costeira/features/movimentacoes/compras/domain/entities/compra_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/page_controllers/compra_form_page_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class CompraAnimaisListaPage extends StatelessWidget {
  const CompraAnimaisListaPage.draft({
    super.key,
    required CompraFormPageController pageController,
  }) : _pageController = pageController,
       _savedAnimais = null;

  const CompraAnimaisListaPage.saved({
    super.key,
    required List<CompraAnimalEntity> animais,
  }) : _pageController = null,
       _savedAnimais = animais;

  final CompraFormPageController? _pageController;
  final List<CompraAnimalEntity>? _savedAnimais;

  @override
  Widget build(BuildContext context) {
    final animais = _buildItems();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          animais.length == 1
              ? '1 animal vinculado'
              : '${animais.length} animais vinculados',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: animais.isEmpty
          ? const Center(child: Text('Nenhum animal vinculado.'))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: animais.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final animal = animais[index];
                return _AnimalListTile(index: index + 1, animal: animal);
              },
            ),
    );
  }

  List<_AnimalListItem> _buildItems() {
    final pageController = _pageController;
    if (pageController != null) {
      return pageController.animais
          .map(
            (animal) => _AnimalListItem.fromDraft(
              animal,
              categoryLabel: pageController.animalCategoryLabel(
                animal.appAnimaisCategoriasId,
              ),
              subcategoryLabel: pageController.animalSubcategoryLabel(
                animal.appAnimaisSubcategoriasId,
              ),
              baseRacialLabel: pageController.animalBaseRacialLabel(
                animal.utBasesRaciaisId,
              ),
            ),
          )
          .toList(growable: false);
    }

    return (_savedAnimais ?? const [])
        .map(_AnimalListItem.fromSaved)
        .toList(growable: false);
  }
}

class _AnimalListTile extends StatelessWidget {
  const _AnimalListTile({required this.index, required this.animal});

  final int index;
  final _AnimalListItem animal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEBEBEB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4EC),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: Color(0xFF00823A),
                    fontSize: 12,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  animal.brinco,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF313131),
                    fontSize: 15,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Sexo', value: animal.sexoLabel),
          _InfoRow(label: 'Categoria', value: animal.categoryLabel),
          if (animal.subcategoryLabel != null)
            _InfoRow(label: 'Subcategoria', value: animal.subcategoryLabel!),
          if (animal.baseRacialLabel != null)
            _InfoRow(label: 'Base racial', value: animal.baseRacialLabel!),
          _InfoRow(label: 'Peso total', value: '${animal.pesoTotal} kg'),
        ],
      ),
    );
  }
}

class _AnimalListItem {
  const _AnimalListItem({
    required this.brinco,
    required this.sexoLabel,
    required this.categoryLabel,
    required this.pesoTotal,
    this.subcategoryLabel,
    this.baseRacialLabel,
  });

  factory _AnimalListItem.fromDraft(
    CompraUpsertAnimalEntity animal, {
    required String categoryLabel,
    required String? subcategoryLabel,
    required String? baseRacialLabel,
  }) {
    return _AnimalListItem(
      brinco: animal.brinco.trim().isEmpty ? 'Sem brinco' : animal.brinco,
      sexoLabel: animal.sexo == 1 ? 'Macho' : 'Fêmea',
      categoryLabel: categoryLabel,
      subcategoryLabel: subcategoryLabel,
      baseRacialLabel: baseRacialLabel,
      pesoTotal: animal.pesoTotal,
    );
  }

  factory _AnimalListItem.fromSaved(CompraAnimalEntity animal) {
    return _AnimalListItem(
      brinco: animal.brinco?.trim().isNotEmpty == true
          ? animal.brinco!.trim()
          : 'Sem brinco',
      sexoLabel: animal.sexo == 1 ? 'Macho' : 'Fêmea',
      categoryLabel: animal.categoria?.nome.trim().isNotEmpty == true
          ? animal.categoria!.nome.trim()
          : 'Categoria ${animal.appAnimaisCategoriasId}',
      subcategoryLabel: _optionalLabel(animal.subcategoria?.nome),
      baseRacialLabel: _optionalLabel(animal.baseRacial?.nome),
      pesoTotal: animal.pesoTotal?.toStringAsFixed(2) ?? '-',
    );
  }

  final String brinco;
  final String sexoLabel;
  final String categoryLabel;
  final String? subcategoryLabel;
  final String? baseRacialLabel;
  final String pesoTotal;
}

String? _optionalLabel(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 106,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8C8C8C),
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF313131),
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
