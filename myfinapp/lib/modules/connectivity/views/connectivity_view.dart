import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/health_controller.dart';

class ConnectivityView extends GetView<HealthController> {
  const ConnectivityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Connectivity Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'MYFIN',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'API Connectivity Test',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'API Base URL:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
              Text(
                'http://192.168.1.119:5265',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: controller.testApi,
              child: const Text('Test API'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.testDatabase,
              child: const Text('Test Database'),
            ),
            const SizedBox(height: 32),
            _StatusTile(
              label: 'API',
              status: controller.apiStatus,
              message: controller.apiMessage,
            ),
            const SizedBox(height: 12),
            _StatusTile(
              label: 'Database',
              status: controller.databaseStatus,
              message: controller.databaseMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final String label;
  final Rx<HealthStatus> status;
  final RxString message;

  const _StatusTile({
    required this.label,
    required this.status,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Obx(() {
                    final color = _colorFor(status.value);
                    return Text(
                      message.value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: color,
                          ),
                    );
                  }),
                ],
              ),
            ),
            Obx(() {
              return Icon(
                _iconFor(status.value),
                color: _colorFor(status.value),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _colorFor(HealthStatus status) {
    switch (status) {
      case HealthStatus.idle:
        return Colors.grey;
      case HealthStatus.testing:
        return Colors.orange;
      case HealthStatus.success:
        return Colors.green;
      case HealthStatus.failure:
        return Colors.red;
    }
  }

  IconData _iconFor(HealthStatus status) {
    switch (status) {
      case HealthStatus.idle:
        return Icons.help_outline;
      case HealthStatus.testing:
        return Icons.hourglass_empty;
      case HealthStatus.success:
        return Icons.check_circle;
      case HealthStatus.failure:
        return Icons.error;
    }
  }
}
