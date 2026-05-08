import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/pages/suplementacao/add_suplemento.dart';
import 'package:flutter/material.dart';

class EditSuplemento extends StatelessWidget {
  const EditSuplemento({super.key, required this.suplemento});

  final Suplemento suplemento;

  @override
  Widget build(BuildContext context) {
    return AddSuplemento(suplemento: suplemento);
  }
}
