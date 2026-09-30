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
      indicadores: _indicatorsFromJson(
        json['indicadores'],
        tarefas: json['tarefas'],
      ),
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

DashboardIndicatorsEntity _indicatorsFromJson(
  dynamic raw, {
  dynamic tarefas,
}) {
  final map = _map(raw);
  final total = _map(map['total_animais']);
  final lotacao = _map(map['lotacao']);
  final mortalidade = _map(map['mortalidade']);
  final gmd = _map(map['gmd_global']);
  final produtividade = _map(map['produtividade']);
  final peso = _display(lotacao['peso_total']);
  final hectaresLotacao = _display(lotacao['hectares']);
  final lotacaoHint = [
    if (peso != null) '$peso kg',
    if (hectaresLotacao != null) '$hectaresLotacao ha',
  ].join(' · ');

  return DashboardIndicatorsEntity(
    quantidadeKilosProduzidos: produtividade.isNotEmpty
        ? DashboardValueEntity(
            valor: _display(produtividade['kg_produzidos']) ?? '0',
            descricao: 'kg',
          )
        : _valueFromJson(map['quantidade_kilos_produzidos']),
    kilosPorHectare: produtividade.isNotEmpty
        ? DashboardValueEntity(
            valor: _display(produtividade['valor']) ?? '0',
            descricao: produtividade['unidade']?.toString(),
            hectares: _display(produtividade['hectares']),
          )
        : _valueFromJson(map['kilos_por_hectare']),
    estoqueRebanhoReais: _valueFromJson(map['estoque_rebanho_reais']),
    totalAnimais: total.isNotEmpty
        ? _toInt(total['valor'])
        : _toInt(map['total_animais']),
    totalAnimaisUnidade: total['unidade']?.toString() ?? 'cab.',
    mediaFazenda: lotacao.isNotEmpty
        ? DashboardValueEntity(
            valor: _display(lotacao['valor']) ?? '0',
            descricao: lotacao['unidade']?.toString(),
            hectares: hectaresLotacao,
            observacao: lotacaoHint.isEmpty ? null : lotacaoHint,
          )
        : _valueFromJson(map['media_fazenda']),
    mortalidadePercentual: mortalidade.isNotEmpty
        ? DashboardValueEntity(
            valor: _display(mortalidade['valor']) ?? '0',
            descricao: mortalidade['unidade']?.toString(),
            observacao: mortalidade['taxa'] == null
                ? null
                : 'taxa ${_display(mortalidade['taxa'])}',
          )
        : _valueFromJson(map['mortalidade_percentual']),
    ganhoMedioDiario: gmd.isNotEmpty
        ? DashboardValueEntity(
            valor: _display(gmd['valor']) ?? '0',
            descricao: gmd['unidade']?.toString(),
          )
        : _valueFromJson(map['ganho_medio_diario']),
    tarefasMes: _tasksMonthFromJson(tarefas ?? map['tarefas_mes']),
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
  final quantidade = _toInt(map['quantidade'] ?? map['total']);
  final concluidas = _toInt(map['concluidas']);
  final pendentes = map.containsKey('pendentes')
      ? _toInt(map['pendentes'])
      : (quantidade - concluidas).clamp(0, 1 << 30);
  return DashboardTasksMonthEntity(
    quantidade: quantidade,
    concluidas: concluidas,
    pendentes: pendentes,
    emAtraso: _toInt(map['em_atraso'] ?? map['vencidas'] ?? map['atrasadas']),
    urgentes: _toInt(map['urgentes'] ?? map['alta_urgencia']),
    percentualConcluido: map['percentual_concluido']?.toString() ?? '0,00',
  );
}

DashboardChartsEntity _chartsFromJson(dynamic raw) {
  final map = _map(raw);
  return DashboardChartsEntity(
    producaoKgMes: _productionListFromJson(
      map['evolucao_rebanho'] ?? map['producao_kg_mes'],
    ),
    animaisCategoria: _categoryListFromJson(
      map['composicao_rebanho'] ?? map['animais_categoria'],
    ),
    progressoTarefas: _tasksProgressFromJson(
      map['tarefas'] ?? map['progresso_tarefas'],
    ),
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
        final hasFlow =
            map.containsKey('entradas') ||
            map.containsKey('saidas') ||
            map.containsKey('saídas');
        return DashboardProductionMonthEntity(
          label:
              map['nome_mes']?.toString() ??
              map['mes']?.toString() ??
              map['periodo']?.toString() ??
              map['data']?.toString() ??
              '',
          valor: _toDouble(map['valor'] ?? map['quantidade'] ?? map['total']),
          entradas: hasFlow ? _toDouble(map['entradas']) : null,
          saidas: hasFlow ? _toDouble(map['saidas'] ?? map['saídas']) : null,
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
        final categoria = _map(map['categoria']);
        final subcategoria = _map(map['subcategoria']);
        final nomeCategoria =
            categoria['nome']?.toString().trim() ??
            map['nome']?.toString().trim() ??
            '';
        final nomeSub = subcategoria['nome']?.toString().trim() ?? '';
        return DashboardAnimalCategoryEntity(
          id: _toInt(categoria['id'] ?? map['id']),
          nome: nomeSub.isEmpty ? nomeCategoria : '$nomeCategoria · $nomeSub',
          quantidade: _toInt(map['quantidade']),
          percentual: _display(map['percentual']) ?? '0',
        );
      })
      .toList(growable: false);
}

DashboardTasksProgressEntity _tasksProgressFromJson(dynamic raw) {
  if (raw is List) {
    var pendentes = 0;
    var concluidas = 0;
    var emAndamento = 0;
    for (final item in raw.whereType<Map>()) {
      final status = item['status']?.toString() ?? '';
      final quantidade = _toInt(item['quantidade']);
      if (status == 'pendentes') {
        pendentes = quantidade;
      } else if (status == 'concluidas') {
        concluidas = quantidade;
      } else if (status == 'andamento' || status == 'em_andamento') {
        emAndamento = quantidade;
      }
    }
    final total = pendentes + concluidas + emAndamento;
    return DashboardTasksProgressEntity(
      total: total,
      concluidas: concluidas,
      pendentes: pendentes,
      emAndamento: emAndamento,
      percentual: '0',
    );
  }

  final map = _map(raw);
  final total = _toInt(map['total']);
  final concluidas = _toInt(map['concluidas']);
  final pendentes = map.containsKey('pendentes')
      ? _toInt(map['pendentes'])
      : (total - concluidas).clamp(0, 1 << 30);
  return DashboardTasksProgressEntity(
    total: total,
    concluidas: concluidas,
    pendentes: pendentes,
    emAndamento: _toInt(map['em_andamento'] ?? map['andamento']),
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

String? _display(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    var text = value.toStringAsFixed(3);
    text = text
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
    return text.replaceAll('.', ',');
  }
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

int _toInt(dynamic value) {
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) {
    return 0;
  }
  if (text.contains(',') && text.contains('.')) {
    return double.tryParse(text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
  }
  if (text.contains(',')) {
    return double.tryParse(text.replaceAll(',', '.')) ?? 0;
  }
  return double.tryParse(text) ?? 0;
}
