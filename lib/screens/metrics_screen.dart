import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/metrics_provider.dart';
import '../providers/users_provider.dart';
import '../theme/app_theme.dart';

class MetricsScreen extends StatelessWidget {
  const MetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = context.watch<MetricsProvider>();
    final users = context.watch<UsersProvider>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header
        const Text(
          'Métricas',
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Atualizado a cada 5 segundos',
          style: TextStyle(color: AppTheme.whiteSubtle, fontSize: 12),
        ),
        const SizedBox(height: 24),

        // Metrics grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _MetricCard(
              label: 'Usuários Logados',
              value: metrics.loggedUsers.toString(),
              icon: Icons.sensors,
              sublabel: 'agora',
            ),
            _MetricCard(
              label: 'Usuários Ativos',
              value: metrics.activeUsers.toString(),
              icon: Icons.person_outline,
              sublabel: 'últimas 24h',
            ),
            _MetricCard(
              label: 'Total no Banco',
              value: users.totalUsers.toString(),
              icon: Icons.storage_outlined,
              sublabel: 'cadastros',
            ),
            _MetricCard(
              label: 'Tempo Médio',
              value: metrics
                  .formatDuration(metrics.avgUsageTime)
                  .split(' ')
                  .first,
              icon: Icons.timer_outlined,
              sublabel: metrics.formatDuration(metrics.avgUsageTime),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Chart section
        const _SectionLabel(label: 'ATIVIDADE — ÚLTIMAS 12 ATUALIZAÇÕES'),
        const SizedBox(height: 16),
        _ActivityChart(data: metrics.activityData),
        const SizedBox(height: 28),

        // Breakdown section
        const _SectionLabel(label: 'DISTRIBUIÇÃO DE USUÁRIOS'),
        const SizedBox(height: 16),
        _UserDistributionBar(
          active: users.activeUsers,
          total: users.totalUsers,
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _MetricCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final String sublabel;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.sublabel,
  });

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  String _prev = '';

  @override
  void initState() {
    super.initState();
    _prev = widget.value;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(_MetricCard old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _prev = old.value;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(widget.icon,
                  color: AppTheme.whiteSubtle, size: 16),
              Text(
                widget.sublabel,
                style: const TextStyle(
                  color: AppTheme.whiteDisabled,
                  fontSize: 10,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FadeTransition(
            opacity: _anim.drive(
              Tween(begin: 0.4, end: 1.0),
            ),
            child: Text(
              widget.value,
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 28,
                fontWeight: FontWeight.w300,
                fontFamily: 'monospace',
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.label,
            style: const TextStyle(
              color: AppTheme.whiteSubtle,
              fontSize: 11,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityChart extends StatelessWidget {
  final List<double> data;
  const _ActivityChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return Container(
      height: 160,
      padding: const EdgeInsets.fromLTRB(0, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: AppTheme.border,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 36,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: AppTheme.whiteDisabled,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.white,
              barWidth: 1.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) =>
                    FlDotCirclePainter(
                  radius: 2.5,
                  color: AppTheme.white,
                  strokeWidth: 0,
                  strokeColor: Colors.transparent,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.white.withOpacity(0.04),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserDistributionBar extends StatelessWidget {
  final int active;
  final int total;
  const _UserDistributionBar({required this.active, required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : active / total;
    final inactive = total - active;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DistLabel(
                  label: 'Ativos', value: active, color: AppTheme.statusOnline),
              _DistLabel(
                  label: 'Inativos',
                  value: inactive,
                  color: AppTheme.whiteDisabled),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  height: 6,
                  color: AppTheme.border,
                ),
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.statusOnline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(ratio * 100).toStringAsFixed(1)}% ativos',
                style: const TextStyle(
                  color: AppTheme.whiteSubtle,
                  fontSize: 11,
                ),
              ),
              Text(
                'Total: $total',
                style: const TextStyle(
                  color: AppTheme.whiteSubtle,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DistLabel extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _DistLabel(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $value',
          style: const TextStyle(
            color: AppTheme.whiteSubtle,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.whiteDisabled,
        fontSize: 10,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
