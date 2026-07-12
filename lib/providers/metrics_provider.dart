import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

enum ServiceStatus { online, offline, warning }

class ServiceInfo {
  final String name;
  final ServiceStatus status;
  final String latency;
  final DateTime lastChecked;

  ServiceInfo({
    required this.name,
    required this.status,
    required this.latency,
    required this.lastChecked,
  });
}

class MetricsProvider extends ChangeNotifier {
  final _random = Random();
  Timer? _metricsTimer;
  Timer? _statusTimer;

  // Metrics
  int _loggedUsers = 0;
  int _activeUsers = 0;
  int _totalUsers = 0;
  Duration _avgUsageTime = Duration.zero;
  List<double> _activityData = [];

  // Services status
  List<ServiceInfo> _services = [];
  bool _isRefreshingStatus = false;

  bool get isRefreshingStatus => _isRefreshingStatus;
  int get loggedUsers => _loggedUsers;
  int get activeUsers => _activeUsers;
  int get totalUsers => _totalUsers;
  Duration get avgUsageTime => _avgUsageTime;
  List<double> get activityData => _activityData;
  List<ServiceInfo> get services => _services;

  MetricsProvider() {
    _initData();
    _startAutoRefresh();
  }

  void _initData() {
    _loggedUsers = 12 + _random.nextInt(8);
    _activeUsers = 34 + _random.nextInt(15);
    _totalUsers = 247;
    _avgUsageTime = Duration(
      minutes: 8 + _random.nextInt(10),
      seconds: _random.nextInt(60),
    );
    _activityData = List.generate(
      12,
      (i) => 20.0 + _random.nextDouble() * 60,
    );
    _initServices();
  }

  void _initServices() {
    _services = [
      ServiceInfo(
        name: 'Frontend',
        status: ServiceStatus.online,
        latency: '${12 + _random.nextInt(8)}ms',
        lastChecked: DateTime.now(),
      ),
      ServiceInfo(
        name: 'Backend',
        status: ServiceStatus.online,
        latency: '${24 + _random.nextInt(20)}ms',
        lastChecked: DateTime.now(),
      ),
      ServiceInfo(
        name: 'Banco de Dados',
        status: ServiceStatus.online,
        latency: '${4 + _random.nextInt(6)}ms',
        lastChecked: DateTime.now(),
      ),
    ];
  }

  void _startAutoRefresh() {
    _metricsTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _refreshMetrics();
    });
  }

  void _refreshMetrics() {
    _loggedUsers =
        (_loggedUsers + _random.nextInt(3) - 1).clamp(5, 50);
    _activeUsers =
        (_activeUsers + _random.nextInt(5) - 2).clamp(20, 80);
    _activityData.removeAt(0);
    _activityData.add(20.0 + _random.nextDouble() * 60);
    notifyListeners();
  }

  Future<void> refreshStatus() async {
    _isRefreshingStatus = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));

    final statuses = [
      ServiceStatus.online,
      ServiceStatus.online,
      ServiceStatus.online,
      ServiceStatus.online,
      ServiceStatus.warning,
      ServiceStatus.offline,
    ];

    _services = [
      ServiceInfo(
        name: 'Frontend',
        status: statuses[_random.nextInt(4)], // biased toward online
        latency: '${10 + _random.nextInt(15)}ms',
        lastChecked: DateTime.now(),
      ),
      ServiceInfo(
        name: 'Backend',
        status: statuses[_random.nextInt(5)],
        latency: '${20 + _random.nextInt(30)}ms',
        lastChecked: DateTime.now(),
      ),
      ServiceInfo(
        name: 'Banco de Dados',
        status: statuses[_random.nextInt(5)],
        latency: '${3 + _random.nextInt(8)}ms',
        lastChecked: DateTime.now(),
      ),
    ];

    _isRefreshingStatus = false;
    notifyListeners();
  }

  String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}h ' : ''}${minutes}m ${seconds}s';
  }

  @override
  void dispose() {
    _metricsTimer?.cancel();
    _statusTimer?.cancel();
    super.dispose();
  }
}
