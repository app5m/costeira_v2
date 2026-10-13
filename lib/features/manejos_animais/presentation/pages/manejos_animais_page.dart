import 'package:costeira/features/manejos_animais/domain/entities/manejo_animal_lista.dart';
import 'package:costeira/features/manejos_animais/presentation/controllers/listar_manejos_animais_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ManejosAnimaisPage extends StatefulWidget {
  const ManejosAnimaisPage({super.key});

  @override
  State<ManejosAnimaisPage> createState() => _ManejosAnimaisPageState();
}

class _ManejosAnimaisPageState extends State<ManejosAnimaisPage> {
  late final ListarManejosAnimaisController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<ListarManejosAnimaisController>()..init();
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Grupo('Animal'),
            _chips(ManejoAnimalCategoria.lista),
            const _Grupo('Reprodutivo'),
            _chips(ManejoAnimalCategoria.reprodutivo),
            Expanded(child: _lista()),
          ],
        );
      },
    );
  }

  Widget _chips(List<ManejoAnimalCategoria> categorias) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final categoria in categorias)
            FilterChip(
              label: Text(categoria.nome),
              selected: _controller.categoriaId == categoria.id,
              onSelected: (_) => _controller.setCategoria(categoria.id),
              selectedColor: const Color(0xFFD9EDE1),
              checkmarkColor: MyColors.colorPrimary,
            ),
        ],
      ),
    );
  }

  Widget _lista() {
    if (_controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _controller.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              color: Color(0xFF8C8C8C),
            ),
          ),
        ),
      );
    }
    if (_controller.itens.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum manejo nesta categoria.',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            color: Color(0xFF8C8C8C),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _controller.load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _controller.itens.length,
        itemBuilder: (context, index) => _card(_controller.itens[index]),
      ),
    );
  }

  Widget _card(ManejoAnimalListaItem item) {
    final titulo = item.data.isEmpty ? ManejoAnimalCategoria.nomeDe(item.idCategoria) : item.data;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF313131),
            ),
          ),
          if (item.detalhe.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.detalhe,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                color: Color(0xFF6B6B6B),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Grupo extends StatelessWidget {
  const _Grupo(this.titulo);

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(
        titulo,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF8C8C8C),
        ),
      ),
    );
  }
}
