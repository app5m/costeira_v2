import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/animals/presentation/pages/animals_page.dart';
import 'package:costeira/features/animals/presentation/pages/animals/add_animal.dart';
import 'package:costeira/features/animals/presentation/pages/animals/detail_animal.dart';
import 'package:costeira/features/animals/presentation/pages/animals/edit_animal.dart';
import 'package:costeira/features/animals/presentation/pages/lotes/add_lote.dart';
import 'package:costeira/features/animals/presentation/pages/lotes/edit_lote.dart';
import 'package:costeira/features/animals/presentation/pages/lotes/lotes_page.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AnimalsRoutes {
  static void register(RouteManager r) {
    r.child('/', child: (_) => const AnimalsPage());
    r.child('/add-animal-page', child: (_) => const AddAnimal());
    r.child(
      '/edit-animal-page',
      child: (_) {
        final animal = Modular.args.data as AnimalEntity;
        return EditAnimal(animal: animal);
      },
    );
    r.child(
      '/detail-animal-page',
      child: (_) {
        final animal = Modular.args.data as AnimalEntity;
        return DetailAnimal(animal: animal);
      },
    );
    r.child('/lots', child: (_) => const LotesPage());
    r.child('/add-lot-page', child: (_) => const AddLote());
    r.child(
      '/edit-lot-page',
      child: (_) {
        final lot = Modular.args.data as AnimalLotEntity;
        return EditLote(lot: lot);
      },
    );
  }
}
