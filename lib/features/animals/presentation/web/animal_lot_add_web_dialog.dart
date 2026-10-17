import 'package:costeira/app/app_routes.dart';
import 'package:costeira/features/animals/presentation/web/animal_lot_form_web_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

Future<Map<String, dynamic>?> openAnimalLotAdd(BuildContext context) {
  if (!kIsWeb) {
    return Modular.to.pushNamed<Map<String, dynamic>?>(AppRoutes.animalLotsAdd);
  }
  return showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const AnimalLotFormWebDialog.add(),
  );
}
