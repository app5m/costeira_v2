import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/sub_user_flag.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_kind.dart';
import 'package:costeira/features/cadastros/presentation/page_controllers/parceiros_list_page_controller.dart';
import 'package:costeira/features/cadastros/presentation/web/parceiro_form_web_dialog.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ParceirosListWebDialog extends StatefulWidget {
  const ParceirosListWebDialog({super.key, required this.kind});

  final ParceiroKind kind;

  @override
  State<ParceirosListWebDialog> createState() => _ParceirosListWebDialogState();
}

class _ParceirosListWebDialogState extends State<ParceirosListWebDialog> {
  late final ParceirosListPageController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<ParceirosListPageController>();
    _controller.init(widget.kind);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.loadInitialData();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openForm([ParceiroEntity? parceiro]) async {
    final farmId = _controller.selectedFarmId ?? parceiro?.appFazendasId;
    if (farmId == null) {
      _message('Cadastre uma fazenda antes.');
      return;
    }
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ParceiroFormWebDialog(
        kind: widget.kind,
        appFazendasId: farmId,
        parceiro: parceiro,
      ),
    );
    if (!mounted || result?['success'] != true) return;
    await _controller.reload();
    if (!mounted) return;
    _message(
      result?['message']?.toString() ?? 'Cadastro salvo com sucesso.',
      isError: false,
    );
  }

  Future<void> _confirmDelete(ParceiroEntity parceiro) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: !_controller.isDeleting,
      builder: (dialogContext) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Excluir ${widget.kind.singular.toLowerCase()}?',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Tem certeza que deseja excluir ${parceiro.nome}?',
            style: const TextStyle(fontFamily: 'Montserrat'),
          ),
          actions: [
            TextButton(
              onPressed: _controller.isDeleting
                  ? null
                  : () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _controller.isDeleting
                  ? null
                  : () async {
                      final result = await _controller.deleteParceiro(parceiro);
                      if (!dialogContext.mounted) return;
                      Navigator.of(dialogContext).pop(result.isSuccess);
                      if (mounted) {
                        _message(result.message, isError: !result.isSuccess);
                      }
                    },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFC4473A),
                foregroundColor: Colors.white,
              ),
              child: Text(_controller.isDeleting ? 'Excluindo...' : 'Excluir'),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && mounted) setState(() {});
  }

  void _message(String message, {bool isError = true}) {
    AppSnackBar.show(context: context, message: message, isError: isError);
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final narrow = viewport.width < 620;
    final height = (viewport.height - 48).clamp(320.0, 760.0);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.all(narrow ? 8 : 24),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: SizedBox(
          width: 720,
          height: height,
          child: Column(
            children: [
              _header(narrow),
              const Divider(height: 1, color: Color(0xFFE7E4DD)),
              Expanded(child: _body(narrow)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(bool narrow) {
    final canAdd = _controller.selectedFarmId != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(narrow ? 16 : 22, 10, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.kind.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF252525),
              ),
            ),
          ),
          if (canAdd)
            ElevatedButton.icon(
              onPressed: _controller.isLoading ? null : () => _openForm(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(narrow ? 'Adicionar' : 'Adicionar'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                minimumSize: Size(narrow ? 108 : 124, 42),
                backgroundColor: MyColors.colorPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Fechar',
            onPressed: _controller.isDeleting
                ? null
                : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _body(bool narrow) {
    if (_controller.isLoading &&
        _controller.fazendas.isEmpty &&
        _controller.parceiros.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        if (_controller.fazendas.isNotEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(
              narrow ? 16 : 22,
              18,
              narrow ? 16 : 22,
              14,
            ),
            child: narrow
                ? Column(
                    children: [
                      _farmSelector(),
                      const SizedBox(height: 12),
                      _nameFilter(),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _farmSelector()),
                      const SizedBox(width: 12),
                      Expanded(child: _nameFilter()),
                    ],
                  ),
          ),
        Expanded(child: _list()),
      ],
    );
  }

  Widget _farmSelector() {
    return AppSelectOverlay<int>(
      value: _controller.selectedFarmId,
      placeholder: 'Selecionar fazenda',
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      options: [
        for (final farm in _controller.fazendas)
          AppSelectOption(
            value: farm.id,
            label: farm.nome.isEmpty ? 'Fazenda ${farm.id}' : farm.nome,
          ),
      ],
      enabled: !_controller.isLoading,
      leading: const Icon(
        LucideIcons.warehouse,
        size: 18,
        color: MyColors.colorPrimary,
      ),
      onChanged: (value) {
        if (value != null) _controller.selectFarm(value);
      },
    );
  }

  Widget _nameFilter() {
    return SizedBox(
      height: 52,
      child: TextField(
        controller: _controller.nomeController,
        textAlignVertical: TextAlignVertical.center,
        decoration: const InputDecoration(
          hintText: 'Filtrar por nome',
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          prefixIcon: Icon(LucideIcons.search, size: 18),
          prefixIconConstraints: BoxConstraints(minWidth: 48, minHeight: 52),
        ),
      ),
    );
  }

  Widget _list() {
    if (_controller.fazendas.isEmpty) {
      return const _MessageState(
        icon: LucideIcons.warehouse,
        message:
            'Cadastre uma fazenda para gerenciar fornecedores e compradores.',
      );
    }
    if (_controller.errorMessage != null && _controller.parceiros.isEmpty) {
      return _MessageState(
        icon: LucideIcons.alertTriangle,
        message: _controller.errorMessage!,
        actionLabel: 'Tentar novamente',
        onAction: _controller.reload,
      );
    }
    if (_controller.isLoading && _controller.parceiros.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.parceiros.isEmpty) {
      return _MessageState(
        icon: widget.kind == ParceiroKind.fornecedor
            ? LucideIcons.truck
            : LucideIcons.shoppingBag,
        message: 'Nenhum ${widget.kind.singular.toLowerCase()} cadastrado.',
      );
    }
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(22, 4, 30, 24),
        itemCount: _controller.parceiros.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final parceiro = _controller.parceiros[index];
          return _ParceiroRow(
            parceiro: parceiro,
            kind: widget.kind,
            onEdit: () => _openForm(parceiro),
            onDelete: () => _confirmDelete(parceiro),
          );
        },
      ),
    );
  }
}

class _ParceiroRow extends StatelessWidget {
  const _ParceiroRow({
    required this.parceiro,
    required this.kind,
    required this.onEdit,
    required this.onDelete,
  });

  final ParceiroEntity parceiro;
  final ParceiroKind kind;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE7E4DD)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0x1400823A),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  kind == ParceiroKind.fornecedor
                      ? LucideIcons.truck
                      : LucideIcons.shoppingBag,
                  size: 19,
                  color: MyColors.colorPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parceiro.nome.isEmpty ? kind.singular : parceiro.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF313131),
                      ),
                    ),
                    SubUserFlag(nome: parceiro.subUsuarioNome),
                    const SizedBox(height: 4),
                    Text(
                      parceiro.isPessoaFisica
                          ? 'Pessoa física'
                          : 'Pessoa jurídica',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Color(0xFF777777),
                      ),
                    ),
                    if (parceiro.email.isNotEmpty)
                      Text(
                        parceiro.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Color(0xFF777777),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Excluir',
                onPressed: onDelete,
                icon: const Icon(
                  LucideIcons.trash2,
                  size: 18,
                  color: Color(0xFFC4473A),
                ),
              ),
              const Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: Color(0xFF8C8C8C),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: MyColors.colorPrimary),
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
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
