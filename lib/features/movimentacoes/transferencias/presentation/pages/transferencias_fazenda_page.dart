import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_fazenda_list_item.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/page_controllers/transferencias_fazenda_list_page_controller.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/pages/transferencia_fazenda_detail_page.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/widgets/transferencia_fazenda_card.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TransferenciasFazendaPage extends StatefulWidget {
  const TransferenciasFazendaPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<TransferenciasFazendaPage> createState() =>
      _TransferenciasFazendaPageState();
}

class _TransferenciasFazendaPageState extends State<TransferenciasFazendaPage>
    with SingleTickerProviderStateMixin {
  final TransferenciasFazendaListPageController _controller =
      Modular.get<TransferenciasFazendaListPageController>();
  late final TabController _tabs = TabController(
    length: 2,
    vsync: this,
    initialIndex: widget.initialTab,
  );

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: MyColors.colorPrimary,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            title: const Text(
              'Transferências',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            bottom: TabBar(
              controller: _tabs,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Recebidas'),
                Tab(text: 'Enviadas'),
              ],
            ),
          ),
          body: _controller.isLoading &&
                  _controller.recebidas.isEmpty &&
                  _controller.enviadas.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabs,
                  children: [
                    _List(
                      items: _controller.recebidas,
                      recebidas: true,
                      onDecidir: _decidir,
                      onOpen: (item) => _openDetail(item, canEdit: false),
                    ),
                    _List(
                      items: _controller.enviadas,
                      recebidas: false,
                      onDecidir: _decidir,
                      onOpen: (item) => _openDetail(item, canEdit: true),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _openDetail(
    TransferenciaFazendaListItem item, {
    required bool canEdit,
  }) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TransferenciaFazendaDetailPage(
          item: item,
          canEdit: canEdit,
        ),
      ),
    );
    if (changed == true && mounted) {
      await _controller.load();
    }
  }

  Future<void> _decidir(int id, int status) async {
    final error = await _controller.decidir(
      id: id,
      statusTransferencia: status,
    );
    if (!mounted || error == null) {
      return;
    }
    AppSnackBar.show(context: context, message: error, isError: true);
  }
}

class _List extends StatelessWidget {
  const _List({
    required this.items,
    required this.recebidas,
    required this.onDecidir,
    required this.onOpen,
  });

  final List<TransferenciaFazendaListItem> items;
  final bool recebidas;
  final Future<void> Function(int id, int status) onDecidir;
  final void Function(TransferenciaFazendaListItem item) onOpen;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma transferência',
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: Color(0xFF8A8A8A),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return TransferenciaFazendaCard(
          item: item,
          recebidas: recebidas,
          onDecidir: onDecidir,
          onOpen: () => onOpen(item),
        );
      },
    );
  }
}
