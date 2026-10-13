import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/features/manejos_animais/presentation/page_controllers/manejo_campo_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ManejoCampoPage extends StatefulWidget {
  const ManejoCampoPage({super.key});

  @override
  State<ManejoCampoPage> createState() => _ManejoCampoPageState();
}

class _ManejoCampoPageState extends State<ManejoCampoPage> {
  late final ManejoCampoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<ManejoCampoController>()..init();
    _controller.addListener(_sync);
  }

  void _sync() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_sync);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Manejo de campo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _controller.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                if (_controller.error != null) _erro(_controller.error!),
                _dataField(),
                _select(
                  'Piquete',
                  _controller.piqueteId,
                  _controller.piquetes
                      .map((item) => AppSelectOption(value: item.id, label: item.nome))
                      .toList(),
                  _controller.setPiquete,
                ),
                const _Label('Área (ha)'),
                _caixa(_area()),
                _select(
                  'Tipo de manejo',
                  _controller.tipoId,
                  _controller.tipos
                      .map((item) => AppSelectOption(value: item.id, label: item.nome))
                      .toList(),
                  _controller.setTipo,
                ),
                const _Label('Uso de insumo'),
                _escolha(
                  left: 'Sem insumo',
                  right: 'Usar produto',
                  leftSelected: !_controller.usarProduto,
                  onLeft: () => _controller.setUsarProduto(false),
                  onRight: () => _controller.setUsarProduto(true),
                ),
                const SizedBox(height: 18),
                if (_controller.usarProduto) ..._produto(),
                const _Label('Observações'),
                _input(controller: _controller.obs, hint: 'Detalhes do manejo...', maxLines: 3),
                CustomButton(
                  text: 'Registrar manejo',
                  enabled: _controller.podeRegistrar,
                  isLoading: _controller.saving,
                  onPressed: _registrar,
                ),
              ],
            ),
    );
  }

  List<Widget> _produto() {
    if (_controller.insumos.isEmpty) {
      return [
        const Text(
          'Nenhum produto cadastrado no estoque.',
          style: TextStyle(color: Color(0xFF8C8C8C), fontSize: 13, fontFamily: 'Montserrat'),
        ),
        const SizedBox(height: 18),
      ];
    }
    final produto = _controller.insumo;
    final porHa = _controller.dosagem == ManejoCampoDosagem.hectare;
    return [
      _select(
        'Produto',
        _controller.insumoId,
        _controller.insumos
            .map((item) => AppSelectOption(value: item.id, label: item.nome))
            .toList(),
        _controller.setInsumo,
      ),
      if (produto != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Text(
            'Unidade ${produto.unidade?.nome ?? ''} · Saldo ${produto.qtdTotal ?? 0}',
            style: const TextStyle(color: Color(0xFF313131), fontSize: 13, fontFamily: 'Montserrat'),
          ),
        ),
      const _Label('Modo de dosagem'),
      _escolha(
        left: 'Por hectare',
        right: 'Área total',
        leftSelected: porHa,
        onLeft: () => _controller.setDosagem(ManejoCampoDosagem.hectare),
        onRight: () => _controller.setDosagem(ManejoCampoDosagem.area),
      ),
      const SizedBox(height: 18),
      _Label(porHa ? 'Quantidade por ha' : 'Quantidade'),
      _input(
        controller: _controller.quantidade,
        hint: '0',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
      if (_controller.saldoInsuficiente)
        _erro('Saldo insuficiente no estoque para esta aplicação.')
      else
        _caixa('Total ${_fmt(_controller.quantidadeTotal)} ${produto?.unidade?.nome ?? ''}'),
    ];
  }

  String _area() {
    final area = _controller.area;
    if (area == null) {
      return '—';
    }
    return '${_fmt(area)} ha';
  }

  String _fmt(double value) {
    return value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  }

  Future<void> _registrar() async {
    final erro = await _controller.registrar();
    if (!mounted) {
      return;
    }
    if (erro != null) {
      AppSnackBar.show(context: context, message: erro);
      return;
    }
    AppSnackBar.show(context: context, message: 'Manejo de campo registrado.', isError: false);
    Navigator.of(context).pop();
  }

  Widget _dataField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('Data'),
        _input(
          controller: _controller.data,
          hint: '00/00/0000',
          readOnly: true,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _controller.dataAtual,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              _controller.setData(picked);
            }
          },
        ),
      ],
    );
  }

  Widget _select(
    String label,
    int? value,
    List<AppSelectOption<int>> options,
    ValueChanged<int?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        AppSelectOverlay<int>(
          value: value,
          placeholder: 'Selecionar',
          options: options,
          onChanged: onChanged,
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    bool readOnly = false,
    TextInputType? keyboardType,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF8C8C8C), fontSize: 14, fontFamily: 'Montserrat'),
          filled: true,
          fillColor: const Color(0xFFEBEBEB),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _caixa(String texto) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14, color: Color(0xFF313131)),
      ),
    );
  }

  Widget _escolha({
    required String left,
    required String right,
    required bool leftSelected,
    required VoidCallback onLeft,
    required VoidCallback onRight,
  }) {
    return Row(
      children: [
        Expanded(child: _opcao(left, leftSelected, onLeft)),
        const SizedBox(width: 8),
        Expanded(child: _opcao(right, !leftSelected, onRight)),
      ],
    );
  }

  Widget _opcao(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFD9EDE1) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? MyColors.colorPrimary : const Color(0xFFE2E2E2),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? MyColors.colorPrimary : const Color(0xFF313131),
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _erro(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        texto,
        style: const TextStyle(color: Colors.red, fontSize: 12, fontFamily: 'Montserrat'),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF313131), fontSize: 14, fontFamily: 'Montserrat'),
      ),
    );
  }
}
