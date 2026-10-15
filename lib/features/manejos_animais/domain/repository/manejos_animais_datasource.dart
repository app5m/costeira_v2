import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/manejos_animais/domain/entities/manejo_animal_lista.dart';

abstract class ManejosAnimaisDatasource {
  Future<ApiMessage> adicionar({
    required int appUsersId,
    required int appFazendasId,
    required Map<String, dynamic> fields,
  });

  Future<ApiMessage> adicionarCampo({
    required int appUsersId,
    required int appFazendasId,
    required Map<String, dynamic> fields,
  });

  Future<ApiMessage> adicionarReprodutivo({
    required int appUsersId,
    required int appFazendasId,
    required Map<String, dynamic> fields,
  });

  Future<ApiMessage> excluir({
    required int appUsersId,
    required int appFazendasId,
    required int id,
  });

  Future<ManejoAnimalListaEntity> listar({
    required int appUsersId,
    required int appFazendasId,
    required int idCategoria,
    bool? estacaoAtiva,
    String? dataReferencia,
  });
}
