import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/web_empty_state.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_entity.dart';
import 'package:costeira/features/fazendas/presentation/page_controllers/fazendas_list_page_controller.dart';
import 'package:costeira/features/fazendas/presentation/web/fazenda_form_web_dialog.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FazendasWebPage extends StatefulWidget {
  const FazendasWebPage({super.key, this.onFarmChanged});

  final Future<void> Function()? onFarmChanged;

  @override
  State<FazendasWebPage> createState() => _FazendasWebPageState();
}

class _FazendasWebPageState extends State<FazendasWebPage> {
  late final FazendasListPageController _controller;
  int? _selectedFarmId;
  int? _switchingFarmId;

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<FazendasListPageController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final selectedFarmId = await SessionStorage.getSelectedFarmId();
    if (mounted) setState(() => _selectedFarmId = selectedFarmId);
    await _controller.loadInitialData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openForm([FazendaEntity? fazenda]) async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => FazendaFormWebDialog(fazenda: fazenda),
    );
    if (!mounted || result?['success'] != true) return;
    await _controller.reload();
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message:
          result?['message']?.toString() ??
          (fazenda == null
              ? 'Fazenda salva com sucesso.'
              : 'Fazenda atualizada com sucesso.'),
      isError: false,
    );
  }

  Future<void> _reload() async {
    final result = await _controller.reload();
    if (!mounted || result == null || result.isSuccess) return;
    AppSnackBar.show(context: context, message: result.message, isError: true);
  }

  Future<void> _accessFarm(FazendaEntity fazenda) async {
    if (_switchingFarmId != null || fazenda.id == _selectedFarmId) return;
    setState(() => _switchingFarmId = fazenda.id);
    await SessionStorage.saveSelectedFarmId(fazenda.id);
    if (!mounted) return;
    setState(() => _selectedFarmId = fazenda.id);
    AppSnackBar.show(
      context: context,
      message: '${_farmName(fazenda)} selecionada.',
      isError: false,
    );
    await widget.onFarmChanged?.call();
    if (mounted) setState(() => _switchingFarmId = null);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ColoredBox(
          color: Colors.white,
          child: Column(
            children: [
              _toolbar(),
              const Divider(height: 1, color: Color(0xFFE7E4DD)),
              Expanded(child: _body()),
            ],
          ),
        );
      },
    );
  }

  Widget _toolbar() {
    final count = _controller.fazendas.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              count == 1
                  ? '1 fazenda cadastrada'
                  : '$count fazendas cadastradas',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF777777),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Atualizar lista',
            onPressed: _controller.isLoading ? null : _reload,
            icon: const Icon(LucideIcons.refreshCw, size: 19),
            color: MyColors.colorPrimary,
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _controller.isLoading ? null : () => _openForm(),
            icon: const Icon(Icons.add_rounded, size: 19),
            label: const Text('Adicionar'),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              minimumSize: const Size(132, 46),
              backgroundColor: MyColors.colorPrimary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFBFC9C5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    if (_controller.isLoading && _controller.fazendas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.errorMessage != null && _controller.fazendas.isEmpty) {
      return _ErrorState(
        message: _controller.errorMessage!,
        onRetry: _controller.isLoading ? null : _reload,
      );
    }
    if (_controller.fazendas.isEmpty) {
      return WebEmptyState(
        icon: LucideIcons.warehouse,
        title: 'Nenhuma fazenda cadastrada',
        description:
            'Use o botão Adicionar para cadastrar a primeira propriedade.',
        actionLabel: 'Adicionar',
        onAction: () => _openForm(),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        return Scrollbar(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              constraints.maxWidth < 760 ? 16 : 28,
              22,
              constraints.maxWidth < 760 ? 16 : 28,
              32,
            ),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [wide ? _table() : _stackedRows()],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _table() {
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
      child: Column(
        children: [
          const _TableHeader(),
          for (var index = 0; index < _controller.fazendas.length; index++) ...[
            if (index > 0) const Divider(height: 1, color: Color(0xFFE7E4DD)),
            _FarmTableRow(
              fazenda: _controller.fazendas[index],
              selected: _controller.fazendas[index].id == _selectedFarmId,
              switching: _controller.fazendas[index].id == _switchingFarmId,
              onAccess: () => _accessFarm(_controller.fazendas[index]),
              onEdit: () => _openForm(_controller.fazendas[index]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stackedRows() {
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
      child: Column(
        children: [
          for (var index = 0; index < _controller.fazendas.length; index++) ...[
            if (index > 0) const Divider(height: 1, color: Color(0xFFE7E4DD)),
            _FarmStackedRow(
              fazenda: _controller.fazendas[index],
              selected: _controller.fazendas[index].id == _selectedFarmId,
              switching: _controller.fazendas[index].id == _switchingFarmId,
              onAccess: () => _accessFarm(_controller.fazendas[index]),
              onEdit: () => _openForm(_controller.fazendas[index]),
            ),
          ],
        ],
      ),
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
          SizedBox(width: 38),
          SizedBox(width: 12),
          Expanded(flex: 4, child: _HeaderText('Nome')),
          SizedBox(width: 16),
          Expanded(flex: 4, child: _HeaderText('E-mail')),
          SizedBox(width: 16),
          Expanded(flex: 3, child: _HeaderText('Celular')),
          SizedBox(width: 236),
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
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: .35,
        color: Color(0xFF777777),
      ),
    );
  }
}

class _FarmTableRow extends StatelessWidget {
  const _FarmTableRow({
    required this.fazenda,
    required this.selected,
    required this.switching,
    required this.onAccess,
    required this.onEdit,
  });

  final FazendaEntity fazenda;
  final bool selected;
  final bool switching;
  final VoidCallback onAccess;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          const _FarmIcon(),
          const SizedBox(width: 12),
          Expanded(flex: 4, child: _FarmName(fazenda, selected: selected)),
          const SizedBox(width: 16),
          Expanded(flex: 4, child: _ValueText(_value(fazenda.email))),
          const SizedBox(width: 16),
          Expanded(flex: 3, child: _ValueText(_value(fazenda.celular))),
          const SizedBox(width: 16),
          _FarmActions(
            selected: selected,
            switching: switching,
            onAccess: onAccess,
            onEdit: onEdit,
          ),
        ],
      ),
    );
  }
}

class _FarmStackedRow extends StatelessWidget {
  const _FarmStackedRow({
    required this.fazenda,
    required this.selected,
    required this.switching,
    required this.onAccess,
    required this.onEdit,
  });

  final FazendaEntity fazenda;
  final bool selected;
  final bool switching;
  final VoidCallback onAccess;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FarmIcon(),
              const SizedBox(width: 12),
              Expanded(child: _FarmName(fazenda, selected: selected)),
            ],
          ),
          const SizedBox(height: 12),
          _CompactValue(icon: LucideIcons.mail, value: _value(fazenda.email)),
          const SizedBox(height: 5),
          _CompactValue(
            icon: LucideIcons.phone,
            value: _value(fazenda.celular),
          ),
          const SizedBox(height: 14),
          _FarmActions(
            selected: selected,
            switching: switching,
            onAccess: onAccess,
            onEdit: onEdit,
            expanded: true,
          ),
        ],
      ),
    );
  }
}

