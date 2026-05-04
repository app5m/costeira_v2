import 'package:costeira/features/tasks/domain/entities/task_responsavel_entity.dart';
import 'package:costeira/features/tasks/presentation/helpers/task_formatters.dart';
import 'package:flutter/material.dart';

import '../../../../theme/colors.dart';

class DetailTaskResponsavel extends StatefulWidget {
  const DetailTaskResponsavel({super.key, required this.responsavel});

  final TaskResponsavelEntity responsavel;

  @override
  State<DetailTaskResponsavel> createState() => _DetailTaskResponsavelState();
}

class _DetailTaskResponsavelState extends State<DetailTaskResponsavel> {
  Widget buildTextField(String label, String value) {
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
        const SizedBox(height: 6),
        TextFormField(
          readOnly: true,
          initialValue: value,
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
            letterSpacing: 0.10,
          ),
          decoration: InputDecoration(
            hintText: value,
            hintStyle: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              height: 1.50,
              letterSpacing: 0.10,
            ),
            filled: true,
            fillColor: const Color(0xFFEBEBEB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 16,
            ),
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
    final responsavel = widget.responsavel;
    final email = responsavel.email.trim().isEmpty ? '-' : responsavel.email;
    final celular = responsavel.celular.trim().isEmpty
        ? '-'
        : formatTaskResponsavelPhone(responsavel.celular);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Detalhes do responsavel',
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
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              buildTextField('Nome', responsavel.nome),
              buildTextField('E-mail', email),
              buildTextField('Celular', celular),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
