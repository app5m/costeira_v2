import 'package:costeira/app/app_route_data.dart';
import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/common/get_list/domain/usecases/get_list_usecase.dart';
import 'package:costeira/core/input_formatters/brazilian_currency_input_formatter.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_kind.dart';
import 'package:costeira/features/cadastros/domain/usecases/get_parceiros_usecase.dart';
import 'package:costeira/features/cadastros/presentation/pages/parceiro_form_page.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/insumos/domain/usecases/get_insumos_usecase.dart';
import 'package:costeira/features/insumos/domain/usecases/movimentar_estoque_usecase.dart';
import 'package:costeira/features/insumos/presentation/controllers/add_insumo_registro_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AddCompraInsumo extends StatefulWidget {
  const AddCompraInsumo({super.key, required this.tipo, this.produtoNovo = false});

  final int tipo;
  final bool produtoNovo;

  @override
  State<AddCompraInsumo> createState() => _AddCompraInsumoState();
}

class _AddCompraInsumoState extends State<AddCompraInsumo> {
  late final AddInsumoRegistroController _controller;
  static const _moneyFormatter = BrazilianCurrencyInputFormatter();

  bool get _isSaida => widget.tipo == 2;

  @override
  void initState() {
    super.initState();
    _controller = AddInsumoRegistroController(
      Modular.get<MovimentarEstoqueUsecase>(),
      Modular.get<GetInsumosUsecase>(),
      Modular.get<GetListUsecase>(),
      Modular.get<GetParceirosUsecase>(),
      Modular.get<ResolveCurrentFarmId>(),
      isSaida: _isSaida,
      produtoNovo: widget.produtoNovo,
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
      final result = await _controller.submit();
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
        message: _controller.errorMessage ?? 'Nao foi possivel salvar.',
        isError: true,
      );
    }
  }

  Future<void> _pickDate({required bool validade}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    if (validade) {
      _controller.setValidade(picked);
    } else {
      _controller.setData(picked);
    }
  }

  Future<void> _cadastrarFornecedor() async {
    final farmId = _controller.farmId;
    if (farmId == null) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ParceiroFormPage(
          data: ParceiroFormRouteData(
            kind: ParceiroKind.fornecedor,
            appFazendasId: farmId,
          ),
        ),
      ),
    );
    if (!mounted) return;
    await _controller.reloadFornecedores();
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
              _isSaida ? 'Baixa' : 'Entrada de insumo',
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
            child: _controller.isLoading && _controller.categorias.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isSaida) ..._baixaFields() else ..._entradaFields(),
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
                              backgroundColor: _isSaida
                                  ? const Color(0xFFE53935)
                                  : MyColors.colorPrimary,
                              disabledBackgroundColor: const Color(0xFFBDBDBD),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _controller.isLoading || !_controller.isFormValid
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
                                : Text(
                                    _isSaida ? 'Registrar Baixa' : 'Registrar Entrada',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  List<Widget> _entradaFields() {
    final total = _totalLabel();
    return [
      _dateField(label: 'Data da entrada', onTap: () => _pickDate(validade: false)),
      _select<int>(
        label: 'Categoria',
        value: _controller.categoriaId,
        placeholder: 'Selecione...',
        options: _controller.categorias
            .map((item) => AppSelectOption<int>(value: item.id, label: item.nome))
            .toList(),
        enabled: _controller.categorias.isNotEmpty,
        onChanged: _controller.onCategoria,
      ),
      _select<int>(
        label: 'Subcategoria',
        value: _controller.subcategoriaId,
        placeholder: _controller.categoriaId == null
            ? 'Selecione a categoria primeiro'
            : 'Selecione...',
        options: _controller.subcategorias
            .map((item) => AppSelectOption<int>(value: item.id, label: item.nome))
            .toList(),
        enabled: _controller.categoriaId != null,
        onChanged: _controller.onSubcategoria,
      ),
      _modeToggle(
        left: 'Selecionar existente',
        right: 'Cadastrar novo',
        novo: _controller.produtoNovo,
        onChanged: _controller.onProdutoNovo,
      ),
      if (_controller.produtoNovo)
        _text(
          controller: _controller.nomeController,
          label: 'Produto',
          hint: 'Ex: Ivermectina 1%',
        )
      else
        _select<int>(
          label: 'Produto',
          value: _controller.produtoId,
          placeholder: 'Selecione...',
          options: _controller.produtos
              .map(
                (item) => AppSelectOption<int>(
                  value: item.id,
                  label: _controller.produtoLabel(item),
                ),
              )
              .toList(),
          enabled:
              _controller.categoriaId != null && _controller.subcategoriaId != null,
          onChanged: _controller.onProduto,
        ),
      if (_controller.produtoNovo)
        _select<int>(
          label: 'Unidade de medida',
          value: _controller.unidadeId,
          placeholder: 'Selecione...',
          options: _unidadeOptions(),
          enabled: _controller.unidades.isNotEmpty,
          onChanged: _controller.onUnidade,
        )
      else
        _readOnly(label: 'Unidade de medida', value: _controller.unidadeLabel),
      if (_controller.avisoEntrada != null) _banner(_controller.avisoEntrada!),
      _modeToggle(
        left: 'Fornecedor existente',
        right: 'Cadastrar novo',
        novo: false,
        onChanged: (novo) {
          if (novo) _cadastrarFornecedor();
        },
      ),
      _select<int>(
        label: 'Fornecedor',
        value: _controller.fornecedorId,
        placeholder: 'Selecione...',
        options: _controller.fornecedores
            .map((item) => AppSelectOption<int>(value: item.id, label: item.nome))
            .toList(),
        enabled: _controller.fornecedores.isNotEmpty,
        onChanged: _controller.onFornecedor,
      ),
      _text(
        controller: _controller.qtdController,
        label: 'Quantidade',
        hint: 'Ex: 10',
        number: true,
      ),
      _text(
        controller: _controller.valorController,
        label: 'Valor unitário (R\$)',
        hint: '0,00',
        number: true,
        formatters: [_moneyFormatter],
      ),
      _dateField(
        label: 'Validade (opcional)',
        controller: _controller.validadeController,
        onTap: () => _pickDate(validade: true),
      ),
      _readOnly(label: 'Valor total da entrada', value: total),
      _text(
        controller: _controller.obsController,
        label: 'Observações',
        hint: 'Nota fiscal, lote, condições de armazenamento',
        maxLines: 3,
      ),
    ];
  }

  List<Widget> _baixaFields() {
    return [
      _dateField(label: 'Data', onTap: () => _pickDate(validade: false)),
      _select<int>(
        label: 'Motivo',
        value: _controller.motivoId,
        placeholder: 'Selecione...',
        options: _controller.motivos
            .map((item) => AppSelectOption<int>(value: item.id, label: item.nome))
            .toList(),
        enabled: _controller.motivos.isNotEmpty,
        onChanged: _controller.onMotivo,
      ),
      _select<int>(
        label: 'Produto',
        value: _controller.produtoId,
        placeholder: 'Selecione...',
        options: _controller.produtos
            .map((item) => AppSelectOption<int>(value: item.id, label: item.nome))
            .toList(),
        enabled: _controller.produtos.isNotEmpty,
        onChanged: _controller.onProduto,
      ),
      _readOnly(label: 'Unidade', value: _controller.unidadeLabel),
      if (_controller.avisoBaixa != null) _banner(_controller.avisoBaixa!),
      _text(
        controller: _controller.qtdController,
        label: 'Quantidade a baixar',
        hint: '0',
        number: true,
      ),
      _text(
        controller: _controller.obsController,
        label: 'Observações',
        hint: 'Motivo detalhado da baixa (obrigatório)',
        maxLines: 3,
      ),
    ];
  }

  List<AppSelectOption<int>> _unidadeOptions() {
    return _controller.unidades
        .map((item) => AppSelectOption<int>(value: item.id, label: item.nome))
        .toList();
  }

  String _totalLabel() {
    final qtd = double.tryParse(
      _controller.qtdController.text.trim().replaceAll('.', '').replaceAll(',', '.'),
    );
    final valor = BrazilianCurrency.parse(_controller.valorController.text);
    if (qtd == null || valor == null) return 'R\$ —';
    return BrazilianCurrency.format(qtd * valor);
  }

  Widget _dateField({
    required String label,
    required VoidCallback onTap,
    TextEditingController? controller,
  }) {
    return _shell(
      label: label,
      child: TextField(
        controller: controller ?? _controller.dataController,
        readOnly: true,
        onTap: onTap,
        style: _fieldStyle,
        decoration: _decoration(''),
      ),
    );
  }

  Widget _text({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool number = false,
    int maxLines = 1,
    List<TextInputFormatter>? formatters,
  }) {
    return _shell(
      label: label,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: number
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        inputFormatters: formatters ??
            (number
                ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))]
                : null),
        style: _fieldStyle,
        decoration: _decoration(hint),
      ),
    );
  }

  Widget _select<T>({
    required String label,
    required T? value,
    required String placeholder,
    required List<AppSelectOption<T>> options,
    required bool enabled,
    required ValueChanged<T?> onChanged,
  }) {
    final selected = options.any((item) => item.value == value) ? value : null;
    return _shell(
      label: label,
      child: AppSelectOverlay<T>(
        value: selected,
        placeholder: placeholder,
        options: options,
        enabled: enabled,
        onChanged: onChanged,
      ),
    );
  }

  Widget _readOnly({required String label, required String value}) {
    return _shell(
      label: label,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEBEBEB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(value, style: _fieldStyle),
      ),
    );
  }

  Widget _banner(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF313131),
          fontSize: 13,
          fontFamily: 'Montserrat',
          height: 1.4,
        ),
      ),
    );
  }

  Widget _modeToggle({
    required String left,
    required String right,
    required bool novo,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Expanded(child: _modeButton(left, !novo, () => onChanged(false))),
          const SizedBox(width: 8),
          Expanded(child: _modeButton(right, novo, () => onChanged(true))),
        ],
      ),
    );
  }

  Widget _modeButton(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? MyColors.colorPrimary : const Color(0xFFEBEBEB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF313131),
            fontSize: 13,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _shell({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 6),
        child,
        const SizedBox(height: 18),
      ],
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF8C8C8C),
        fontSize: 14,
        fontFamily: 'Montserrat',
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

  TextStyle get _fieldStyle => const TextStyle(
        color: Color(0xFF313131),
        fontSize: 14,
        fontFamily: 'Montserrat',
      );
}
