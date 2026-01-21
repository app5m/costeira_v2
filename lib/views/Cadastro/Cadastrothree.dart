import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../navigationscreen/navigationscreen.dart';
import '../validationCode/validation.code.dart';

class Cadastrotree extends StatefulWidget {
  const Cadastrotree({super.key});

  @override
  State<Cadastrotree> createState() => _CadastrotreeState();
}

class _CadastrotreeState extends State<Cadastrotree> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final _nomeFantasiaController = TextEditingController();
  final _razaoSocialController = TextEditingController();
  final _inscricaoEstadualController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    _nomeFantasiaController.dispose();
    _razaoSocialController.dispose();
    _inscricaoEstadualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color(0xFF00823A),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Topo verde fixo
            Container(
              height: 80,
              width: double.infinity,
              color: const Color(0xFF00823A),
            ),

            Column(
              children: [
                const SizedBox(height: 20), // Espaço pro verde

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
                          padding: const EdgeInsets.all(20.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header com back button
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
                                    color: Color(0xFF77787C),
                                    fontSize: 14,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                _buildTextField('E-mail', emailController, 'exemplo@email.com', null),
                                const SizedBox(height: 16),

                                _buildTextField('Nome Fantasia', _nomeFantasiaController, 'Digite o nome fantasia', null),
                                const SizedBox(height: 16),

                                _buildTextField('Razão Social', _razaoSocialController, 'Digite a razão social', null),

                                const SizedBox(height: 32), // Espaço antes do botão


                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
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
                                  )
                                ),
                              ),
                              SizedBox(height: 32,)
                            ],
                          ),
                        ),
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

  Widget _buildTextField(String label, TextEditingController controller,
      String hintText, String? Function(String?)? validator) {
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13.50),
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

  void _onSubmit() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => ValidationCode(email: 'a@a.com', password: '', lat: '', long: '', tipo: 1,)),
    );
  }
}
