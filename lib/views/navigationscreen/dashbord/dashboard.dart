import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  static const _metrics = [
    _DashboardMetric('icon/weight.svg', 'Quilos produzidos', '35.000 kg'),
    _DashboardMetric('icon/hand-coins.svg', 'Receita estimada', 'R\$ 1.725.000,00'),
    _DashboardMetric('icon/cow-light.svg', 'Total de animais', '3 cabeças'),
    _DashboardMetric('icon/workflow.svg', 'Média da fazenda', '600 kg/ha'),
    _DashboardMetric('icon/chart-area.svg', 'Ganho médio diário', '0,65 kg/dia'),
    _DashboardMetric('icon/book-check.svg', 'Tarefas do mês', '3 pendentes'),
  ];

  static const _charts = [
    'images/chartproduct.png',
    'images/categoriachart.png',
    'images/gmd.png',
    'images/progressotarefas.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFEBEBEB)),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 24,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset('icon/calendar.svg'),
                      const SizedBox(width: 8),
                      const Text(
                        '01 de nov - 30 de nov',
                        style: TextStyle(
                          color: Color(0xFF313131),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  SvgPicture.asset('icon/header.svg'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _metrics
                    .map((metric) => _MetricCard(metric: metric))
                    .toList(growable: false),
              ),
            ),
            const SizedBox(height: 16),
            ..._charts.map(
              (asset) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Image.asset(
                  asset,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _DashboardMetric metric;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 56) / 2;

    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEBEBEB)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00823A), Color(0xFF00B752)],
              ),
              borderRadius: BorderRadius.circular(42.67),
            ),
            child: SvgPicture.asset(
              metric.icon,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            metric.title,
            style: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            metric.value,
            style: const TextStyle(
              color: Color(0xFF00431F),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardMetric {
  const _DashboardMetric(this.icon, this.title, this.value);

  final String icon;
  final String title;
  final String value;
}
