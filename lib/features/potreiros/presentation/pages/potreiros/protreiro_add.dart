import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/input_formatters/fixed_two_decimal_input_formatter.dart';
import 'package:costeira/features/potreiros/presentation/page_controllers/potreiro_add_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../../theme/colors.dart';

class PotreiroAdd extends StatefulWidget {
  const PotreiroAdd({super.key});

  @override
  State<PotreiroAdd> createState() => _PotreiroAddState();
}

class _PotreiroAddState extends State<PotreiroAdd> {
  static const _decimalFormatter = FixedTwoDecimalInputFormatter();

  final PotreiroAddPageController _pageController =
      Modular.get<PotreiroAddPageController>();

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
      Modular.to.pop({'success': true, 'message': result.message});
      return;
    }

    AppSnackBar.show(context: context, message: result.message, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: MyColors.colorPrimary,
            leading: GestureDetector(
              onTap: () => Modular.to.pop(),
              child: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            title: const Text(
              'Adicionar potreiro',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  _buildTextField(
                    _pageController.nomeController,
                    'Nome',
                    'Nome do potreiro',
                  ),
                  _buildTextField(
                    _pageController.areaTotalController,
                    'Área total',
                    '0.00',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: const [_decimalFormatter],
                  ),
                  _buildTextField(
                    _pageController.areaUtilController,
                    'Área utilizável',
                    '0.00',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: const [_decimalFormatter],
                  ),
                  _buildDropdown(
                    'Status atual do potreiro',
                    _pageController.selectedStatusAtual,
                    PotreiroAddPageController.statusOptions,
                    _pageController.onStatusAtualChanged,
                  ),
                  _buildTextField(
                    _pageController.tipoForragemController,
                    'Tipo forragem',
                    'Tipo da forragem presente no potreiro',
                  ),
                  _buildDropdown(
                    'Acesso a água',
                    _pageController.selectedAcessoAgua,
                    PotreiroAddPageController.acessoOptions,
                    _pageController.onAcessoAguaChanged,
                  ),
                  _buildDropdown(
                    'Acesso a sombra',
                    _pageController.selectedAcessoSombra,
                    PotreiroAddPageController.acessoOptions,
                    _pageController.onAcessoSombraChanged,
                  ),
                  _buildTextField(
                    _pageController.lotacaoMediaController,
                    'Lotação média',
                    '0.00',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: const [_decimalFormatter],
                  ),
                  _buildTextField(
                    _pageController.obsController,
                    'Observações',
                    'Ex: Área com pastagem bem formada...',
                    minLines: 3,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.colorPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed:
                          _pageController.isLoading ||
                              !_pageController.isFormValid
                          ? null
                          : _submit,
                      child: Text(
                        _pageController.isLoading ? 'Salvando...' : 'Salvar',
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
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int minLines = 1,
    int maxLines = 1,
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
          minLines: minLines,
          maxLines: maxLines,
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

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    void Function(String? value) onChanged,
  ) {
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
        AppSelectOverlay<String>(
          value: items.contains(value) ? value : null,
          placeholder: 'Selecione',
          options: items
              .map((item) => AppSelectOption<String>(value: item, label: item))
              .toList(growable: false),
          enabled: items.isNotEmpty,
          onChanged: onChanged,
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
