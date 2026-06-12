import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';

class SanitariosFilterRequestModel {
  const SanitariosFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory SanitariosFilterRequestModel.fromEntity(
    SanitariosFilterEntity filter,
  ) {
    return SanitariosFilterRequestModel._(
      {
        'token': WSConstantes.token,
        'app_users_id': filter.appUsersId,
        'id': filter.id,
        'tipo_manejo': filter.tipoManejo,
        'data_in': filter.dataIn,
        'data_out': filter.dataOut,
      }..removeWhere((key, value) => value == null),
    );
  }
}

class SanitarioUpsertRequestModel {
  const SanitarioUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory SanitarioUpsertRequestModel.create(SanitarioUpsertEntity sanitario) {
    return SanitarioUpsertRequestModel._(_payload(sanitario));
  }

  factory SanitarioUpsertRequestModel.update(SanitarioUpsertEntity sanitario) {
    return SanitarioUpsertRequestModel._(
      _payload(sanitario)..['id'] = sanitario.id,
    );
  }

  static Map<String, dynamic> _payload(SanitarioUpsertEntity sanitario) {
    return {
      'token': WSConstantes.token,
      'app_users_id': sanitario.appUsersId,
      'tipo_manejo': sanitario.tipoManejo,
      'tipo_carrapaticida': sanitario.tipoCarrapaticida,
      'data_planejada': sanitario.dataPlanejada,
      'obs': sanitario.obs,
      'categorias': sanitario.categorias,
      'lotes': sanitario.lotes,
    }..removeWhere((key, value) => value == null);
  }
}

class DeleteSanitarioRequestModel {
  const DeleteSanitarioRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory DeleteSanitarioRequestModel.fromEntity(DeleteSanitarioEntity entity) {
    return DeleteSanitarioRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': entity.appUsersId,
      'id': entity.id,
    });
  }
}

class SanitarioExecucaoRequestModel {
  const SanitarioExecucaoRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory SanitarioExecucaoRequestModel.fromEntity(
    SanitarioExecucaoEntity execucao,
  ) {
    return SanitarioExecucaoRequestModel._(
      {
        'token': WSConstantes.token,
        'id': execucao.id,
        'app_users_id': execucao.appUsersId,
        'data_execucao': execucao.dataExecucao,
        'insumos': execucao.insumos
            .map(
              (item) => {
                'id_insumo': item.idInsumo,
                'quantidade': item.quantidade,
              },
            )
            .toList(growable: false),
      }..removeWhere((key, value) => value == null),
    );
  }
}

class SanitarioChartsFilterRequestModel {
  const SanitarioChartsFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory SanitarioChartsFilterRequestModel.fromEntity(
    SanitarioChartsFilterEntity filter,
  ) {
    return SanitarioChartsFilterRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': filter.appUsersId,
      'mes_ano': filter.mesAno,
    });
  }
}

class SanitarioChartsResponseModel extends SanitarioChartsEntity {
  const SanitarioChartsResponseModel({
    required super.planejadosExecutados,
    required super.executadoPorInsumoTipoManejo,
    required super.planejadosExecutadosMesAMes,
  });

