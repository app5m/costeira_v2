import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/components/web_page_dialog.dart';
import 'package:costeira/features/animals/presentation/pages/lotes/add_lote.dart';
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
    builder: (_) => const WebPageDialog(
      title: 'Adicionar lote',
      width: 560,
      maxHeight: 460,
      child: AddLote(),
    ),
  );
}
