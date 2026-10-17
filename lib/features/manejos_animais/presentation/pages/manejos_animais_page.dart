import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/form_accordion.dart';
import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:costeira/features/manejos_animais/domain/entities/manejo_animal_lista.dart';
import 'package:costeira/features/manejos_animais/presentation/controllers/listar_manejos_animais_controller.dart';
import 'package:costeira/features/manejos_animais/presentation/pages/manejo_editar_page.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum _GrupoFiltro { animal, reprodutivo, campo }

class ManejosAnimaisPage extends StatefulWidget {
  const ManejosAnimaisPage({super.key});

  @override
  State<ManejosAnimaisPage> createState() => _ManejosAnimaisPageState();
}

class _ManejosAnimaisPageState extends State<ManejosAnimaisPage> {
  late final ListarManejosAnimaisController _controller;
  _GrupoFiltro? _grupo;
  bool _opcoesAbertas = true;

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
        final grupo = _grupo;
        if (grupo == null) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _cardGrupo(
                titulo: 'Manejo animal',
                descricao: 'Pesagem, sanitário, nutrição e outros',
                icon: LucideIcons.scale,
                onTap: () => _abrir(_GrupoFiltro.animal),
              ),
              _cardGrupo(
                titulo: 'Manejo reprodutivo',
                descricao: 'Entrada, IATF, diagnóstico e aborto',
                icon: LucideIcons.heart,
                onTap: () => _abrir(_GrupoFiltro.reprodutivo),
              ),
              _cardGrupo(
                titulo: 'Manejo de campo',
                descricao: 'Adubação, calagem, roçada e outros',
                icon: LucideIcons.sprout,
                onTap: () => _abrir(_GrupoFiltro.campo),
              ),
            ],
          );
        }
        final categorias = _categorias(grupo);
        final escolhida = _controller.categoriaId;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _voltar(grupo),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: FormAccordion(
                title: escolhida == null
                    ? 'Escolher'
                    : ManejoAnimalCategoria.nomeDe(escolhida),
                expanded: _opcoesAbertas,
                complete: escolhida == null ? null : true,
                onToggle: () =>
                    setState(() => _opcoesAbertas = !_opcoesAbertas),
                child: Column(
                  children: [
                    for (final categoria in categorias)
                      _opcao(categoria, selecionada: escolhida == categoria.id),
                  ],
                ),
              ),
            ),
            Expanded(
              child: escolhida == null ? const SizedBox.shrink() : _lista(),
            ),
          ],
        );
      },
    );
  }

  void _abrir(_GrupoFiltro grupo) {
    setState(() {
      _grupo = grupo;
      _opcoesAbertas = true;
    });
    _controller.limpar();
  }

  void _escolher(int id) {
    setState(() => _opcoesAbertas = false);
    _controller.setCategoria(id);
  }

  List<ManejoAnimalCategoria> _categorias(_GrupoFiltro grupo) {
    return switch (grupo) {
      _GrupoFiltro.animal => ManejoAnimalCategoria.lista,
      _GrupoFiltro.reprodutivo => ManejoAnimalCategoria.reprodutivo,
      _GrupoFiltro.campo => ManejoAnimalCategoria.campo,
    };
  }

  String _titulo(_GrupoFiltro grupo) {
    return switch (grupo) {
      _GrupoFiltro.animal => 'Manejo animal',
      _GrupoFiltro.reprodutivo => 'Manejo reprodutivo',
      _GrupoFiltro.campo => 'Manejo de campo',
    };
  }

  Widget _cardGrupo({
    required String titulo,
    required String descricao,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFFF7F8F8),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9EDE1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: MyColors.colorPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF313131),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        descricao,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Color(0xFF8C8C8C),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF8C8C8C)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _voltar(_GrupoFiltro grupo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
      child: TextButton.icon(
        onPressed: () => setState(() => _grupo = null),
        icon: const Icon(
          Icons.arrow_back_ios,
          size: 14,
          color: Color(0xFF313131),
        ),
        label: Text(
          _titulo(grupo),
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF313131),
          ),
        ),
      ),
    );
  }

  Widget _opcao(ManejoAnimalCategoria categoria, {required bool selecionada}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selecionada ? const Color(0xFFD9EDE1) : const Color(0xFFF7F8F8),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => _escolher(categoria.id),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    categoria.nome,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selecionada
                          ? MyColors.colorPrimary
                          : const Color(0xFF313131),
                    ),
                  ),
                ),
                if (selecionada)
                  Icon(Icons.check, size: 18, color: MyColors.colorPrimary),
              ],
            ),
          ),
        ),
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
    final titulo = item.data.isEmpty
        ? ManejoAnimalCategoria.nomeDe(item.idCategoria)
        : item.data;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
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
          ),
          IconButton(
            tooltip: 'Editar',
            onPressed: item.id == null ? null : () => _editar(item),
            icon: SvgPicture.asset(
              'icon/square-pen.svg',
              width: 18,
              height: 18,
            ),
          ),
          IconButton(
            tooltip: 'Excluir',
            onPressed: item.id == null ? null : () => _confirmarExclusao(item),
            icon: SvgPicture.asset('icon/trash.svg', width: 18, height: 18),
          ),
        ],
      ),
    );
  }

  Future<void> _editar(ManejoAnimalListaItem item) async {
    final atualizou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ManejoEditarPage(item: item)),
    );
    if (atualizou == true) {
      await _controller.load();
    }
  }

  Future<void> _confirmarExclusao(ManejoAnimalListaItem item) async {
    final id = item.id;
    if (id == null) {
      return;
    }
    final confirmar = await _showDeleteConfirmation();
    if (confirmar != true || !mounted) {
      return;
    }
    final erro = await _controller.excluir(id);
    if (!mounted) {
      return;
    }
    AppSnackBar.show(
      context: context,
      message: erro ?? 'Manejo excluído.',
      isError: erro != null,
    );
  }

  Future<bool?> _showDeleteConfirmation() {
    if (kIsWeb) {
      return showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => WebDialogFrame(
          title: 'Excluir manejo',
          width: 480,
          maxHeight: 340,
          bodyPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: _deleteConfirmationContent(showTitle: false),
        ),
      );
    }

    return showModalBottomSheet<bool>(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        top: false,
        child: _deleteConfirmationContent(showTitle: true),
      ),
    );
  }

  Widget _deleteConfirmationContent({required bool showTitle}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        mainAxisSize: showTitle ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showTitle) ...[
            const Text(
              'Excluir manejo',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
          ],
          const Text(
            'Tem certeza que deseja excluir esse manejo permanentemente?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: Color(0xFF8692A8),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Excluir',
                style: TextStyle(fontFamily: 'Montserrat', color: Colors.red),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                color: Color(0xFF313131),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
