import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';

class IndicadoresRequestModel {
  const IndicadoresRequestModel({
    required this.appUsersId,
    required this.appFazendasId,
    this.appAnimaisLotesId,
    this.appAnimaisCategoriasId,
    this.appPotreirosId,
    this.idAnoAgricola,
    this.dataIn,
    this.dataOut,
  });

  final int appUsersId;
  final int appFazendasId;
  final int? appAnimaisLotesId;
  final int? appAnimaisCategoriasId;
  final int? appPotreirosId;
  final int? idAnoAgricola;
  final String? dataIn;
  final String? dataOut;

  Map<String, dynamic> toJson() {
    final periodo = <String, dynamic>{};
    if (idAnoAgricola != null && idAnoAgricola! > 0) {
      periodo['id_ano_agricola'] = idAnoAgricola;
    }
    if (dataIn != null && dataIn!.isNotEmpty) {
      periodo['data_in'] = dataIn;
    }
    if (dataOut != null && dataOut!.isNotEmpty) {
      periodo['data_out'] = dataOut;
    }

    final corpo = <String, dynamic>{
      'token': WSConstantes.token,
      'app_users_id': appUsersId,
      'app_fazendas_id': appFazendasId,
      if (periodo.isNotEmpty) 'periodo': periodo,
    };
    if (appAnimaisLotesId != null) {
      corpo['app_animais_lotes_id'] = appAnimaisLotesId;
    }
    if (appAnimaisCategoriasId != null) {
      corpo['app_animais_categorias_id'] = appAnimaisCategoriasId;
    }
    if (appPotreirosId != null) {
      corpo['app_potreiros_id'] = appPotreirosId;
    }
    return withSubUser(corpo);
  }
}
