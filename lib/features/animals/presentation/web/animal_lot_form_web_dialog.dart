import 'package:costeira/core/components/app_form_field.dart';
import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/presentation/page_controllers/add_lote_page_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/edit_lote_page_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AnimalLotFormWebDialog extends StatefulWidget {
  const AnimalLotFormWebDialog.add({super.key}) : lot = null;

  const AnimalLotFormWebDialog.edit({super.key, required AnimalLotEntity this.lot});

  final AnimalLotEntity? lot;

  bool get isEditing => lot != null;

  @override
  State<AnimalLotFormWebDialog> createState() => _AnimalLotFormWebDialogState();
}

class _AnimalLotFormWebDialogState extends State<AnimalLotFormWebDialog> {
  AddLotePageController? _addController;
  EditLotePageController? _editController;
  String? _submitError;

  bool get _isEditing => widget.isEditing;
  bool get _isLoading =>
      _isEditing ? (_editController?.isLoading ?? false) : (_addController?.isLoading ?? false);
  bool get _canSubmit {
    if (_isEditing) {
      return (_editController?.nomeController.text.trim().isNotEmpty ?? false) &&
          !_isLoading;
    }
    return (_addController?.hasNome ?? false) && !_isLoading;
  }

  TextEditingController get _nomeController => _isEditing
      ? _editController!.nomeController
      : _addController!.nomeController;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _editController = Modular.get<EditLotePageController>();
      _editController!.addListener(_refresh);
      _editController!.init(widget.lot!);
    } else {
      _addController = Modular.get<AddLotePageController>();
      _addController!.addListener(_refresh);
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _addController?.removeListener(_refresh);
    _editController?.removeListener(_refresh);
    _addController?.dispose();
    _editController?.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitError = null);
    final result = _isEditing
        ? await _editController!.submit()
        : await _addController!.submit();
    if (!mounted) return;
    if (result.isSuccess) {
      Navigator.of(context).pop({'success': true, 'message': result.message});
      return;
    }
    setState(() => _submitError = result.message);
  }

  @override
  Widget build(BuildContext context) {
    return WebDialogFrame(
      title: _isEditing ? 'Editar lote' : 'Adicionar lote',
      width: 560,
      maxHeight: 460,
      bodyPadding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_submitError != null) ...[
              Text(
                _submitError!,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFC4473A),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _canSubmit ? _submit : null,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: MyColors.colorPrimary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFBFC9C5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Salvar' : 'Adicionar',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      child: AppFormField(
        label: 'Nome do lote',
        hintText: 'Ex: A',
        controller: _nomeController,
      ),
    );
  }
}
