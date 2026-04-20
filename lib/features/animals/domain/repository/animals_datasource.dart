import 'package:costeira/features/animals/domain/entities/animal_charts_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_charts_filter_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lots_filter_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lots_list_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_upsert_entity.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/animals/domain/entities/animals_filter_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_upsert_entity.dart';
import 'package:costeira/features/animals/domain/entities/animals_list_entity.dart';
import 'package:costeira/features/animals/domain/entities/delete_animal_entity.dart';
import 'package:costeira/features/animals/domain/entities/delete_animal_lot_entity.dart';

abstract class AnimalsDatasource {
  Future<ApiMessage> createAnimal(AnimalUpsertEntity animal);
  Future<ApiMessage> updateAnimal(AnimalUpsertEntity animal);
  Future<AnimalsListEntity> getAnimals(AnimalsFilterEntity filter);
  Future<ApiMessage> deleteAnimal(DeleteAnimalEntity animal);
  Future<ApiMessage> createAnimalLot(AnimalLotUpsertEntity lot);
  Future<ApiMessage> updateAnimalLot(AnimalLotUpsertEntity lot);
  Future<AnimalLotsListEntity> getAnimalLots(AnimalLotsFilterEntity filter);
  Future<ApiMessage> deleteAnimalLot(DeleteAnimalLotEntity lot);
  Future<AnimalChartsEntity> getAnimalCharts(AnimalChartsFilterEntity filter);
}
