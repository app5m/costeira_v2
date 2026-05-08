import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/pages/manejo/add_manejo.dart';
import 'package:flutter/material.dart';

class EditManejo extends StatelessWidget {
  const EditManejo({super.key, required this.manejo});

  final Manejo manejo;

  @override
  Widget build(BuildContext context) {
    return AddManejo(manejo: manejo);
  }
}