  factory SanitarioChartsResponseModel.fromWrapper(Map<String, dynamic> json) {
    final dataList = (json['data'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
    final data = dataList.isEmpty ? <String, dynamic>{} : dataList.first;

    return SanitarioChartsResponseModel(
      planejadosExecutados: SanitarioPlanejadoExecutadoModel.fromJson(
        Map<String, dynamic>.from(data['planejados_executados'] as Map? ?? {}),
      ),
      executadoPorInsumoTipoManejo: _list(
        data['executado_por_insumo_tipo_manejo'],
        SanitarioExecutadoInsumoTipoManejoModel.fromJson,
      ),
      planejadosExecutadosMesAMes: _list(
        data['planejados_executados_mes_a_mes'],
        SanitarioPlanejadoExecutadoMesModel.fromJson,
      ),
    );
  }
}

class SanitarioPlanejadoExecutadoModel
    extends SanitarioPlanejadoExecutadoEntity {
  const SanitarioPlanejadoExecutadoModel({
    required super.planejado,
    required super.executado,
  });

  factory SanitarioPlanejadoExecutadoModel.fromJson(Map<String, dynamic> json) {
    return SanitarioPlanejadoExecutadoModel(
      planejado: _double(json['planejado']) ?? 0,
      executado: _double(json['executado']) ?? 0,
    );
  }
}

class SanitarioExecutadoInsumoTipoManejoModel
    extends SanitarioExecutadoInsumoTipoManejoEntity {
  const SanitarioExecutadoInsumoTipoManejoModel({
    required super.tipoManejo,
    required super.insumo,
    required super.quantidade,
  });

  factory SanitarioExecutadoInsumoTipoManejoModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SanitarioExecutadoInsumoTipoManejoModel(
      tipoManejo: json['tipo_manejo']?.toString() ?? '',
      insumo:
          _reference(json['insumo']) ??
          const SanitarioReferenceEntity(id: 0, nome: ''),
      quantidade: _double(json['quantidade']) ?? 0,
    );
  }
}

class SanitarioPlanejadoExecutadoMesModel
    extends SanitarioPlanejadoExecutadoMesEntity {
  const SanitarioPlanejadoExecutadoMesModel({
    required super.ano,
    required super.mes,
    required super.status,
    required super.quantidade,
  });

  factory SanitarioPlanejadoExecutadoMesModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SanitarioPlanejadoExecutadoMesModel(
      ano: _int(json['ano']),
      mes: _int(json['mes']),
      status: json['status']?.toString() ?? '',
      quantidade: _double(json['quantidade']) ?? 0,
    );
  }
}

class SanitariosListResponseModel extends SanitariosListEntity {
  const SanitariosListResponseModel({
    required super.rows,
    required super.lista,
    super.tiposManejos,
    super.status,
    super.categorias,
    super.lotes,
    super.insumos,
  });

