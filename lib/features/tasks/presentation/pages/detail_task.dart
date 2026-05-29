import 'package:costeira/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter/material.dart';

import '../../../../theme/colors.dart';

class DetailTask extends StatefulWidget {
  const DetailTask({super.key, required this.task});

  final TaskEntity task;

  @override
  State<DetailTask> createState() => _DetailTaskState();
}

class _DetailTaskState extends State<DetailTask> {
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
    final task = widget.task;

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
          'Detalhes da tarefa',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                buildTextField('O que fazer', task.descricao),
                buildTextField('Responsável', task.responsavel?.nome ?? '-'),
                buildTextField('Tipo', task.tipo == 2 ? 'Mensal' : 'Datas'),
                buildTextField('Urgência', task.urgenciaNome),
                buildTextField('Status', task.statusNome),
                buildTextField('Datas', _datesLabel(task)),
                buildTextField(
                  'Observações',
                  task.obs.trim().isEmpty ? '-' : task.obs,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _datesLabel(TaskEntity task) {
    if (task.datas.isEmpty) {
      return '-';
    }
    return task.datas
        .map((item) => item.mesAno ?? item.data.split(' ').first)
        .join(', ');
  }
}
