import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';
import 'package:costeira/features/sanitarios/presentation/controllers/delete_sanitario_controller.dart';
import 'package:costeira/features/sanitarios/presentation/controllers/list_sanitarios_controller.dart';
import 'package:costeira/features/sanitarios/presentation/pages/add_execucao.dart';
import 'package:costeira/features/sanitarios/presentation/pages/add_planejamento.dart';
import 'package:costeira/features/sanitarios/presentation/pages/detail_planejamento.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Planejamento extends StatefulWidget {
  const Planejamento({super.key});

  @override
  State<Planejamento> createState() => _PlanejamentoState();
}

class SanitariosPlanejamentoList extends StatelessWidget {
  const SanitariosPlanejamentoList({super.key, required this.controller});

  final ListSanitariosController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage != null) {
          return _FeedbackState(
            message: controller.errorMessage!,
            actionLabel: 'Tentar novamente',
            onAction: () => controller.load(),
          );
        }

        final sanitarios = controller.planejados;
        if (sanitarios.isEmpty) {
          return const _FeedbackState(
            message: 'Nenhum planejamento encontrado.',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.reload,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 88),
            itemCount: sanitarios.length,
            itemBuilder: (context, index) {
              return _SanitarioCard(
                sanitario: sanitarios[index],
                onDelete: () => _confirmDelete(context, sanitarios[index]),
                onExecute: () {
                  Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddExecucaoSanitario(sanitario: sanitarios[index]),
                    ),
                  ).then((saved) {
                    if (saved == true) {
                      controller.reload();
                    }
                  });
                },
                onEdit: () {
                  Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddPlanejamento(sanitario: sanitarios[index]),
                    ),
                  ).then((saved) {
                    if (saved == true) {
                      controller.reload();
                    }
                  });
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    SanitarioEntity sanitario,
  ) async {
    final confirmed = await showModalBottomSheet<bool>(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(width: 72, height: 2, color: const Color(0xFFE2E2E2)),
                const SizedBox(height: 24),
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
                const Text(
                  'Excluir planejamento',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tem certeza que deseja excluir esse\nplanejamento permanentemente?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF8692A8),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Excluir',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
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
              ],
            ),
          ),
        );
      },
    );
    if (confirmed != true || !context.mounted) return;

    final deleteController = Modular.get<DeleteSanitarioController>();
    try {
      final result = await deleteController.deleteSanitario(sanitario.id);
      if (!context.mounted) return;
      AppSnackBar.show(
        context: context,
        message: result?.message ?? 'Planejamento excluido com sucesso.',
        isError: false,
      );
      await controller.reload();
    } on ApiException catch (error) {
      if (!context.mounted) return;
      AppSnackBar.show(context: context, message: error.message);
    }
  }
}

class _PlanejamentoState extends State<Planejamento> {
  late final ListSanitariosController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<ListSanitariosController>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(64)),
        onPressed: () {
          Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddPlanejamento()),
          ).then((saved) {
            if (saved == true) {
              _controller.reload();
            }
          });
        },
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Planejamento',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            if (_controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_controller.errorMessage != null) {
              return _FeedbackState(
                message: _controller.errorMessage!,
                actionLabel: 'Tentar novamente',
                onAction: () => _controller.load(),
              );
            }

            final sanitarios = _controller.planejados;
            if (sanitarios.isEmpty) {
              return const _FeedbackState(
                message: 'Nenhum planejamento encontrado.',
              );
            }

            return RefreshIndicator(
              onRefresh: _controller.reload,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 16, bottom: 88),
                itemCount: sanitarios.length,
                itemBuilder: (context, index) {
                  return _SanitarioCard(
                    sanitario: sanitarios[index],
                    onDelete: () => _confirmDelete(context, sanitarios[index]),
                    onExecute: () {
                      Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddExecucaoSanitario(
                            sanitario: sanitarios[index],
                          ),
                        ),
                      ).then((saved) {
                        if (saved == true) {
                          _controller.reload();
                        }
                      });
                    },
                    onEdit: () {
                      Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddPlanejamento(sanitario: sanitarios[index]),
                        ),
                      ).then((saved) {
                        if (saved == true) {
                          _controller.reload();
                        }
                      });
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    SanitarioEntity sanitario,
  ) async {
    final confirmed = await showModalBottomSheet<bool>(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(width: 72, height: 2, color: const Color(0xFFE2E2E2)),
                const SizedBox(height: 24),
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
                const Text(
                  'Excluir planejamento',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tem certeza que deseja excluir esse\nplanejamento permanentemente?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF8692A8),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Excluir',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
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
              ],
            ),
          ),
        );
      },
    );
    if (confirmed != true || !context.mounted) return;

    final deleteController = Modular.get<DeleteSanitarioController>();
    try {
      final result = await deleteController.deleteSanitario(sanitario.id);
      if (!context.mounted) return;
      AppSnackBar.show(
        context: context,
        message: result?.message ?? 'Planejamento excluido com sucesso.',
        isError: false,
      );
      await _controller.reload();
    } on ApiException catch (error) {
      if (!context.mounted) return;
      AppSnackBar.show(context: context, message: error.message);
    }
  }
}

