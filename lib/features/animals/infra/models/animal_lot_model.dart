import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';

class AnimalLotModel extends AnimalLotEntity {
  const AnimalLotModel({
    required super.id,
    required super.appUsersId,
    required super.nome,
    super.createAt,
    super.updateAt,
    super.animalsCount,
  });

  factory AnimalLotModel.fromJson(Map<String, dynamic> json) {
    final animals = json['animais'] as List<dynamic>? ?? const [];

    return AnimalLotModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      appUsersId: int.tryParse(json['app_users_id']?.toString() ?? '') ?? 0,
      nome: json['nome']?.toString() ?? '',
      createAt: json['create_at']?.toString(),
      updateAt: json['update_at']?.toString(),
      animalsCount: animals.length,
    );
  }
}
