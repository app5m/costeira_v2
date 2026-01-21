import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import 'cadastrotwo.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final _formKey = GlobalKey<FormState>();
  final _cnpjController = TextEditingController();
  final _nomeFantasiaController = TextEditingController();
  final _razaoSocialController = TextEditingController();
  final _inscricaoEstadualController = TextEditingController();

  @override
  void dispose() {
    _cnpjController.dispose();
    _nomeFantasiaController.dispose();
    _razaoSocialController.dispose();
    _inscricaoEstadualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00823A),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Faixa verde de fundo
            Container(
              height: 80,
              width: double.infinity,
              color: const Color(0xFF00823A),
            ),

            // Conteúdo
            Column(
              children: [
                // deixa um espaço para a faixa verde
                const SizedBox(height: 20),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: const Icon(Icons.arrow_back_ios, size: 20),
                                    ),

                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Cadastrar',
                                  style: TextStyle(
                                    color: Color(0xFF313131),
                                    fontSize: 24,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Preencha os campos abaixo.',
                                  style: TextStyle(
                                    color: const Color(0xFF8C8C8C),
                                    fontSize: 14,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                    letterSpacing: 0.10,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                _buildTextField(
                                  'CNPJ',
                                  _cnpjController,
                                  '00.000.000/0000-00',
                                      (value) => _validateCNPJ(value),
                                ),
                                const SizedBox(height: 16),

                                _buildTextField(
                                  'Nome Fantasia',
                                  _nomeFantasiaController,
                                  'Nome Fantasia',
                                      (value) =>
                                  (value == null || value.isEmpty)
                                      ? 'Campo obrigatório'
                                      : null,
                                ),
                                const SizedBox(height: 16),

                                _buildTextField(
                                  'Razão Social',
                                  _razaoSocialController,
                                  'Razão Social',
                                      (value) =>
                                  (value == null || value.isEmpty)
                                      ? 'Campo obrigatório'
                                      : null,
                                ),
                                const SizedBox(height: 16),

                                _buildTextField(
                                  'Inscrição Estadual',
                                  _inscricaoEstadualController,
                                  '000.000.000',
                                      (value) => null,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(children: [


                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _onSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00823A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Avançar',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                    height: 1.50,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      String hintText,
      String? Function(String?)? validator,
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
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          style: const TextStyle(
            color: Color(0xFF8C8C8C),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
            letterSpacing: 0.10,
          ),
          decoration: _inputDecoration(hintText),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFEBEBEB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEBEBEB), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEBEBEB), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEBEBEB), width: 1),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 13.5),
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF8C8C8C),
        fontSize: 14,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w400,
        height: 1.50,
        letterSpacing: 0.10,
      ),
    );
  }

  String? _validateCNPJ(String? value) {
    if (value == null || value.isEmpty) return 'Campo obrigatório';
    final cleanCNPJ = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanCNPJ.length != 14) return 'CNPJ inválido';
    return null;
  }

  void _onSubmit() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const Cadastrotwo()),
    );
  }
}

