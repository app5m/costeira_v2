import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

const fundoFinanceiro = Color(0xFFF6F4EE);

String reais(num valor) {
  final negativo = valor < 0;
  final fixo = valor.abs().toStringAsFixed(2);
  final partes = fixo.split('.');
  final inteiro = partes[0];
  final buffer = StringBuffer();
  for (var i = 0; i < inteiro.length; i++) {
    final restante = inteiro.length - i;
    if (i > 0 && restante % 3 == 0) buffer.write('.');
    buffer.write(inteiro[i]);
  }
  final texto = 'R\$ $buffer,${partes[1]}';
  return negativo ? '-$texto' : texto;
}

class SecaoRotulo extends StatelessWidget {
  const SecaoRotulo(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: Color(0xFF6B6B6B),
      ),
    );
  }
}

class GrupoChips extends StatelessWidget {
  const GrupoChips({
    super.key,
    required this.opcoes,
    required this.selecionado,
    required this.aoEscolher,
    this.travados = const {},
  });

  final List<String> opcoes;
  final String? selecionado;
  final ValueChanged<String> aoEscolher;
  final Set<String> travados;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final opcao in opcoes)
          _ChipOpcao(
            rotulo: opcao,
            ativo: opcao == selecionado,
            travado: travados.contains(opcao),
            aoToque: () => aoEscolher(opcao),
          ),
      ],
    );
  }
}

class _ChipOpcao extends StatelessWidget {
  const _ChipOpcao({
    required this.rotulo,
    required this.ativo,
    required this.travado,
    required this.aoToque,
  });

  final String rotulo;
  final bool ativo;
  final bool travado;
  final VoidCallback aoToque;

  @override
  Widget build(BuildContext context) {
    final fundo = ativo ? MyColors.colorPrimary : Colors.white;
    final letra = ativo ? Colors.white : const Color(0xFF3D5346);
    return Material(
      color: fundo,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: aoToque,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ativo ? MyColors.colorPrimary : const Color(0xFFD7D1C4),
            ),
          ),
          child: Text(
            rotulo,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: travado && !ativo ? const Color(0xFF8A8A8A) : letra,
            ),
          ),
        ),
      ),
    );
  }
}

class CampoFinanceiro extends StatelessWidget {
  const CampoFinanceiro({
    super.key,
    required this.rotulo,
    required this.child,
  });

  final String rotulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SecaoRotulo(rotulo),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

InputDecoration decoracaoCampo(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 13,
      color: Color(0xFF8A8A8A),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: MyColors.colorPrimary),
    ),
  );
}

class CartaoBranco extends StatelessWidget {
  const CartaoBranco({super.key, required this.child, this.aoToque});

  final Widget child;
  final VoidCallback? aoToque;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: aoToque,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE6E6E6)),
          ),
          child: child,
        ),
      ),
    );
  }
}

Future<void> avisoDesenvolvimento(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(
        'Em desenvolvimento',
        style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
      ),
      content: const Text(
        'Esse tipo de lançamento ainda não está disponível.',
        style: TextStyle(fontFamily: 'Montserrat'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Ok'),
        ),
      ],
    ),
  );
}
