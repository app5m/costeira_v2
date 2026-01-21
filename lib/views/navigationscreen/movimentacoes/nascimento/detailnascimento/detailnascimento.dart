import 'package:flutter/material.dart';

import '../../../../../theme/colors.dart';

class DetailNascimento extends StatefulWidget {
  const DetailNascimento({super.key});

  @override
  State<DetailNascimento> createState() => _DetailNascimentoState();
}

class _DetailNascimentoState extends State<DetailNascimento> {

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
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
            letterSpacing: 0.10,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Color(0xFF313131),
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
            onTap: (){
              Navigator.pop(context);
            },child: Icon(Icons.arrow_back_ios, color: Colors.white,)),
        title: Text(
          'Detalhes do nascimento',
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
          child: Column(children: [
            SizedBox(height: 16,),
            buildTextField("Brinco",  '2034',),
            buildTextField("Data", "02/04/2025"),
            buildTextField("Categoria de origem", 'Matriz prenhe → Parida',),
            Row(
              children: [
                Text(
                  'Sexo ',
                  style: TextStyle(
                    color: const Color(0xFF313131),
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                    letterSpacing: 0.10,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                RadioGroup<int>(
                  groupValue: _selectedValue,
                  onChanged: (int? value) {
                    setState(() {
                      _selectedValue = value;
                    });
                  },
                  child: Row(
                    children: [
                      Row(
                        children: [
                          Radio<int>(
                            side: BorderSide(),
                            value: 1, // Valor único para este botão
                            groupValue: _selectedValue,
                            onChanged: (int? value) {
                              setState(() => _selectedValue = value);
                            },
                          ),
                          Text('Macho', style: TextStyle(
                            color: const Color(0xFF8C8C8C),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                            letterSpacing: 0.10,
                          ),),
                        ],
                      ),
                      SizedBox(width: 20),
                      Row(
                        children: [
                          Radio<int>(
                            side: BorderSide(),
                            value: 2, // Valor único para o segundo botão
                            groupValue: _selectedValue,
                            onChanged: (int? value) {
                              setState(() => _selectedValue = value);
                            },
                          ),
                          Text('Fêmea', style: TextStyle(
                            color: const Color(0xFF8C8C8C),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                            letterSpacing: 0.10,
                          ),),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),


            // buildTextField("Peso médio", "322 kg"),
            // buildTextField("Preço / KG",   'R\$ 15,20/kg',),
            // buildTextField("Valor total",  'R\$ 58.240,00',),
            // buildTextField("Destino", 'Fazenda Santa Helena – Uberaba/MG',),
            // buildTextField("Observações", "Lote com boa condição corporal, vacinado, transportado via caminhão boiadeiro."),

            const SizedBox(height: 32),
          ],),
        ),
      ),
    );
  }
  int? _selectedValue = 2;
}
