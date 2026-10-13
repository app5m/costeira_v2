import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';

class AnimalLotModel extends AnimalLotEntity {
  const AnimalLotModel({
    required super.id,
    required super.appUsersId,
    required super.nome,
    super.appPotreirosId,
    super.createAt,
    super.updateAt,
    super.animalsCount,
    super.sexo,
    super.categoriaNome,
    super.animalIds,
    super.temBrinco,
    super.idLocal,
    super.syncStatus,
    super.pendingAction,
    super.isLocalOnly = false,
  });

  factory AnimalLotModel.fromJson(Map<String, dynamic> json) {
    final animals = json['animais'] as List<dynamic>? ?? const [];
    final sexos = animals
        .whereType<Map>()
        .map((item) => int.tryParse(item['sexo']?.toString() ?? ''))
        .whereType<int>()
        .toSet();
    final mapas = animals.whereType<Map>().toList();
    final categorias = mapas
        .map((item) => item['categoria_nome']?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toSet();
    final ids = <int>[
      for (final item in mapas)
        if (int.tryParse(item['id']?.toString() ?? '') case final int id) id,
    ];

    return AnimalLotModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      appUsersId: int.tryParse(json['app_users_id']?.toString() ?? '') ?? 0,
      nome: json['nome']?.toString() ?? '',
      appPotreirosId:
          int.tryParse(json['app_potreiros_id']?.toString() ?? '') ??
          int.tryParse(json['id_potreiro']?.toString() ?? ''),
      createAt: json['create_at']?.toString(),
      updateAt: json['update_at']?.toString(),
      animalsCount: animals.length,
      sexo: sexos.length == 1 ? sexos.first : null,
      categoriaNome: categorias.length == 1 ? categorias.first : null,
      animalIds: ids,
      temBrinco: mapas.any((item) {
        final brinco = item['brinco']?.toString().trim() ?? '';
        return brinco.isNotEmpty && brinco != 'null';
      }),
      idLocal: json['idLocal']?.toString(),
      syncStatus: json['syncStatus']?.toString(),
      pendingAction: json['pendingAction']?.toString(),
      isLocalOnly: json['isLocalOnly'] == true,
    );
  }
}
