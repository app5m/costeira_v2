import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/features/tasks/domain/entities/task_responsavel_entity.dart';
import 'package:costeira/features/tasks/presentation/pages/add_task_responsavel.dart';
import 'package:costeira/features/tasks/presentation/pages/detail_task_responsavel.dart';
import 'package:costeira/features/tasks/presentation/controllers/list_task_responsaveis_controller.dart';
import 'package:costeira/features/tasks/presentation/helpers/task_formatters.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TaskResponsaveisTab extends StatefulWidget {
  const TaskResponsaveisTab({super.key});

  @override
  State<TaskResponsaveisTab> createState() => _TaskResponsaveisTabState();
}

class _TaskResponsaveisTabState extends State<TaskResponsaveisTab> {
  final ListTaskResponsaveisController _controller =
      Modular.get<ListTaskResponsaveisController>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _loadResponsaveis();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadResponsaveis() async {
    try {
      await _controller.load();
    } catch (error) {
      if (mounted && error is! ApiException) {
        AppSnackBar.show(
          context: context,
          message: 'Nao foi possivel listar os responsaveis.',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(child: _buildResponsaveisContent());
  }

  Widget _buildResponsaveisContent() {
    final responsaveis = _controller.responsaveis;

    if (_controller.isLoading && responsaveis.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final errorMessage = _controller.errorMessage;
    if (errorMessage != null && responsaveis.isEmpty) {
      return _buildMessageState(errorMessage);
    }

    if (responsaveis.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadResponsaveis,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: responsaveis.length,
        itemBuilder: (context, index) {
          return _buildResponsavelCard(responsaveis[index]);
        },
      ),
    );
  }

  Widget _buildMessageState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 14,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Text(
        'Nenhum responsável cadastrado.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF8C8C8C),
          fontSize: 14,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildResponsavelCard(TaskResponsavelEntity responsavel) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailTaskResponsavel(responsavel: responsavel),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
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
          spacing: 8,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 16,
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
                    child: const Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Color(0xFF8C8C8C),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Text(
                          responsavel.nome,
                          style: const TextStyle(
                            color: Color(0xFF313131),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (responsavel.email.trim().isNotEmpty)
                          Text(
                            responsavel.email,
                            style: const TextStyle(
                              color: Color(0xFF8C8C8C),
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (responsavel.celular.trim().isNotEmpty)
                          Text(
                            formatTaskResponsavelPhone(responsavel.celular),
                            style: const TextStyle(
                              color: Color(0xFF8C8C8C),
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () => _deleteResponsavel(responsavel),
                  child: SvgPicture.asset('icon/trash.svg'),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddTaskResponsavel(responsavel: responsavel),
                            ),
                          );
                          await _loadResponsaveis();
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

  Future<void> _deleteResponsavel(TaskResponsavelEntity responsavel) async {
    final shouldDelete = await _showDeleteConfirmation();
    if (!shouldDelete || _isLoading) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final message = await _controller.deleteResponsavel(responsavel);
      if (!mounted) {
        return;
      }

      AppSnackBar.show(
        context: context,
        message: message.message,
        isError: false,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackBar.show(
        context: context,
        message: error is ApiException
            ? error.message
            : 'Nao foi possivel excluir o responsavel.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showModalBottomSheet<bool>(
          backgroundColor: Colors.white,
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 2,
                    color: const Color(0xFFE2E2E2),
                  ),
                  const SizedBox(height: 20),
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
                    'Excluir responsavel',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tem certeza que deseja excluir esse\nresponsavel permanentemente?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF8692A8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    text: 'Excluir',
                    backgroundColor: Colors.white,
                    textColor: Colors.red,
                    borderColor: Colors.red,
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
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
        ) ??
        false;
  }
}
