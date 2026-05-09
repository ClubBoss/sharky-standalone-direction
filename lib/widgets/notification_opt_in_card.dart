import 'package:flutter/material.dart';

import '../services/notification_service.dart';

abstract class NotificationServiceDelegate {
  Future<NotificationPermissionStatus> requestPermission();
  Future<void> openSettings();
}

class _NotificationServiceDelegate implements NotificationServiceDelegate {
  final NotificationService _service;

  _NotificationServiceDelegate(this._service);

  @override
  Future<NotificationPermissionStatus> requestPermission() =>
      _service.requestPermission();

  @override
  Future<void> openSettings() => _service.openSettings();
}

class NotificationOptInCard extends StatefulWidget {
  final NotificationPermissionStatus status;
  final Future<void> Function() onStatusChanged;
  final NotificationServiceDelegate service;

  NotificationOptInCard({
    super.key,
    required this.status,
    required this.onStatusChanged,
    NotificationServiceDelegate? service,
  }) : service =
           service ??
           _NotificationServiceDelegate(NotificationService.instance);

  @override
  State<NotificationOptInCard> createState() => _NotificationOptInCardState();
}

class _NotificationOptInCardState extends State<NotificationOptInCard> {
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isRu = locale.languageCode.toLowerCase().startsWith('ru');
    final title = isRu ? 'Включить уведомления' : 'Enable notifications';
    final descUndetermined = isRu
        ? 'Получайте напоминания о ежедневных целях.'
        : 'Get reminders to complete your daily goals.';
    final descDenied = isRu
        ? 'Уведомления отключены. Включите их в настройках.'
        : 'Notifications are disabled. Turn them on in settings.';
    final primaryLabel = widget.status == NotificationPermissionStatus.denied
        ? (isRu ? 'Открыть настройки' : 'Open Settings')
        : (isRu ? 'Включить' : 'Enable');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.status == NotificationPermissionStatus.denied
                  ? descDenied
                  : descUndetermined,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _processing ? null : _handlePrimary,
                child: _processing
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Text(primaryLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePrimary() async {
    setState(() {
      _processing = true;
    });
    try {
      if (widget.status == NotificationPermissionStatus.denied) {
        await widget.service.openSettings();
      } else {
        await widget.service.requestPermission();
      }
      await widget.onStatusChanged();
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }
}
