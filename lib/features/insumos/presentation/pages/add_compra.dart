import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/insumos/domain/usecases/create_insumo_registro_usecase.dart';
import 'package:costeira/features/insumos/domain/usecases/get_insumos_tipo_usecase.dart';
import 'package:costeira/features/insumos/presentation/controllers/add_insumo_registro_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AddCompraInsumo extends StatefulWidget {
  const AddCompraInsumo({super.key, required this.tipo});

  final int tipo;

  @override
  State<AddCompraInsumo> createState() => _AddCompraInsumoState();
}

class _AddCompraInsumoState extends State<AddCompraInsumo> {
  late final AddInsumoRegistroController _controller;

  bool get _isCompra => widget.tipo == 1;

  @override
  void initState() {
    super.initState();
    _controller = AddInsumoRegistroController(
      Modular.get<CreateInsumoRegistroUsecase>(),
      Modular.get<GetInsumosTipoUsecase>(),
    );
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    try {
      final result = await _controller.submit(tipo: widget.tipo);
      if (!mounted) return;

      if (result?.isSuccess == true) {
        Modular.to.pop({'success': true, 'message': result!.message});
        return;
      }

      AppSnackBar.show(
        context: context,
        message: _controller.errorMessage ?? 'Preencha os campos obrigatorios.',
        isError: true,
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message:
            _controller.errorMessage ?? 'Nao foi possivel salvar o registro.',
        isError: true,
      );
    }
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
            leading: GestureDetector(
              onTap: () => Modular.to.pop(),
              child: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            title: Text(
              _isCompra ? 'Registro de compra' : 'Registro de utilização',
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
                if (_controller.isLoading && _controller.insumos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  _buildInsumoSelect(),
                  _buildReadOnlyField(
                    label: 'Unidade de medida',
                    value: _controller.selectedUnidadeLabel,
                  ),
                  _buildTextField(
                    controller: _controller.qtdController,
                    label: 'Quantidade',
                    hint: 'Ex: 25',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                    ],
                  ),
                  _buildTextField(
                    controller: _controller.obsController,
                    label: 'Observações',
                    hint: _isCompra
                        ? 'Compra realizada'
                        : 'Utilização no campo',
                    maxLines: 3,
                  ),
                  if (_controller.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _controller.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.colorPrimary,
                        disabledBackgroundColor: const Color(0xFFBDBDBD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed:
                          _controller.isLoading || !_controller.isFormValid
                          ? null
                          : _submit,
                      child: _controller.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Adicionar',
                              textAlign: TextAlign.center,
                              style: TextStyle(
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsumoSelect() {
    final value =
        _controller.insumos.any(
          (item) => item.id == _controller.selectedInsumoId,
        )
        ? _controller.selectedInsumoId
        : null;

    return _buildFieldShell(
      label: 'Insumo',
      child: AppSelectOverlay<int>(
        value: value,
        placeholder: 'Selecione',
        options: _controller.insumos
            .map(
              (item) => AppSelectOption<int>(
                value: item.id,
                label: _controller.selectedInsumoLabel(item),
              ),
            )
            .toList(growable: false),
        enabled: _controller.insumos.isNotEmpty,
        onChanged: _controller.onInsumoChanged,
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return _buildFieldShell(
      label: label,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEBEBEB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: _controller.selectedInsumo == null
                ? const Color(0xFF8C8C8C)
                : const Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
            letterSpacing: 0.10,
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
    int maxLines = 1,
  }) {
    return _buildFieldShell(
      label: label,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        style: const TextStyle(
          color: Color(0xFF313131),
          fontSize: 14,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w400,
          height: 1.50,
          letterSpacing: 0.10,
        ),
        decoration: _inputDecoration(hint),
      ),
    );
  }

  Widget _buildFieldShell({required String label, required Widget child}) {
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
        child,
        const SizedBox(height: 18),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
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
    );
  }
}
