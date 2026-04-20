import 'package:costeira/features/animals/animals_binds.dart';
import 'package:costeira/features/animals/animals_routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AnimalsModule extends Module {
  @override
  void binds(i) => AnimalsBinds.register(i);

  @override
  void routes(r) => AnimalsRoutes.register(r);
}
