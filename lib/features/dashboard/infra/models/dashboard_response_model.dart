import 'package:costeira/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:costeira/features/dashboard/domain/entities/dashboard_list_entity.dart';

class DashboardListResponseModel extends DashboardListEntity {
  const DashboardListResponseModel({required super.rows, required super.data});

  factory DashboardListResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is List
        ? rawData
              .whereType<Map>()
              .map(
                (item) => DashboardResponseModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(growable: false)
        : <DashboardResponseModel>[];

    return DashboardListResponseModel(
      rows: int.tryParse(json['rows']?.toString() ?? '') ?? data.length,
      data: data,
    );
  }
}

class DashboardResponseModel extends DashboardEntity {
  const DashboardResponseModel({
    required super.periodo,
    required super.indicadores,
    required super.graficos,
  });

  factory DashboardResponseModel.fromJson(Map<String, dynamic> json) {
    return DashboardResponseModel(
      periodo: _periodFromJson(json['periodo']),
      indicadores: _indicatorsFromJson(json['indicadores']),
      graficos: _chartsFromJson(json['graficos']),
    );
  }
}

DashboardPeriodEntity _periodFromJson(dynamic raw) {
  final map = _map(raw);
  return DashboardPeriodEntity(
    dataIn: map['data_in']?.toString() ?? '',
    dataOut: map['data_out']?.toString() ?? '',
  );
}

DashboardIndicatorsEntity _indicatorsFromJson(dynamic raw) {
  final map = _map(raw);
  return DashboardIndicatorsEntity(
    quantidadeKilosProduzidos: _valueFromJson(
      map['quantidade_kilos_produzidos'],
    ),
    kilosPorHectare: _valueFromJson(map['kilos_por_hectare']),
    estoqueRebanhoReais: _valueFromJson(map['estoque_rebanho_reais']),
    totalAnimais: _toInt(map['total_animais']),
    mediaFazenda: _valueFromJson(map['media_fazenda']),
    mortalidadePercentual: _valueFromJson(map['mortalidade_percentual']),
    ganhoMedioDiario: _valueFromJson(map['ganho_medio_diario']),
    tarefasMes: _tasksMonthFromJson(map['tarefas_mes']),
  );
}

DashboardValueEntity _valueFromJson(dynamic raw) {
  final map = _map(raw);
  if (map.isEmpty && raw != null) {
    return DashboardValueEntity(valor: raw.toString());
  }

  return DashboardValueEntity(
    valor: map['valor']?.toString(),
    observacao: map['observacao']?.toString(),
    descricao: map['descricao']?.toString(),
    hectares: map['hectares']?.toString(),
  );
}

DashboardTasksMonthEntity _tasksMonthFromJson(dynamic raw) {
  final map = _map(raw);
  return DashboardTasksMonthEntity(
    quantidade: _toInt(map['quantidade']),
    concluidas: _toInt(map['concluidas']),
    percentualConcluido: map['percentual_concluido']?.toString() ?? '0,00',
  );
}

DashboardChartsEntity _chartsFromJson(dynamic raw) {
  final map = _map(raw);
  return DashboardChartsEntity(
    producaoKgMes: _productionListFromJson(map['producao_kg_mes']),
    animaisCategoria: _categoryListFromJson(map['animais_categoria']),
    progressoTarefas: _tasksProgressFromJson(map['progresso_tarefas']),
  );
}

List<DashboardProductionMonthEntity> _productionListFromJson(dynamic raw) {
  if (raw is! List) {
    return const [];
  }

  return raw
      .whereType<Map>()
      .map((item) {
        final map = Map<String, dynamic>.from(item);
        return DashboardProductionMonthEntity(
          label:
              map['mes']?.toString() ??
              map['periodo']?.toString() ??
              map['data']?.toString() ??
              '',
          valor: _toDouble(map['valor'] ?? map['quantidade'] ?? map['total']),
        );
      })
      .toList(growable: false);
}

List<DashboardAnimalCategoryEntity> _categoryListFromJson(dynamic raw) {
  if (raw is! List) {
    return const [];
  }

  return raw
      .whereType<Map>()
      .map((item) {
        final map = Map<String, dynamic>.from(item);
        return DashboardAnimalCategoryEntity(
          id: _toInt(map['id']),
          nome: map['nome']?.toString().trim() ?? '',
          quantidade: _toInt(map['quantidade']),
          percentual: map['percentual']?.toString() ?? '0,00',
        );
      })
      .toList(growable: false);
}

DashboardTasksProgressEntity _tasksProgressFromJson(dynamic raw) {
  final map = _map(raw);
  return DashboardTasksProgressEntity(
    total: _toInt(map['total']),
    concluidas: _toInt(map['concluidas']),
    percentual: map['percentual']?.toString() ?? '0,00',
  );
}

Map<String, dynamic> _map(dynamic raw) {
  if (raw is Map<String, dynamic>) {
    return raw;
  }
  if (raw is Map) {
    return Map<String, dynamic>.from(raw);
  }
  return <String, dynamic>{};
}

int _toInt(dynamic value) {
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  final normalized = value?.toString().replaceAll('.', '').replaceAll(',', '.');
  return double.tryParse(normalized ?? '') ?? 0;
}
