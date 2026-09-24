import 'package:flutter/material.dart';

class DashboardMockMetric {
  const DashboardMockMetric({
    required this.title,
    required this.value,
    required this.subtitle,
    this.hint,
  });

  final String title;
  final String value;
  final String subtitle;
  final String? hint;
}

class DashboardMockCategorySlice {
  const DashboardMockCategorySlice({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class DashboardMockMonthFlow {
  const DashboardMockMonthFlow({
    required this.label,
    required this.entradas,
    required this.saidas,
  });

  final String label;
  final double entradas;
  final double saidas;
}

class DashboardMockTaskSlice {
  const DashboardMockTaskSlice({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class DashboardMockData {
  const DashboardMockData({
    required this.years,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.urgentTasks,
    required this.metrics,
    required this.composition,
    required this.evolution,
    required this.tasks,
  });

  final List<String> years;
  final int pendingTasks;
  final int overdueTasks;
  final int urgentTasks;
  final List<DashboardMockMetric> metrics;
  final List<DashboardMockCategorySlice> composition;
  final List<DashboardMockMonthFlow> evolution;
  final List<DashboardMockTaskSlice> tasks;

  int get compositionTotal =>
      composition.fold<int>(0, (sum, item) => sum + item.value.round());

  int get tasksTotal =>
      tasks.fold<int>(0, (sum, item) => sum + item.value.round());

  static const demo = DashboardMockData(
    years: ['2025/2026', '2024/2025'],
    pendingTasks: 7,
    overdueTasks: 3,
    urgentTasks: 0,
    metrics: [
      DashboardMockMetric(
        title: 'Total de animais',
        value: '139',
        subtitle: 'UA registradas 129',
        hint: '305 UA registradas',
      ),
      DashboardMockMetric(
        title: 'Lotação',
        value: '0,37',
        subtitle: 'UA/ha',
        hint: '139 cab. em pastagem',
      ),
      DashboardMockMetric(
        title: 'Mortalidade',
        value: '0',
        subtitle: 'cab. · taxa 0,0%',
        hint: 'Sem registros',
      ),
      DashboardMockMetric(
        title: 'GMD global',
        value: '0,180',
        subtitle: 'kg/dia',
        hint: 'Produção ÷ rebanho médio ÷ dias',
      ),
      DashboardMockMetric(
        title: 'Produtividade',
        value: '6,4',
        subtitle: 'kg/ha',
        hint: 'No ano agrícola atual',
      ),
      DashboardMockMetric(
        title: 'Categorias cadastradas',
        value: '3',
        subtitle: 'Vaca, Terneiro, Terneira',
      ),
    ],
    composition: [
      DashboardMockCategorySlice(
        label: 'Vaca · Matriz · Prenha',
        value: 42,
        color: Color(0xFF0B5C38),
      ),
      DashboardMockCategorySlice(
        label: 'Vaca · Matriz · Parida',
        value: 35,
        color: Color(0xFF1E8A55),
      ),
      DashboardMockCategorySlice(
        label: 'Vaca · Matriz · Vazia',
        value: 28,
        color: Color(0xFF3CB371),
      ),
      DashboardMockCategorySlice(
        label: 'Terneiro · Ao pé',
        value: 18,
        color: Color(0xFF7DCFB6),
      ),
      DashboardMockCategorySlice(
        label: 'Terneira · Ao pé',
        value: 16,
        color: Color(0xFFB8E6C8),
      ),
    ],
    evolution: [
      DashboardMockMonthFlow(label: 'Jul', entradas: 110, saidas: 4),
      DashboardMockMonthFlow(label: 'Ago', entradas: 16, saidas: 2),
      DashboardMockMonthFlow(label: 'Set', entradas: 15, saidas: 1),
      DashboardMockMonthFlow(label: 'Out', entradas: 0, saidas: 0),
      DashboardMockMonthFlow(label: 'Nov', entradas: 0, saidas: 0),
      DashboardMockMonthFlow(label: 'Dez', entradas: 0, saidas: 0),
      DashboardMockMonthFlow(label: 'Jan', entradas: 0, saidas: 0),
      DashboardMockMonthFlow(label: 'Fev', entradas: 0, saidas: 0),
      DashboardMockMonthFlow(label: 'Mar', entradas: 0, saidas: 0),
      DashboardMockMonthFlow(label: 'Abr', entradas: 0, saidas: 0),
      DashboardMockMonthFlow(label: 'Mai', entradas: 0, saidas: 0),
      DashboardMockMonthFlow(label: 'Jun', entradas: 0, saidas: 0),
    ],
    tasks: [
      DashboardMockTaskSlice(
        label: 'Pendentes',
        value: 7,
        color: Color(0xFF8B4A2B),
      ),
      DashboardMockTaskSlice(
        label: 'Em andamento',
        value: 4,
        color: Color(0xFFD9762B),
      ),
      DashboardMockTaskSlice(
        label: 'Concluídas',
        value: 7,
        color: Color(0xFF2F7A4A),
      ),
    ],
  );
}
