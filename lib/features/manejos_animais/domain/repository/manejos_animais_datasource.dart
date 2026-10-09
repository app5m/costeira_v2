import 'package:costeira/core/models/api_message.dart';

abstract class ManejosAnimaisDatasource {
  Future<ApiMessage> adicionar({
    required int appUsersId,
    required int appFazendasId,
    required Map<String, dynamic> fields,
  });
}
