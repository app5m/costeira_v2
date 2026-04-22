import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class PrimarySectionAppBar extends AppBar {
  PrimarySectionAppBar({
    super.key,
    required BuildContext context,
    required String title,
  }) : super(
         backgroundColor: MyColors.colorPrimary,
         foregroundColor: Colors.white,
         title: Text(
           title,
           style: const TextStyle(
             color: Colors.white,
             fontSize: 16,
             fontWeight: FontWeight.w600,
           ),
         ),
         leading: IconButton(
           icon: const Icon(Icons.arrow_back_ios),
           onPressed: () => Modular.to.pop(),
         ),
       );
}
