import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';
import 'package:costeira/features/sanitarios/presentation/controllers/delete_sanitario_controller.dart';
import 'package:costeira/features/sanitarios/presentation/controllers/list_sanitarios_controller.dart';
import 'package:costeira/features/sanitarios/presentation/pages/add_planejamento.dart';
import 'package:costeira/features/sanitarios/presentation/pages/detail_execucoes.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Execucoes extends StatefulWidget {
  const Execucoes({super.key});

  @override
  State<Execucoes> createState() => _ExecucoesState();
}

class _ExecucoesState extends State<Execucoes> {
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
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Execuções',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SanitariosExecucoesList(controller: _controller),
    );
  }
}

class SanitariosExecucoesList extends StatelessWidget {
  const SanitariosExecucoesList({super.key, required this.controller});

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

        final sanitarios = controller.executados;
        if (sanitarios.isEmpty) {
          return const _FeedbackState(message: 'Nenhuma execução encontrada.');
        }

        return RefreshIndicator(
          onRefresh: controller.reload,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            itemCount: sanitarios.length,
            itemBuilder: (context, index) {
              return _ExecucaoCard(
                sanitario: sanitarios[index],
                onDelete: () => _confirmDelete(context, sanitarios[index]),
                onSaved: controller.reload,
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, SanitarioEntity sanitario) async {
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
        return Padding(
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
                colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
              ),
              const SizedBox(height: 16),
              const Text(
                'Excluir execução',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tem certeza que deseja excluir essa\nexecução permanentemente?',
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Excluir', style: TextStyle(color: Colors.red)),
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
        message: result?.message ?? 'Execução excluida com sucesso.',
        isError: false,
      );
      await controller.reload();
    } on ApiException catch (error) {
      if (!context.mounted) return;
      AppSnackBar.show(context: context, message: error.message);
    }
  }
}

class _ExecucaoCard extends StatelessWidget {
  const _ExecucaoCard({required this.sanitario, required this.onDelete, required this.onSaved});

  final SanitarioEntity sanitario;
  final VoidCallback onDelete;
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DetailExecucao()));
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
          shadows: const [BoxShadow(color: Color(0x0A000000), blurRadius: 24)],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconBadge(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sanitario.tipoManejo, style: _primaryStyle),
                  const SizedBox(height: 8),
                  Text(_targets, style: _primaryStyle.copyWith(fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(_insumos, style: _secondaryStyle),
                  const SizedBox(height: 8),
                  Text('Realizado em ${sanitario.dataExecucao ?? '-'}', style: _secondaryStyle),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                GestureDetector(onTap: onDelete, child: SvgPicture.asset('icon/trash.svg')),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => AddPlanejamento(sanitario: sanitario)),
                    ).then((saved) {
                      if (saved == true) {
                        onSaved();
                      }
                    });
                  },
                  child: SvgPicture.asset('icon/square-pen.svg'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _targets {
    final lotes = sanitario.lotes.map((item) => item.nome.trim()).where((item) => item.isNotEmpty);
    final categorias = sanitario.categorias
        .map((item) => item.nome.trim())
        .where((item) => item.isNotEmpty);
    final values = [...lotes, ...categorias].join(' • ');
    return values.isEmpty ? 'Sem lote ou categoria vinculada' : values;
  }

  String get _insumos {
    final values = sanitario.insumos
        .map((item) => item.nome.trim())
        .where((item) => item.isNotEmpty)
        .join(', ');
    return values.isEmpty ? 'Sem insumo vinculado' : values;
  }

  TextStyle get _primaryStyle => const TextStyle(
    color: Color(0xFF313131),
    fontSize: 14,
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w500,
  );

  TextStyle get _secondaryStyle => const TextStyle(
    color: Color(0xFF8C8C8C),
    fontSize: 12,
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w500,
  );
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
  const _FeedbackState({required this.message, this.actionLabel, this.onAction});

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