class _SanitarioCard extends StatelessWidget {
  const _SanitarioCard({
    required this.sanitario,
    required this.onDelete,
    required this.onExecute,
    required this.onEdit,
  });

  final SanitarioEntity sanitario;
  final VoidCallback onDelete;
  final VoidCallback onExecute;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPlanejamento(sanitario: sanitario),
          ),
        );
      },
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _IconBadge(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title,
                          style: const TextStyle(
                            color: Color(0xFF313131),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(_lotes, style: _secondaryStyle),
                        const SizedBox(height: 8),
                        Text(
                          sanitario.dataPlanejada ?? '-',
                          style: _secondaryStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<_SanitarioAction>(
              icon: const Icon(Icons.more_vert, color: Color(0xFF8C8C8C)),
              color: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onSelected: (action) {
                switch (action) {
                  case _SanitarioAction.edit:
                    onEdit();
                    break;
                  case _SanitarioAction.delete:
                    onDelete();
                    break;
                  case _SanitarioAction.execute:
                    onExecute();
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _SanitarioAction.edit,
                  child: _ActionMenuItem(
                    icon: Icons.edit_outlined,
                    label: 'Editar',
                  ),
                ),
                PopupMenuItem(
                  value: _SanitarioAction.delete,
                  child: _ActionMenuItem(
                    icon: Icons.delete_outline,
                    label: 'Excluir',
                    color: Colors.red,
                  ),
                ),
                PopupMenuItem(
                  value: _SanitarioAction.execute,
                  child: _ActionMenuItem(
                    icon: Icons.check_circle_outline,
                    label: 'Executar',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _title {
    final categorias = sanitario.categorias
        .map((item) => item.nome.trim())
        .where((item) => item.isNotEmpty)
        .join(', ');
    return categorias.isEmpty
        ? sanitario.tipoManejo
        : '${sanitario.tipoManejo} • $categorias';
  }

  String get _lotes {
    final lotes = sanitario.lotes
        .map((item) => item.nome.trim())
        .where((item) => item.isNotEmpty)
        .join(', ');
    return lotes.isEmpty ? 'Sem lote vinculado' : lotes;
  }

  TextStyle get _secondaryStyle => const TextStyle(
    color: Color(0xFF8C8C8C),
    fontSize: 12,
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w500,
  );
}

enum _SanitarioAction { edit, delete, execute }

class _ActionMenuItem extends StatelessWidget {
  const _ActionMenuItem({
    required this.icon,
    required this.label,
    this.color = const Color(0xFF313131),
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: const Color(0x198C8C8C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(42)),
      ),
      child: SvgPicture.asset(
        'icon/square-chart-gantt.svg',
        width: 16,
        height: 16,
        colorFilter: const ColorFilter.mode(Color(0xFF8C8C8C), BlendMode.srcIn),
      ),
    );
  }
}

class _FeedbackState extends StatelessWidget {
  const _FeedbackState({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8C8C8C),
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
