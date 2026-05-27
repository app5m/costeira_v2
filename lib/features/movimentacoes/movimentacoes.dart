import 'package:costeira/features/movimentacoes/abigeatos/abigeatos.dart';
import 'package:costeira/features/movimentacoes/abortos/abortos.dart';
import 'package:costeira/features/movimentacoes/consumo/consumo.dart';
import 'package:costeira/features/movimentacoes/nascimento/presentation/pages/nascimentos.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/pages/compras.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/presentation/pages/trocas.dart';
import 'package:costeira/features/movimentacoes/transferencias/transferencia.dart';
import 'package:costeira/features/movimentacoes/vendas/presentation/pages/vendas.dart';
import 'package:flutter/material.dart';

import 'mortes/presentation/pages/mortes.dart';

class Movimentacoes extends StatefulWidget {
  const Movimentacoes({super.key});

  @override
  State<Movimentacoes> createState() => _MovimentacoesState();
}

class _MovimentacoesState extends State<Movimentacoes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Compras()),
                );
              },
              child: buttonMotivetion('Compras'),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Vendas()),
                );
              },
              child: buttonMotivetion('Vendas'),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Mortes()),
                );
              },
              child: buttonMotivetion('Mortes'),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Nascimentos()),
                );
              },
              child: buttonMotivetion('Nascimentos'),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrocaCategoria()),
                );
              },
              child: buttonMotivetion('Trocas de categoria'),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Abigeatos()),
                );
              },
              child: buttonMotivetion('Abigeatos'),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Abortos()),
                );
              },
              child: buttonMotivetion('Abortos'),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Consumo()),
                );
              },
              child: buttonMotivetion('Consumo (carnear)'),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Transferencia()),
                );
              },
              child: buttonMotivetion('Transferências de campo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buttonMotivetion(String title) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: const Color(0xFFEBEBEB)),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: Colors.black),
        ],
      ),
    );
  }
}
