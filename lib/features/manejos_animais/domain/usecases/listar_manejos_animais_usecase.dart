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
}
