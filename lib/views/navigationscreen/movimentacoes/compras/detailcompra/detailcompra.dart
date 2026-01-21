import 'package:flutter/material.dart';

import '../../../../../theme/colors.dart';

class DetailCompra extends StatefulWidget {
  const DetailCompra({super.key});

  @override
  State<DetailCompra> createState() => _DetailCompraState();
}

class _DetailCompraState extends State<DetailCompra> {

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
          'Detalhes da compra',
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
            buildTextField("Data",  '12/03/2025',),
            buildTextField("Categoria", "Novilha"),
            buildTextField("Quantidade", '12 animais',),

            buildTextField("Peso médio", "322 kg"),
            buildTextField("Preço / KG",   'R\$ 15,20/kg',),
            buildTextField("Valor total",  'R\$ 58.240,00',),
            buildTextField("Origem", 'Fazenda Santa Helena – Uberaba/MG',),
            buildTextField("Observações", "Lote com boa condição corporal, vacinado, transportado via caminhão boiadeiro."),

            const SizedBox(height: 32),
          ],),
        ),
      ),
    );
  }
}
