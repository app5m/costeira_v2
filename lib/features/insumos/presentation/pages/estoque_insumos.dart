import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/presentation/controllers/delete_insumo_controller.dart';
import 'package:costeira/features/insumos/presentation/controllers/list_insumos_controller.dart';
import 'package:costeira/features/insumos/presentation/pages/add_compra.dart';
import 'package:costeira/features/insumos/presentation/pages/add_insumo.dart';
import 'package:costeira/features/insumos/presentation/pages/detail_insumo.dart';
import 'package:costeira/features/insumos/presentation/pages/graficos_insumo.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Insumos extends StatefulWidget {
  const Insumos({super.key});

  @override
  State<Insumos> createState() => _InsumosState();
}

class _InsumosState extends State<Insumos> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ListInsumosController _listController =
      Modular.get<ListInsumosController>();
  final DeleteInsumoController _deleteController =
      Modular.get<DeleteInsumoController>();

  int index = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInsumos());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _listController.dispose();
    _deleteController.dispose();
    super.dispose();
  }

  Future<void> _loadInsumos({String? tipoInsumo}) async {
    try {
      await _listController.load(tipoInsumo: tipoInsumo);
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppSnackBar.show(
        context: context,
        message:
            _listController.errorMessage ??
            'Nao foi possivel carregar os insumos.',
      );
    }
  }

  Future<void> _showTipoFilter() async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 2,
                    color: const Color(0xFFE2E2E2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tipo de insumo',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                _buildFilterOption(
                  label: 'Todos',
                  isSelected: _listController.currentFilter?.tipoInsumo == null,
                  onTap: () => Navigator.of(context).pop(null),
                ),
                ..._listController.tipoInsumos.map(
                  (tipo) => _buildFilterOption(
                    label: tipo.nome,
                    isSelected:
                        _listController.currentFilter?.tipoInsumo ==
                        tipo.id?.toString(),
                    onTap: () => Navigator.of(context).pop(tipo.id?.toString()),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) {
      return;
    }
    await _loadInsumos(tipoInsumo: selected);
  }

  Widget _buildFilterOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? MyColors.colorPrimary : const Color(0xFF313131),
          fontFamily: 'Montserrat',
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: MyColors.colorPrimary)
          : null,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: index == 0
          ? SpeedDial(
              direction: SpeedDialDirection.up,
              icon: Icons.add_rounded,
              activeIcon: Icons.close_rounded,
              backgroundColor: MyColors.colorPrimary2,
              foregroundColor: Colors.white,
              activeForegroundColor: Colors.white,
              children: [
                SpeedDialChild(
                  shape: const CircleBorder(),
                  child: Icon(Icons.add_rounded, color: MyColors.colorPrimary2),
                  label: 'Novo insumo',
                  labelStyle: TextStyle(
                    color: MyColors.colorPrimary2,
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    height: 1.29,
                  ),
                  onTap: () async {
                    final result = await Navigator.push<Map<String, dynamic>?>(
                      context,
                      MaterialPageRoute(builder: (_) => const AddInsumo()),
                    );
                    if (!mounted || result?['success'] != true) {
                      return;
                    }
                    await _listController.reload();
                  },
                ),
                SpeedDialChild(
                  shape: const CircleBorder(),
                  child: Icon(Icons.add_rounded, color: MyColors.colorPrimary2),
                  label: 'Registro de compra',
                  labelStyle: TextStyle(
                    color: MyColors.colorPrimary2,
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    height: 1.29,
                  ),
                  onTap: () async {
                    final result = await Navigator.push<Map<String, dynamic>?>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddCompraInsumo(tipo: 1),
                      ),
                    );
                    if (!mounted || result?['success'] != true) {
                      return;
                    }
                    await _listController.reload();
                  },
                ),
                SpeedDialChild(
                  shape: const CircleBorder(),
                  child: Icon(Icons.add_rounded, color: MyColors.colorPrimary2),
                  label: 'Registro de utilização',
                  labelStyle: TextStyle(
                    color: MyColors.colorPrimary2,
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    height: 1.29,
                  ),
                  onTap: () async {
                    final result = await Navigator.push<Map<String, dynamic>?>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddCompraInsumo(tipo: 2),
                      ),
                    );
                    if (!mounted || result?['success'] != true) {
                      return;
                    }
                    await _listController.reload();
                  },
                ),
              ],
              buttonSize: const Size(180, 48),
            )
          : null,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
          onTap: () => Modular.to.pop(),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Estoque de Insumos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Lista'),
              Tab(text: 'Registros'),
              Tab(text: 'Gráficos'),
            ],
            onTap: (int inde) {
              setState(() {
                index = inde;
              });
            },
            automaticIndicatorColorAdjustment: false,
            indicatorSize: TabBarIndicatorSize.tab,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
            ),
            dividerColor: Colors.grey,
            labelColor: Colors.black,
            indicatorColor: MyColors.colorPrimary2,
          ),
          const SizedBox(height: 16),
          if (index == 0)
            AnimatedBuilder(
              animation: _listController,
              builder: (context, _) {
                final hasFilters = _listController.hasActiveFilters();
                return _FilterSelector(
                  label: hasFilters
                      ? _listController.tipoLabel(
                          _listController.currentFilter!.tipoInsumo!,
                        )
                      : 'Filtrar por tipo',
                  isActive: hasFilters,
                  onTap: _showTipoFilter,
                );
              },
            ),
          if (index == 0) const SizedBox(height: 16),
          if (index == 0) Expanded(child: _buildList()),
          if (index == 1) Expanded(child: _buildRegistrosList()),
          if (index == 2) const GraficosInsumo(),
        ],
      ),
    );
  }

  Widget _buildList() {
    return AnimatedBuilder(
      animation: _listController,
      builder: (context, _) {
        if (_listController.isLoading && _listController.insumos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_listController.errorMessage != null &&
            _listController.insumos.isEmpty) {
          return ListView(
            children: [
              const SizedBox(height: 120),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _listController.errorMessage!,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        }

        if (_listController.insumos.isEmpty) {
          return ListView(
            children: const [
              SizedBox(height: 120),
              Center(child: Text('Nenhum insumo cadastrado.')),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: _listController.reload,
          child: ListView.builder(
            itemCount: _listController.insumos.length,
            itemBuilder: (context, index) {
              final insumo = _listController.insumos[index];
              return _InsumoCard(
                insumo: insumo,
                tipoLabel: _listController.tipoLabel(insumo.tipoInsumo),
                description: _listController.buildDescription(insumo),
                quantity: _listController.buildQuantity(insumo),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DetailInsumo()),
                  );
                },
                onDelete: () => _confirmDeleteInsumo(insumo),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRegistrosList() {
    return AnimatedBuilder(
      animation: _listController,
      builder: (context, _) {
        if (_listController.isLoading && _listController.registros.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_listController.errorMessage != null &&
            _listController.registros.isEmpty) {
          return ListView(
            children: [
              const SizedBox(height: 120),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _listController.errorMessage!,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        }

        if (_listController.registros.isEmpty) {
          return ListView(
            children: const [
              SizedBox(height: 120),
              Center(child: Text('Nenhum registro cadastrado.')),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: _listController.reload,
          child: ListView.builder(
            itemCount: _listController.registros.length,
            itemBuilder: (context, index) {
              final registro = _listController.registros[index];
              return _RegistroCard(
                registro: registro,
                tipoLabel: _listController.tipoLabel(registro.tipoInsumo),
                quantity: _listController.buildRegistroQuantity(registro),
                onDelete: () => _confirmDeleteRegistro(registro),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteInsumo(InsumoEntity insumo) {
    return _showModalBottomSheetExcluir(
      context: context,
      title: 'Excluir estoque de insumos',
      message: 'Tem certeza que deseja excluir ${insumo.nome} permanentemente?',
      onConfirm: () async {
        final result = await _deleteController.deleteInsumo(insumo.id);
        if (result == null) {
          throw Exception('Erro ao excluir insumo.');
        }
        _listController.removeInsumoById(insumo.id);
        return result.message;
      },
    );
  }

  Future<void> _confirmDeleteRegistro(InsumoRegistroEntity registro) {
    return _showModalBottomSheetExcluir(
      context: context,
      title: 'Excluir registro',
      message:
          'Tem certeza que deseja excluir este registro de ${registro.estoqueNome} permanentemente?',
      onConfirm: () async {
        final result = await _deleteController.deleteRegistro(registro.id);
        if (result == null) {
          throw Exception('Erro ao excluir registro.');
        }
        _listController.removeRegistroById(registro.id);
        return result.message;
      },
    );
  }

  Future<void> _showModalBottomSheetExcluir({
    required BuildContext context,
    required String title,
    required String message,
    required Future<String> Function() onConfirm,
  }) {
    return showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (BuildContext bc) {
        return AnimatedBuilder(
          animation: _deleteController,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Opacity(
                        opacity: 0.70,
                        child: Container(
                          width: 72,
                          decoration: const ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 2,
                                strokeAlign: BorderSide.strokeAlignCenter,
                                color: Color(0xFFE2E2E2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(false),
                              child: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SvgPicture.asset(
                        'icon/danger-linear.svg',
                        width: 80,
                        height: 80,
                        colorFilter: const ColorFilter.mode(
                          Colors.red,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xff000000),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xFF8692A8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _deleteController.isLoading
                              ? null
                              : () async {
                                  try {
                                    final successMessage = await onConfirm();
                                    if (!mounted || !context.mounted) {
                                      return;
                                    }
                                    Navigator.of(context).pop(false);
                                    AppSnackBar.show(
                                      context: this.context,
                                      message: successMessage,
                                      isError: false,
                                    );
                                  } catch (_) {
                                    if (!mounted) {
                                      return;
                                    }
                                    AppSnackBar.show(
                                      context: this.context,
                                      message:
                                          _deleteController.errorMessage ??
                                          'Nao foi possivel excluir.',
                                      isError: true,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: const BorderSide(color: Colors.red),
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                          ),
                          child: Text(
                            _deleteController.isLoading
                                ? 'Excluindo...'
                                : 'Excluir',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _deleteController.isLoading
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            color: MyColors.colorOnPrimary,
                            decoration: TextDecoration.underline,
                            decorationColor: MyColors.colorOnPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _InsumoCard extends StatelessWidget {
  const _InsumoCard({
    required this.insumo,
    required this.tipoLabel,
    required this.description,
    required this.quantity,
    required this.onTap,
    required this.onDelete,
  });

  final InsumoEntity insumo;
  final String tipoLabel;
  final String description;
  final String quantity;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8, left: 20, right: 20),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 24,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: const Color(0x198C8C8C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(42.67),
                      ),
                    ),
                    child: SvgPicture.asset(
                      'icon/diamond.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF8C8C8C),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CardText(tipoLabel, fontSize: 14),
                        const SizedBox(height: 8),
                        _CardText(
                          insumo.valorTotal?.trim().isNotEmpty == true
                              ? insumo.valorTotal!.trim()
                              : 'Valor nao informado',
                          fontSize: 12,
                        ),
                        const SizedBox(height: 8),
                        _CardText(description, fontSize: 12),
                        const SizedBox(height: 8),
                        _CardText(
                          quantity.isEmpty
                              ? 'Quantidade nao informada'
                              : quantity,
                          fontSize: 12,
                          color: const Color(0xFF8C8C8C),
                        ),
                        const SizedBox(height: 8),
                        _CardText(
                          insumo.dataValidade ?? 'Validade nao informada',
                          fontSize: 12,
                          color: const Color(0xFF8C8C8C),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onDelete,
                  child: SvgPicture.asset('icon/trash.svg'),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {},
                  child: SvgPicture.asset('icon/square-pen.svg'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RegistroCard extends StatelessWidget {
  const _RegistroCard({
    required this.registro,
    required this.tipoLabel,
    required this.quantity,
    required this.onDelete,
  });

  final InsumoRegistroEntity registro;
  final String tipoLabel;
  final String quantity;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final obs = registro.obs?.trim();

    return Container(
      width: MediaQuery.of(context).size.width - 40,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8, left: 20, right: 20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0x198C8C8C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(42.67),
              ),
            ),
            child: Icon(
              registro.tipo.id?.toString() == '1'
                  ? Icons.add_shopping_cart_rounded
                  : Icons.remove_circle_outline_rounded,
              size: 16,
              color: const Color(0xFF8C8C8C),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardText(registro.tipo.nome, fontSize: 14),
                const SizedBox(height: 8),
                _CardText(registro.estoqueNome, fontSize: 12),
                const SizedBox(height: 8),
                _CardText(
                  '$tipoLabel - $quantity',
                  fontSize: 12,
                  color: const Color(0xFF8C8C8C),
                ),
                if (obs != null && obs.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _CardText(obs, fontSize: 12),
                ],
                const SizedBox(height: 8),
                _CardText(
                  registro.dataCadastro ?? 'Data nao informada',
                  fontSize: 12,
                  color: const Color(0xFF8C8C8C),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onDelete,
                child: SvgPicture.asset('icon/trash.svg'),
              ),
              const SizedBox(height: 12),
              SvgPicture.asset('icon/square-pen.svg'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardText extends StatelessWidget {
  const _CardText(
    this.text, {
    required this.fontSize,
    this.color = const Color(0xFF313131),
  });

  final String text;
  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _FilterSelector extends StatelessWidget {
  const _FilterSelector({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        padding: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: isActive ? const Color(0x14128977) : Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: isActive ? MyColors.colorPrimary : const Color(0xFFEBEBEB),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 24,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? MyColors.colorPrimary
                    : const Color(0xFF8C8C8C),
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            ),
            Icon(
              Icons.tune_rounded,
              color: isActive ? MyColors.colorPrimary : const Color(0xFF8C8C8C),
            ),
          ],
        ),
      ),
    );
  }
}
