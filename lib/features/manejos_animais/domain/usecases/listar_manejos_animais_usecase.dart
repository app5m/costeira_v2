import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/manejos_animais/domain/entities/manejo_animal_lista.dart';
import 'package:costeira/features/manejos_animais/domain/repository/manejos_animais_datasource.dart';

class ListarManejosAnimaisUsecase {
  const ListarManejosAnimaisUsecase(this._datasource);

  final ManejosAnimaisDatasource _datasource;

  Future<ManejoAnimalListaEntity> call({
    required int appUsersId,
    required int appFazendasId,
    required int idCategoria,
    bool? estacaoAtiva,
    String? dataReferencia,
  }) {
    return _datasource.listar(
      appUsersId: appUsersId,
      appFazendasId: appFazendasId,
      idCategoria: idCategoria,
      estacaoAtiva: estacaoAtiva,
      dataReferencia: dataReferencia,
    );
  }

  Future<ApiMessage> excluir({
    required int appUsersId,
    required int appFazendasId,
    required int id,
  }) {
    return _datasource.excluir(
      appUsersId: appUsersId,
      appFazendasId: appFazendasId,
      id: id,
    );
  }
}
