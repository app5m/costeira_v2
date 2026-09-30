import 'package:costeira/core/storage/sub_usuario_nome.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/infra/models/insumo_reference_model.dart';

class InsumoModel extends InsumoEntity {
  const InsumoModel({
    required super.id,
    required super.appUsersId,
    required super.tipoInsumo,
    super.appEstoquesInsumosSuplementosId,
    required super.nome,
    required super.appEstoquesInsumosUnidadesId,
    super.valorUnidade,
    super.valorTotal,
    super.valorUnidadeRaw,
    super.valorTotalRaw,
    super.qtdTotal,
    super.obs,
    super.dataValidade,
    super.dataCadastro,
    super.updateAt,
    super.unidade,
    super.suplemento,
    super.appEstoquesInsumosCategoriasId,
    super.appEstoquesInsumosSubcategoriasId,
    super.idLocal,
    super.syncStatus,
    super.pendingAction,
    super.isLocalOnly = false,
    super.subUsuarioNome,
  });

  factory InsumoModel.fromJson(Map<String, dynamic> json) {
    return InsumoModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      appUsersId: int.tryParse(json['app_users_id']?.toString() ?? '') ?? 0,
      tipoInsumo: json['tipo_insumo']?.toString() ?? '',
      appEstoquesInsumosSuplementosId: int.tryParse(
        json['app_estoques_insumos_suplementos_id']?.toString() ?? '',
      ),
      nome: json['nome']?.toString() ?? '',
      appEstoquesInsumosUnidadesId:
          int.tryParse(
            json['app_estoques_insumos_unidades_id']?.toString() ?? '',
          ) ??
          0,
      valorUnidade: _text(json, const ['custo_medio', 'valor_unidade']),
      valorTotal: _text(json, const ['valor_total']),
      valorUnidadeRaw: _number(
        json,
        const ['custo_medio_raw', 'valor_unidade_raw'],
      ),
      valorTotalRaw: _number(json, const ['valor_total_raw']),
      qtdTotal: double.tryParse(json['qtd_total']?.toString() ?? ''),
      obs: json['obs']?.toString(),
      dataValidade: json['data_validade']?.toString(),
      dataCadastro: json['data_cadastro']?.toString(),
      updateAt: json['update_at']?.toString(),
      unidade: _referenceFromJson(json['unidade']),
      suplemento: _referenceFromJson(json['suplemento']),
      appEstoquesInsumosCategoriasId:
          _linkedId(json, 'app_estoques_insumos_categorias_id', 'categoria') ??
          _linkedId(json, 'app_estoque_insumos_categorias_id', 'categoria'),
      appEstoquesInsumosSubcategoriasId:
          _linkedId(
            json,
            'app_estoques_insumos_subcategorias_id',
            'subcategoria',
          ) ??
          _linkedId(json, 'app_estoque_insumos_subcategorias_id', 'subcategoria'),
      idLocal: json['idLocal']?.toString(),
      syncStatus: json['syncStatus']?.toString(),
      pendingAction: json['pendingAction']?.toString(),
      isLocalOnly: json['isLocalOnly'] == true,
      subUsuarioNome: subUsuarioNome(json),
    );
  }

  static String? _text(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  static double? _number(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = double.tryParse(json[key]?.toString() ?? '');
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  static int? _linkedId(
    Map<String, dynamic> json,
    String idKey,
    String objectKey,
  ) {
    final direct = int.tryParse(json[idKey]?.toString() ?? '');
    if (direct != null && direct > 0) {
      return direct;
    }
    final nested = json[objectKey];
    if (nested is Map) {
      final id = int.tryParse(nested['id']?.toString() ?? '');
      if (id != null && id > 0) {
        return id;
      }
    }
    return null;
  }

  static InsumoReferenceEntity? _referenceFromJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      return InsumoReferenceModel.fromJson(value);
    }
    if (value is Map) {
      return InsumoReferenceModel.fromJson(Map<String, dynamic>.from(value));
    }
    return null;
  }
}
