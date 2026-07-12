import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/metrics_provider.dart';
import '../theme/app_theme.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  @override
  Widget build(BuildContext context) {
    final metrics = context.watch<MetricsProvider>();

    return RefreshIndicator(
      color: AppTheme.white,
      backgroundColor: AppTheme.surfaceVariant,
      onRefresh: metrics.refreshStatus,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status dos Serviços',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Última verificação agora',
                    style: TextStyle(
                      color: AppTheme.whiteSubtle,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              _RefreshButton(
                isRefreshing: metrics.isRefreshingStatus,
                onRefresh: metrics.refreshStatus,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Overall status banner
          _OverallStatusBanner(services: metrics.services),
          const SizedBox(height: 24),

          // Service cards
          ...metrics.services.map(
            (service) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ServiceCard(service: service),
            ),
          ),

          const SizedBox(height: 24),
          const _SectionDivider(label: 'INFORMAÇÕES DO SISTEMA'),
          const SizedBox(height: 16),

          // Info rows
          const _InfoRow(label: 'Versão do App', value: 'v1.0.0'),
          const _InfoRow(label: 'Ambiente', value: 'Production'),
          const _InfoRow(label: 'Região', value: 'sa-east-1'),
          const _InfoRow(label: 'Uptime', value: '14d 7h 23m'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _RefreshButton extends StatefulWidget {
  final bool isRefreshing;
  final VoidCallback onRefresh;

  const _RefreshButton({
    required this.isRefreshing,
    required this.onRefresh,
  });

  @override
  State<_RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<_RefreshButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didUpdateWidget(_RefreshButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRefreshing) {
      _rotateController.repeat();
    } else {
      _rotateController.stop();
      _rotateController.reset();
    }
  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isRefreshing ? null : widget.onRefresh,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: RotationTransition(
            turns: _rotateController,
            child: Icon(
              Icons.refresh,
              color: widget.isRefreshing
                  ? AppTheme.whiteSubtle
                  : AppTheme.white,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class _OverallStatusBanner extends StatelessWidget {
  final List<ServiceInfo> services;

  const _OverallStatusBanner({required this.services});

  @override
  Widget build(BuildContext context) {
    final allOnline =
        services.every((s) => s.status == ServiceStatus.online);
    final hasOffline =
        services.any((s) => s.status == ServiceStatus.offline);

    final color = hasOffline
        ? AppTheme.statusOffline
        : allOnline
            ? AppTheme.statusOnline
            : AppTheme.statusWarning;

    final label = hasOffline
        ? 'Serviço com falha detectado'
        : allOnline
            ? 'Todos os serviços operacionais'
            : 'Degradação parcial detectada';

    final icon = hasOffline
        ? Icons.error_outline
        : allOnline
            ? Icons.check_circle_outline
            : Icons.warning_amber_outlined;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceInfo service;

  const _ServiceCard({required this.service});

  Color get _statusColor {
    switch (service.status) {
      case ServiceStatus.online:
        return AppTheme.statusOnline;
      case ServiceStatus.offline:
        return AppTheme.statusOffline;
      case ServiceStatus.warning:
        return AppTheme.statusWarning;
    }
  }

  String get _statusLabel {
    switch (service.status) {
      case ServiceStatus.online:
        return 'ONLINE';
      case ServiceStatus.offline:
        return 'OFFLINE';
      case ServiceStatus.warning:
        return 'DEGRADADO';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Indicator dot with pulse
          _PulseDot(color: _statusColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Latência: ${service.latency}',
                  style: const TextStyle(
                    color: AppTheme.whiteSubtle,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _statusLabel,
              style: TextStyle(
                color: _statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withOpacity(_animation.value),
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  final String label;
  const _SectionDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.whiteDisabled,
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider(color: AppTheme.border)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.whiteSubtle,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
