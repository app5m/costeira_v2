import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/mortes/domain/entities/delete_morte_entity.dart';
import 'package:costeira/features/movimentacoes/mortes/domain/repository/mortes_datasource.dart';

class DeleteMorteUsecase {
  const DeleteMorteUsecase(this._datasource);

  final MortesDatasource _datasource;

  Future<ApiMessage> call(DeleteMorteEntity morte) {
    return _datasource.deleteMorte(morte);
  }
}
