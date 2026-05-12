import 'package:flutter/material.dart';

import '../../../../../theme/colors.dart';

class AddMorte extends StatefulWidget {
  const AddMorte({super.key});

  @override
  State<AddMorte> createState() => _AddMorteState();
}

class _AddMorteState extends State<AddMorte> {
  Widget buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
            letterSpacing: 0.10,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          style: TextStyle(
            color: Color(0xFF8C8C8C),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
            letterSpacing: 0.10,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              height: 1.50,
              letterSpacing: 0.10,
            ),
            filled: true,
            fillColor: Color(0xFFEBEBEB),
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 16),
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

  Widget buildTextField5Line(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
            letterSpacing: 0.10,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          minLines: 3,
          maxLines: 3,
          style: TextStyle(
            color: Color(0xFF8C8C8C),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
            letterSpacing: 0.10,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              height: 1.50,
              letterSpacing: 0.10,
            ),
            filled: true,
            fillColor: Color(0xFFEBEBEB),
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 16),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          'Adicionar morte',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 16),
              buildTextField("Data", "00/00/0000"),
              buildTextField("Categoria", "Selecionar"),
              buildTextField("Potreiro", "Selecione"),
              buildTextField("Causa", "Selecione"),
              buildTextField("Valor total", "R\$ 00,00"),
              buildTextField5Line(
                "Observações",
                "Ex: Animal apresentava diarrei..",
              ),

              const SizedBox(height: 16),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.colorPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Salvar",
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
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
