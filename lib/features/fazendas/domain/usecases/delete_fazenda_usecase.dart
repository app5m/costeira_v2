import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/fazendas/domain/repository/fazendas_datasource.dart';

class DeleteFazendaUsecase {
  const DeleteFazendaUsecase(this._datasource);

  final FazendasDatasource _datasource;

  Future<ApiMessage> call({required int id, required int appUsersId}) {
    return _datasource.deleteFazenda(id: id, appUsersId: appUsersId);
  }
}
