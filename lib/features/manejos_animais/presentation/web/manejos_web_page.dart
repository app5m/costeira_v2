import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/web_empty_state.dart';
import 'package:costeira/core/components/web_page_dialog.dart';
import 'package:costeira/features/manejos_animais/domain/entities/manejo_animal_lista.dart';
import 'package:costeira/features/manejos_animais/presentation/controllers/listar_manejos_animais_controller.dart';
import 'package:costeira/features/manejos_animais/presentation/pages/manejo_animal_sessao_page.dart';
import 'package:costeira/features/manejos_animais/presentation/pages/manejo_campo_page.dart';
import 'package:costeira/features/manejos_animais/presentation/pages/manejo_editar_page.dart';
import 'package:costeira/features/manejos_animais/presentation/pages/manejo_reprodutivo_page.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ManejosWebPage extends StatefulWidget {
  const ManejosWebPage({super.key});

  @override
  State<ManejosWebPage> createState() => _ManejosWebPageState();
}

class _ManejosWebPageState extends State<ManejosWebPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ListarManejosAnimaisController _controller;
  final ValueNotifier<int> _revision = ValueNotifier(0);
  int _tabIndex = 0;
  int? _deletingId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _controller = Modular.get<ListarManejosAnimaisController>();
    _controller.addListener(_onControllerChanged);
    _controller.init();
  }

  void _onControllerChanged() {
    if (mounted) _revision.value++;
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _tabController.dispose();
    _revision.dispose();
    super.dispose();
  }

  List<ManejoAnimalCategoria> get _categories => switch (_tabIndex) {
    0 => ManejoAnimalCategoria.lista,
    1 => ManejoAnimalCategoria.reprodutivo,
    _ => ManejoAnimalCategoria.campo,
  };

  void _changeTab(int index) {
    if (_tabIndex == index) return;
    _tabIndex = index;
    _deletingId = null;
    _controller.limpar();
    _revision.value++;
  }

  Future<void> _selectCategory(int id) async {
    await _controller.setCategoria(id);
  }

  Future<void> _reload() async {
    if (_controller.categoriaId == null || _controller.loading) return;
    await _controller.load();
  }

  Future<void> _openCreate() async {
    final (title, page) = switch (_tabIndex) {
      0 => ('Manejo animal', const ManejoAnimalSessaoPage()),
      1 => ('Manejo reprodutivo', const ManejoReprodutivoPage()),
      _ => ('Manejo de campo', const ManejoCampoPage()),
    };
    await showDialog<Object?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WebPageDialog(
        title: title,
        width: 760,
        maxHeight: 840,
        child: Padding(padding: const EdgeInsets.only(bottom: 20), child: page),
      ),
    );
    if (!mounted || _controller.categoriaId == null) return;
    await _controller.load();
  }

  Future<void> _openEdit(ManejoAnimalListaItem item) async {
    if (item.id == null || _controller.excluindo) return;
    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WebPageDialog(
        title: 'Editar ${ManejoAnimalCategoria.nomeDe(item.idCategoria)}',
        width: 700,
        maxHeight: 800,
        child: ManejoEditarPage(item: item),
      ),
    );
    if (!mounted || updated != true) return;
    await _controller.load();
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: 'Manejo atualizado.',
      isError: false,
    );
  }

  Future<void> _confirmDelete(ManejoAnimalListaItem item) async {
    final id = item.id;
    if (id == null || _controller.excluindo) return;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir manejo', style: _dialogTitleStyle),
        content: const Text(
          'Tem certeza que deseja excluir esse manejo permanentemente?',
          style: _dialogBodyStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFC4473A),
              side: const BorderSide(color: Color(0xFFE1B8B2)),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    _deletingId = id;
    _revision.value++;
    final error = await _controller.excluir(id);
    if (mounted) {
      _deletingId = null;
      _revision.value++;
    }
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: error ?? 'Manejo excluído.',
      isError: error != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        children: [
          _tabs(),
          const Divider(height: 1, color: Color(0xFFE7E4DD)),
          ValueListenableBuilder<int>(
            valueListenable: _revision,
            builder: (_, __, ___) => _toolbar(),
          ),
          const Divider(height: 1, color: Color(0xFFE7E4DD)),
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: _revision,
              builder: (_, __, ___) => _body(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: constraints.maxWidth < 570 ? constraints.maxWidth : 570,
            child: TabBar(
              controller: _tabController,
              onTap: _changeTab,
              tabs: const [
                Tab(text: 'Manejo animal'),
                Tab(text: 'Manejo reprodutivo'),
                Tab(text: 'Manejo de campo'),
              ],
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: const Color(0xFF313131),
              unselectedLabelColor: const Color(0xFF8C8C8C),
              indicatorColor: MyColors.colorPrimary2,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _toolbar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final category = _controller.categoriaId;
        final count = _controller.itens.length;
        final caption = category == null
            ? 'Escolha uma categoria'
            : '${count == 1 ? '1 manejo' : '$count manejos'} · '
                  '${ManejoAnimalCategoria.nomeDe(category)}';
        return Padding(
          padding: EdgeInsets.fromLTRB(
            compact ? 16 : 28,
            16,
            compact ? 16 : 28,
            16,
          ),
          child: Row(
            children: [
              if (!compact)
                Expanded(
                  child: Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _toolbarCaptionStyle,
                  ),
                ),
              if (compact)
                Expanded(child: _categorySelector())
              else
                SizedBox(width: 196, child: _categorySelector()),
              const SizedBox(width: 8),
              _ToolbarIconButton(
                isLoading: _controller.loading,
                enabled: category != null && !_controller.loading,
                onPressed: _reload,
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: compact ? 126 : 170,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: _openCreate,
                  icon: const Icon(Icons.add_rounded, size: 19),
                  label: Text(compact ? 'Adicionar' : 'Adicionar manejo'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    backgroundColor: MyColors.colorPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                    textStyle: _buttonTextStyle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _categorySelector() {
    final selected = _controller.categoriaId;
    return AppSelectOverlay<int>(
      value: selected,
      options: [
        for (final category in _categories)
          AppSelectOption(value: category.id, label: category.nome),
      ],
      enabled: !_controller.loading,
      placeholder: 'Categoria',
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      fieldColor: Colors.white,
      menuColor: const Color(0xFFFFFEFB),
      menuMaxHeight: 420,
      adaptiveMenuPlacement: true,
      border: Border.all(color: const Color(0xFFD4D9D1)),
      borderRadius: 9,
      leading: const Icon(
        LucideIcons.slidersHorizontal,
        size: 17,
        color: MyColors.colorPrimary,
      ),
      onChanged: (value) {
        if (value != null) _selectCategory(value);
      },
    );
  }

  Widget _body() {
    final selected = _controller.categoriaId;
    if (selected == null) {
      return const WebEmptyState(
        icon: LucideIcons.slidersHorizontal,
        title: 'Escolha uma categoria',
        description:
            'Selecione uma categoria na barra acima para visualizar os manejos.',
      );
    }

    final content = _content();
    return Stack(
      fit: StackFit.expand,
      children: [
        content,
        if (_controller.loading && _controller.itens.isNotEmpty)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }

  Widget _content() {
    if (_controller.loading && _controller.itens.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.error != null && _controller.itens.isEmpty) {
      return _ErrorState(message: _controller.error!, onRetry: _reload);
    }
    if (_controller.itens.isEmpty) {
      return const WebEmptyState(
        icon: LucideIcons.clipboardList,
        title: 'Nenhum manejo nesta categoria',
        description:
            'Use o botão Adicionar manejo para registrar uma nova atividade.',
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final horizontal = constraints.maxWidth < 760 ? 16.0 : 28.0;
        return Scrollbar(
          child: ListView(
            padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 32),
            children: [wide ? _table() : _stackedRows()],
          ),
        );
      },
    );
  }

  Widget _table() {
    return _ListFrame(
      child: Column(
        children: [
          const _TableHeader(),
          for (var index = 0; index < _controller.itens.length; index++) ...[
            if (index > 0) const Divider(height: 1, color: Color(0xFFE7E4DD)),
            _TableRow(
              item: _controller.itens[index],
              deleting: _deletingId == _controller.itens[index].id,
              actionsEnabled: !_controller.excluindo,
              onEdit: () => _openEdit(_controller.itens[index]),
              onDelete: () => _confirmDelete(_controller.itens[index]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stackedRows() {
    return _ListFrame(
      child: Column(
        children: [
          for (var index = 0; index < _controller.itens.length; index++) ...[
            if (index > 0) const Divider(height: 1, color: Color(0xFFE7E4DD)),
            _StackedRow(
              item: _controller.itens[index],
              deleting: _deletingId == _controller.itens[index].id,
              actionsEnabled: !_controller.excluindo,
              onEdit: () => _openEdit(_controller.itens[index]),
              onDelete: () => _confirmDelete(_controller.itens[index]),
            ),
          ],
        ],
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  const _ToolbarIconButton({
    required this.isLoading,
    required this.enabled,
    required this.onPressed,
  });

  final bool isLoading;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: MyColors.colorPrimary,
          side: const BorderSide(color: Color(0xFFBFD4C7)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(LucideIcons.refreshCw, size: 18),
      ),
    );
  }
}

class _ListFrame extends StatelessWidget {
  const _ListFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E4DD)),
      ),
      child: child,
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F7F3),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: const Row(
        children: [
          Expanded(flex: 2, child: _HeaderText('Data')),
          SizedBox(width: 16),
          Expanded(flex: 5, child: _HeaderText('Detalhe')),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _HeaderText('Lote')),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _HeaderText('Brinco')),
          SizedBox(width: 196),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.item,
    required this.deleting,
    required this.actionsEnabled,
    required this.onEdit,
    required this.onDelete,
  });

  final ManejoAnimalListaItem item;
  final bool deleting;
  final bool actionsEnabled;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 68),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(flex: 2, child: _CellText(_titleFor(item), strong: true)),
            const SizedBox(width: 16),
            Expanded(flex: 5, child: _CellText(_readable(item.detalhe))),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _CellText(_readable(item.lote))),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _CellText(_readable(item.brinco))),
            const SizedBox(width: 8),
            _RowActions(
              deleting: deleting,
              enabled: actionsEnabled && item.id != null,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _StackedRow extends StatelessWidget {
  const _StackedRow({
    required this.item,
    required this.deleting,
    required this.actionsEnabled,
    required this.onEdit,
    required this.onDelete,
  });

  final ManejoAnimalListaItem item;
  final bool deleting;
  final bool actionsEnabled;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_titleFor(item), style: _rowTitleStyle),
          const SizedBox(height: 10),
          _InfoLine(label: 'Detalhe', value: _readable(item.detalhe)),
          const SizedBox(height: 5),
          _InfoLine(label: 'Lote', value: _readable(item.lote)),
          const SizedBox(height: 5),
          _InfoLine(label: 'Brinco', value: _readable(item.brinco)),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: _RowActions(
              deleting: deleting,
              enabled: actionsEnabled && item.id != null,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}

class _RowActions extends StatelessWidget {
  const _RowActions({
    required this.deleting,
    required this.enabled,
    required this.onEdit,
    required this.onDelete,
  });

  final bool deleting;
  final bool enabled;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 188,
      child: Row(
        children: [
          SizedBox(
            width: 88,
            height: 38,
            child: OutlinedButton.icon(
              onPressed: enabled ? onEdit : null,
              icon: const Icon(LucideIcons.pencil, size: 15),
              label: const Text('Editar'),
              style: _editButtonStyle,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 92,
            height: 38,
            child: OutlinedButton(
              onPressed: enabled ? onDelete : null,
              style: _deleteButtonStyle,
              child: deleting
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFC4473A),
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.trash2, size: 15),
                        SizedBox(width: 7),
                        Text('Excluir'),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: _headerTextStyle);
  }
}

class _CellText extends StatelessWidget {
  const _CellText(this.text, {this.strong = false});

  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: strong ? _rowTitleStyle : _cellTextStyle,
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: '$label: ',
        style: _cellTextStyle.copyWith(fontWeight: FontWeight.w600),
        children: [
          TextSpan(
            text: value,
            style: _cellTextStyle.copyWith(fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.alertTriangle,
              size: 36,
              color: Color(0xFFC4473A),
            ),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center, style: _cellTextStyle),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

String _titleFor(ManejoAnimalListaItem item) {
  final data = item.data.trim();
  return data.isNotEmpty
      ? data
      : ManejoAnimalCategoria.nomeDe(item.idCategoria);
}

String _readable(String value) {
  final text = value.trim();
  return text.isEmpty ? '-' : text;
}

const _toolbarCaptionStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 13,
  fontWeight: FontWeight.w600,
  color: Color(0xFF777777),
);

const _buttonTextStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 12,
  fontWeight: FontWeight.w700,
);

const _headerTextStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: Color(0xFF696969),
);

const _rowTitleStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 13,
  fontWeight: FontWeight.w700,
  color: Color(0xFF313131),
);

const _cellTextStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 13,
  color: Color(0xFF5F5F5F),
);

const _dialogTitleStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 17,
  fontWeight: FontWeight.w700,
  color: Color(0xFF313131),
);

const _dialogBodyStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14,
  color: Color(0xFF5F5F5F),
);

final _editButtonStyle = OutlinedButton.styleFrom(
  padding: EdgeInsets.zero,
  foregroundColor: MyColors.colorPrimary,
  side: const BorderSide(color: Color(0xFFBFD4C7)),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  textStyle: _buttonTextStyle,
);

final _deleteButtonStyle = OutlinedButton.styleFrom(
  padding: EdgeInsets.zero,
  foregroundColor: const Color(0xFFC4473A),
  side: const BorderSide(color: Color(0xFFE1B8B2)),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  textStyle: _buttonTextStyle,
);
