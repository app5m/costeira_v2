import 'package:costeira/app/app_routes.dart';
import 'package:costeira/features/potreiros/presentation/web/potreiro_form_web_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

Future<Map<String, dynamic>?> openPotreiroAdd(BuildContext context) {
  if (!kIsWeb) {
    return Modular.to.pushNamed<Map<String, dynamic>?>(AppRoutes.potreirosAdd);
  }
  return showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PotreiroFormWebDialog(),
  );
}
