import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/features/tasks/domain/entities/task_responsavel_entity.dart';
import 'package:costeira/features/tasks/presentation/controllers/save_task_responsavel_controller.dart';
import 'package:costeira/features/tasks/presentation/helpers/task_formatters.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter/services.dart';

class AddTaskResponsavel extends StatefulWidget {
  const AddTaskResponsavel({super.key, this.responsavel});

  final TaskResponsavelEntity? responsavel;

  @override
  State<AddTaskResponsavel> createState() => _AddTaskResponsavelState();
}

class _AddTaskResponsavelState extends State<AddTaskResponsavel> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _celularController = TextEditingController();
  final SaveTaskResponsavelController _saveController =
      Modular.get<SaveTaskResponsavelController>();

  bool _isLoading = false;

  bool get _isEditing => widget.responsavel != null;

  bool get _isFormValid => _nomeController.text.trim().isNotEmpty;

  bool get _hasChanges {
    final responsavel = widget.responsavel;
    if (responsavel == null) {
      return true;
    }

    return _nomeController.text.trim() != responsavel.nome.trim() ||
        _emailController.text.trim() != responsavel.email.trim() ||
        taskResponsavelApiPhoneDigits(_celularController.text) !=
            taskResponsavelApiPhoneDigits(responsavel.celular);
  }

  bool get _canSubmit => _isFormValid && (!_isEditing || _hasChanges);

  @override
  void initState() {
    super.initState();
    final responsavel = widget.responsavel;
    if (responsavel != null) {
      _nomeController.text = responsavel.nome;
      _emailController.text = responsavel.email;
      _celularController.text = formatTaskResponsavelPhone(responsavel.celular);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _celularController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canSubmit || _isLoading) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final responsavel = TaskResponsavelEntity(
        id: widget.responsavel?.id,
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        celular: taskResponsavelApiPhoneDigits(_celularController.text),
      );
      final message = await _saveController.submit(responsavel);

      if (!mounted) {
        return;
      }

      AppSnackBar.show(
        context: context,
        message: message.message,
        isError: false,
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackBar.show(
        context: context,
        message: error is ApiException
            ? error.message
            : 'Nao foi possivel salvar o responsavel.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
        title: Text(
          _isEditing ? 'Editar responsável' : 'Adicionar responsável',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _nomeController,
                label: 'Nome',
                hint: 'Nome do responsavel',
              ),
              _buildTextField(
                controller: _emailController,
                label: 'E-mail',
                hint: 'email@dominio.com',
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                controller: _celularController,
                label: 'Celular',
                hint: '(99) 99999-9999',
                keyboardType: TextInputType.phone,
                inputFormatters: const [_CellPhoneInputFormatter()],
              ),
              const SizedBox(height: 2),
              CustomButton(
                onPressed: _submit,
                text: _isEditing ? 'Salvar' : 'Adicionar',
                enabled: _canSubmit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: (_) => setState(() {}),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 16,
            ),
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
}

class _CellPhoneInputFormatter extends TextInputFormatter {
  const _CellPhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = formatTaskResponsavelPhone(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
