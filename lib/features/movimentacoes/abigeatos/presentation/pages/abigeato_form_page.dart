import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/entities/abigeato_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/abigeatos/presentation/page_controllers/abigeato_form_page_controller.dart';
import 'package:costeira/features/movimentacoes/abigeatos/presentation/pages/abigeato_animais_page.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AbigeatoFormPage extends StatefulWidget {
  const AbigeatoFormPage({super.key, this.abigeato});

  final AbigeatoUpsertEntity? abigeato;

  @override
  State<AbigeatoFormPage> createState() => _AbigeatoFormPageState();
}

class _AbigeatoFormPageState extends State<AbigeatoFormPage> {
  final AbigeatoFormPageController _pageController = Modular.get<AbigeatoFormPageController>();

  @override
  void initState() {
    super.initState();
    _pageController.init(abigeato: widget.abigeato);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final result = await _pageController.submit();
    if (!mounted) {
      return;
    }
    if (result.isSuccess) {
      Navigator.pop(context, {'success': true, 'message': result.message});
      return;
    }
    AppSnackBar.show(context: context, message: result.message, isError: true);
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null) {
      return;
    }
    _pageController.dataController.text =
        '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
  }

  Future<void> _openAnimalsPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AbigeatoAnimaisPage(pageController: _pageController)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: !_pageController.isEdit
              ? FloatingActionButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(64)),
                  onPressed: _openAnimalsPage,
                  child: const Icon(Icons.pets, color: Colors.white),
                )
              : null,
          appBar: AppBar(
            backgroundColor: MyColors.colorPrimary,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            title: Text(
              _pageController.isEdit ? 'Editar abigeato' : 'Adicionar abigeato',
              style: const TextStyle(
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
                _buildTextField(
                  controller: _pageController.dataController,
                  label: 'Data do abigeato',
                  hint: '00/00/0000',
                  readOnly: true,
                  onTap: _selectDate,
                ),
                _buildTextField(
                  controller: _pageController.obsController,
                  label: 'Observações',
                  hint: 'Digite observações sobre o abigeato',
                  maxLines: 3,
                ),
                if (!_pageController.isEdit) _buildAnimalsSummary(),

                if (_pageController.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _pageController.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 20),
                CustomButton(
                  onPressed: _submit,
                  text: _pageController.isEdit ? 'Salvar' : 'Adicionar',
                  enabled: _pageController.isFormValid,
                  isLoading: _pageController.isLoading,
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimalsSummary() {
    final count = _pageController.selectedAnimais.length;
    final label = count == 1 ? '1 animal selecionado' : '$count animais selecionados';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Animais',
          style: TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _openAnimalsPage,
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    count == 0 ? 'Selecionar animais por brinco' : label,
                    style: const TextStyle(
                      color: Color(0xFF313131),
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_right, color: Color(0xFF8C8C8C)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
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
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              height: 1.50,
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
}

class _ReadOnlyHint extends StatelessWidget {
  const _ReadOnlyHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF8C8C8C),
          fontSize: 12,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