class _FarmName extends StatelessWidget {
  const _FarmName(this.fazenda, {required this.selected});

  final FazendaEntity fazenda;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _farmName(fazenda),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF313131),
          ),
        ),
        if (selected) ...[
          const SizedBox(height: 4),
          const Text(
            'Fazenda atual',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: MyColors.colorPrimary,
            ),
          ),
        ],
      ],
    );
  }
}

class _FarmActions extends StatelessWidget {
  const _FarmActions({
    required this.selected,
    required this.switching,
    required this.onAccess,
    required this.onEdit,
    this.expanded = false,
  });

  final bool selected;
  final bool switching;
  final VoidCallback onAccess;
  final VoidCallback onEdit;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final access = SizedBox(
      height: 38,
      width: expanded ? null : 124,
      child: ElevatedButton(
        onPressed: selected || switching ? null : onAccess,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          backgroundColor: MyColors.colorPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE4ECE7),
          disabledForegroundColor: MyColors.colorPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: switching
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                selected ? 'Fazenda atual' : 'Acessar',
                maxLines: 1,
                softWrap: false,
              ),
      ),
    );
    final edit = SizedBox(
      height: 38,
      width: expanded ? null : 88,
      child: OutlinedButton.icon(
        onPressed: onEdit,
        icon: const Icon(LucideIcons.pencil, size: 15),
        label: const Text('Editar'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          foregroundColor: MyColors.colorPrimary,
          side: const BorderSide(color: Color(0xFFBFD4C7)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );

    if (expanded) {
      return Row(
        children: [
          Expanded(child: access),
          const SizedBox(width: 8),
          Expanded(child: edit),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [access, const SizedBox(width: 8), edit],
    );
  }
}

class _FarmIcon extends StatelessWidget {
  const _FarmIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0x1400823A),
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Icon(
        LucideIcons.warehouse,
        size: 18,
        color: MyColors.colorPrimary,
      ),
    );
  }
}

class _ValueText extends StatelessWidget {
  const _ValueText(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4F5652),
      ),
    );
  }
}

class _CompactValue extends StatelessWidget {
  const _CompactValue({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF8A8A8A)),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: Color(0xFF777777),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback? onRetry;

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
              size: 38,
              color: Color(0xFFC4473A),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 17),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

String _farmName(FazendaEntity fazenda) =>
    fazenda.nome.trim().isEmpty ? 'Fazenda' : fazenda.nome.trim();

String _value(String value) => value.trim().isEmpty ? 'Não informado' : value;
