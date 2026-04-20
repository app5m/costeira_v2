import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_upsert_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/edit_animal_lot_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../../theme/colors.dart';

class EditLote extends StatefulWidget {
  const EditLote({super.key, required this.lot});

  final AnimalLotEntity lot;

  @override
  State<EditLote> createState() => _EditLoteState();
}

class _EditLoteState extends State<EditLote> {
  final EditAnimalLotController _controller = Modular.get<EditAnimalLotController>();

  final TextEditingController _nomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppLogger.info('LOTES EDIT PAGE: INIT STATE ID=${widget.lot.id}');
    _controller.setInitialLot(widget.lot);
    _nomeController.text = widget.lot.nome;
  }

  @override
  void dispose() {
    AppLogger.info('LOTES EDIT PAGE: DISPOSE');
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    AppLogger.info('LOTES EDIT PAGE: VALIDANDO FORMULARIO PARA SALVAR');
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) {
      _showMessage('Informe o nome do lote.');
      return;
    }

    try {
      AppLogger.info('LOTES EDIT PAGE: ENVIANDO EDICAO DO LOTE ID=${widget.lot.id}');
      final result = await _controller.submit(
        AnimalLotUpsertEntity(id: widget.lot.id, appUsersId: widget.lot.appUsersId, nome: nome),
      );

      if (!mounted || result == null) {
        return;
      }

      if (result.isSuccess) {
        AppLogger.success('LOTES EDIT PAGE: LOTE ATUALIZADO COM SUCESSO MSG=${result.message}');
        Navigator.of(context).pop({'success': true, 'message': result.message});
        return;
      }

      _showMessage(result.message);
    } catch (_) {
      AppLogger.error('LOTES EDIT PAGE: ERRO AO ATUALIZAR LOTE');
      _showMessage(_controller.errorMessage ?? 'Não foi possível atualizar o lote.');
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    AppLogger.warning('LOTES EDIT PAGE: EXIBINDO MENSAGEM $message');
    AppSnackBar.show(context: context, message: message, isError: isError);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
            letterSpacing: 0.10,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
            letterSpacing: 0.10,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              height: 1.50,
              letterSpacing: 0.10,
            ),
            filled: true,
            fillColor: const Color(0xFFEBEBEB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final isLoading = _controller.isLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: MyColors.colorPrimary,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            title: const Text(
              'Editar lote',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(controller: _nomeController, label: 'Nome do lote', hint: 'Ex: A'),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.colorPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: isLoading ? null : _submit,
                    child: Text(
                      isLoading ? 'Salvando...' : 'Salvar',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        height: 1.29,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