  factory SanitariosListResponseModel.fromWrapper(Map<String, dynamic> json) {
    final data = (json['data'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .firstOrNull;

    final body = data ?? const <String, dynamic>{};
    final lista = _list(body['lista'], SanitarioModel.fromJson);

    return SanitariosListResponseModel(
      rows: int.tryParse(json['rows']?.toString() ?? '') ?? lista.length,
      lista: lista,
      tiposManejos: _list(
        body['tipos_manejos'],
        SanitarioTipoManejoModel.fromJson,
      ),
      status: _list(body['status'], SanitarioReferenceModel.fromJson),
      categorias: _list(body['categorias'], SanitarioCategoriaModel.fromJson),
      lotes: _list(body['lotes'], SanitarioLoteModel.fromJson),
      insumos: _list(body['insumos'], SanitarioInsumoModel.fromJson),
    );
  }
}

class SanitarioModel extends SanitarioEntity {
  const SanitarioModel({
    required super.id,
    required super.appUsersId,
    required super.tipoManejo,
    super.tipoCarrapaticida,
    super.dataPlanejada,
    super.dataExecucao,
    super.obs,
    super.dataCadastro,
    super.updateAt,
    required super.status,
    super.categorias,
    super.lotes,
    super.insumos,
    super.idLocal,
    super.syncStatus,
    super.pendingAction,
    super.isLocalOnly = false,
  });

  factory SanitarioModel.fromJson(Map<String, dynamic> json) {
    return SanitarioModel(
      id: _int(json['id']),
      appUsersId: _int(json['app_users_id']),
      tipoManejo: json['tipo_manejo']?.toString() ?? '',
      tipoCarrapaticida: json['tipo_carrapaticida']?.toString(),
      dataPlanejada: json['data_planejada']?.toString(),
      dataExecucao: json['data_execucao']?.toString(),
      obs: json['obs']?.toString(),
      dataCadastro: json['data_cadastro']?.toString(),
      updateAt: json['update_at']?.toString(),
      status: json['status']?.toString() ?? '',
      categorias: _list(json['categorias'], SanitarioCategoriaModel.fromJson),
      lotes: _list(json['lotes'], SanitarioLoteModel.fromJson),
      insumos: _list(json['insumos'], SanitarioInsumoModel.fromJson),
      idLocal: json['idLocal']?.toString(),
      syncStatus: json['syncStatus']?.toString(),
      pendingAction: json['pendingAction']?.toString(),
      isLocalOnly: json['isLocalOnly'] == true,
    );
  }
}

class SanitarioCategoriaModel extends SanitarioCategoriaEntity {
  const SanitarioCategoriaModel({
    required super.id,
    super.appSanitariosId,
    super.appAnimaisCategoriasId,
    required super.nome,
    super.sexo,
  });

  factory SanitarioCategoriaModel.fromJson(Map<String, dynamic> json) {
    return SanitarioCategoriaModel(
      id: _int(json['id']),
      appSanitariosId: _nullableInt(json['app_sanitarios_id']),
      appAnimaisCategoriasId: _nullableInt(json['app_animais_categorias_id']),
      nome: json['nome']?.toString() ?? '',
      sexo: _nullableInt(json['sexo']),
    );
  }
}

class SanitarioLoteModel extends SanitarioLoteEntity {
  const SanitarioLoteModel({
    required super.id,
    super.appSanitariosId,
    super.appAnimaisLotesId,
    required super.nome,
    super.appUsersId,
    super.createAt,
    super.updateAt,
  });

  factory SanitarioLoteModel.fromJson(Map<String, dynamic> json) {
    return SanitarioLoteModel(
      id: _int(json['id']),
      appSanitariosId: _nullableInt(json['app_sanitarios_id']),
      appAnimaisLotesId: _nullableInt(json['app_animais_lotes_id']),
      nome: json['nome']?.toString() ?? '',
      appUsersId: _nullableInt(json['app_users_id']),
      createAt: json['create_at']?.toString(),
      updateAt: json['update_at']?.toString(),
    );
  }
}

class SanitarioInsumoModel extends SanitarioInsumoEntity {
  const SanitarioInsumoModel({
    required super.id,
    required super.appUsersId,
    required super.tipoInsumo,
    required super.nome,
    super.qtdTotal,
    super.valorUnidade,
    super.valorTotal,
    super.dataValidade,
    super.unidade,
  });

  factory SanitarioInsumoModel.fromJson(Map<String, dynamic> json) {
    return SanitarioInsumoModel(
      id: _int(json['id']),
      appUsersId: _int(json['app_users_id']),
      tipoInsumo: json['tipo_insumo']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      qtdTotal: _double(json['qtd_total']),
      valorUnidade: _double(json['valor_unidade']),
      valorTotal: _double(json['valor_total']),
      dataValidade: json['data_validade']?.toString(),
      unidade: _reference(json['unidade']),
    );
  }
}

class SanitarioReferenceModel extends SanitarioReferenceEntity {
  const SanitarioReferenceModel({required super.id, required super.nome});

  factory SanitarioReferenceModel.fromJson(Map<String, dynamic> json) {
    return SanitarioReferenceModel(
      id: json['id'],
      nome: json['nome']?.toString() ?? '',
    );
  }
}

class SanitarioTipoManejoModel extends SanitarioTipoManejoEntity {
  const SanitarioTipoManejoModel({
    required super.id,
    required super.nome,
    super.tiposCarrapaticida,
  });

  factory SanitarioTipoManejoModel.fromJson(Map<String, dynamic> json) {
    return SanitarioTipoManejoModel(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      tiposCarrapaticida: _list(
        json['tipos_carrapaticida'],
        SanitarioReferenceModel.fromJson,
      ),
    );
  }
}

List<T> _list<T>(dynamic value, T Function(Map<String, dynamic>) fromJson) {
  return (value as List<dynamic>? ?? const [])
      .whereType<Map>()
      .map((item) => fromJson(Map<String, dynamic>.from(item)))
      .toList(growable: false);
}

SanitarioReferenceEntity? _reference(dynamic value) {
  if (value is Map<String, dynamic>) {
    return SanitarioReferenceModel.fromJson(value);
  }
  if (value is Map) {
    return SanitarioReferenceModel.fromJson(Map<String, dynamic>.from(value));
  }
  return null;
}

int _int(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;
int? _nullableInt(dynamic value) => int.tryParse(value?.toString() ?? '');
double? _double(dynamic value) => double.tryParse(value?.toString() ?? '');
