import 'package:costeira/views/login/recuperarsenha/recuperasenha.dart';
import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../validationCode/validation.code.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: MyColors.colorPrimary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Topo verde com bordas arredondadas do card branco
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Linha com back + título
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
                          'Entrar',
                          style: TextStyle(
                            color: const Color(0xFF313131),
                            fontSize: 24,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
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
                        const SizedBox(height: 32),

                        // Campo E-mail
                        const Text(
                          'E-mail',
                          style: TextStyle(
                            color: const Color(0xFF313131),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                            letterSpacing: 0.10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 55,
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              color: Color(0xFF000000),
                              fontSize: 14,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'exemplo@email.com',
                              hintStyle: TextStyle(
                                color: Color(0xFFBDBDBD),
                                fontSize: 14,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFE5E5E5),
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(6)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF00866A),
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(6)),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Campo Senha
                        const Text(
                          'Digite sua senha',
                          style: TextStyle(
                            color: const Color(0xFF313131),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                            letterSpacing: 0.10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 55,
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            style: const TextStyle(
                              color: Color(0xFF000000),
                              fontSize: 14,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Senha',
                              hintStyle: const TextStyle(
                                color: Color(0xFFBDBDBD),
                                fontSize: 14,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFE5E5E5),
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(6)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF00866A),
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(6)),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RecoverPasswordPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Esqueceu sua senha?',
                              style: TextStyle(
                                color: const Color(0xFF8C8C8C),
                                fontSize: 14,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                                letterSpacing: 0.10,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Botão Avançar
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ValidationCode(
                                    email: 'email1',
                                    password: 'password',
                                    lat: 'lat',
                                    long: 'long',
                                    tipo: 1,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MyColors.colorPrimary,
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

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModalBottomSheetPassword(BuildContext context) {
    // pode reaproveitar o seu método atual aqui
  }
}
