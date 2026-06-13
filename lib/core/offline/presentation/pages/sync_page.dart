import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/offline/presentation/controllers/sync_controller.dart';
import 'package:costeira/core/offline/sync/sync_item.dart';
import 'package:costeira/core/offline/sync/sync_status.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  late final SyncController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<SyncController>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.load());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _syncNow() async {
    await _controller.syncNow();
    if (!mounted) {
      return;
    }

    final message = _controller.message;
    if (message == null || message.isEmpty) {
      return;
    }

    AppSnackBar.show(
      context: context,
      message: message,
      isError: !_controller.isOnline || _controller.errorCount > 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return RefreshIndicator(
          color: MyColors.colorPrimary,
          onRefresh: _controller.load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _StatusCard(controller: _controller),
              const SizedBox(height: 16),
              _SummaryRow(controller: _controller),
              const SizedBox(height: 16),
              _SyncButton(controller: _controller, onPressed: _syncNow),

              const SizedBox(height: 20),
              if (!_controller.isOnline) ...[
                const _InfoBanner(
                  title: 'Sem conexão para sincronizar',
                  message: 'Conecte-se a internet para enviar as alterações pendentes.',
                  isError: true,
                ),
                const SizedBox(height: 16),
              ],
              if (_controller.errorCount > 0) ...[
                const _InfoBanner(
                  title: 'Alguns itens não puderam ser sincronizados',
                  message: 'Os itens com erro ficam salvos no aparelho para uma nova tentativa.',
                  isError: true,
                ),
                const SizedBox(height: 16),
              ],
              if (_controller.message != null &&
                  _controller.isOnline &&
                  _controller.errorCount == 0) ...[
                _InfoBanner(
                  title: _controller.message!,
                  message: 'Os dados oficiais serao recarregados apos a sincronização.',
                  isError: false,
                ),
                const SizedBox(height: 16),
              ],
              _PendingList(controller: _controller),
            ],
          ),
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.controller});

  final SyncController controller;

  @override
  Widget build(BuildContext context) {
    final isDone =
        controller.pendingCount == 0 && controller.errorCount == 0 && !controller.isSyncing;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: MyColors.colorPrimary.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: controller.isSyncing
                  ? const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        color: MyColors.colorPrimary,
                      ),
                    )
                  : SvgPicture.asset(
                      'icon/cloud-sync.svg',
                      width: 30,
                      height: 30,
                      colorFilter: const ColorFilter.mode(MyColors.colorPrimary, BlendMode.srcIn),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.isSyncing
                      ? 'Sincronizando...'
                      : isDone
                      ? 'Tudo sincronizado'
                      : 'Salvo no aparelho',
                  style: const TextStyle(
                    color: Color(0xFF1F1F1F),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.isSyncing
                      ? 'Enviando dados para a nuvem'
                      : isDone
                      ? 'Nenhuma alteração pendente no momento.'
                      : 'Sincronize quando tiver internet.',
                  style: const TextStyle(color: Color(0xFF666666), fontSize: 12, height: 1.25),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Status da conexão',
                style: TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              _ConnectionPill(isOnline: controller.isOnline),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.controller});

  final SyncController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'alterações pendentes',
            value: controller.pendingCount.toString(),
            color: const Color(0xFFFF9800),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: 'Itens com erro',
            value: controller.errorCount.toString(),
            color: MyColors.colorBtnNo,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF4F4F4F),
              fontSize: 11,
              height: 1.15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncButton extends StatelessWidget {
  const _SyncButton({required this.controller, required this.onPressed});

  final SyncController controller;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: controller.canSyncNow ? onPressed : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: MyColors.colorPrimary,
          disabledBackgroundColor: MyColors.colorPrimary.withOpacity(0.55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (controller.isSyncing)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
              )
            else
              SvgPicture.asset(
                'icon/arrow-reload-horizontal.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            const SizedBox(width: 10),
            Text(
              controller.isSyncing ? 'Sincronizando...' : 'Sincronizar agora',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingList extends StatelessWidget {
  const _PendingList({required this.controller});

  final SyncController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(color: MyColors.colorPrimary),
        ),
      );
    }

    if (!controller.hasItems) {
      return const _EmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pendencias (${controller.visibleCount})',
          style: const TextStyle(
            color: Color(0xFF1F1F1F),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        ...controller.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _SyncItemTile(item: item, isSyncing: controller.isSyncing),
          ),
        ),
      ],
    );
  }
}

class _SyncItemTile extends StatelessWidget {
  const _SyncItemTile({required this.item, required this.isSyncing});

  final SyncItem item;
  final bool isSyncing;

  @override
  Widget build(BuildContext context) {
    final visual = _StatusVisual.fromStatus(
      isSyncing && item.status == SyncStatus.pending ? SyncStatus.syncing : item.status,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: visual.color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(visual.icon, size: 18, color: visual.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _itemTitle(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _itemSubtitle(item),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF747474),
                    fontSize: 11,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.error?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.error!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: MyColors.colorBtnNo,
                      fontSize: 11,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusChip(visual: visual),
        ],
      ),
    );
  }

  String _itemTitle(SyncItem item) {
    final module = _moduleLabel(item.module);
    final action = _actionLabel(item.action);
    return '$module - $action';
  }

  String _itemSubtitle(SyncItem item) {
    final id = item.payload['id'];
    final idLabel = id == null ? '' : ' - ID $id';
    return '${_formatDate(item.createdAt)}$idLabel';
  }

  String _moduleLabel(String module) {
    switch (module) {
      case 'animais':
        return 'Animais';
      case 'lotes':
        return 'Lotes';
      case 'potreiros':
        return 'Potreiros';
      case 'movimentacoes':
        return 'Movimentações';
      default:
        return module.isEmpty ? 'Item offline' : module;
    }
  }

  String _actionLabel(String action) {
    switch (action) {
      case 'create':
        return 'Criar';
      case 'update':
        return 'Atualizar';
      case 'delete':
        return 'Excluir';
      default:
        return action.isEmpty ? 'Pendente' : action;
    }
  }

  String _formatDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} ${two(date.hour)}:${two(date.minute)}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.visual});

  final _StatusVisual visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: visual.color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        visual.label,
        style: TextStyle(color: visual.color, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ConnectionPill extends StatelessWidget {
  const _ConnectionPill({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? MyColors.colorPrimary : MyColors.colorBtnNo;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.title, required this.message, required this.isError});

  final String title;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? MyColors.colorBtnNo : MyColors.colorPrimary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: MyColors.colorPrimary.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: MyColors.colorPrimary, size: 32),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tudo sincronizado',
            style: TextStyle(color: Color(0xFF202020), fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Nenhuma alteração pendente no momento.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusVisual {
  const _StatusVisual({required this.label, required this.color, required this.icon});

  final String label;
  final Color color;
  final IconData icon;

  factory _StatusVisual.fromStatus(String status) {
    switch (status) {
      case SyncStatus.syncing:
        return const _StatusVisual(
          label: 'Sincronizando',
          color: MyColors.colorPrimary,
          icon: Icons.sync_rounded,
        );
      case SyncStatus.error:
        return const _StatusVisual(
          label: 'Erro',
          color: MyColors.colorBtnNo,
          icon: Icons.error_outline,
        );
      case SyncStatus.pending:
      default:
        return const _StatusVisual(
          label: 'Pendente',
          color: Color(0xFFFF9800),
          icon: Icons.schedule_rounded,
        );
    }
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: const Color(0xFFEAEAEA)),
    boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 3))],
  );
}
