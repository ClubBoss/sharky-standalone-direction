import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/streak_tracker_service.dart';

/// Widget that allows users to freeze their streak once per week.
///
/// Displays:
/// - ❄️ icon
/// - "Use Freeze" button (if eligible)
/// - Last freeze date (if used before)
///
/// Only shown when:
/// - Current streak > 1
/// - No session today
/// - 7 days have passed since last freeze
class StreakFreezeWidget extends StatefulWidget {
  const StreakFreezeWidget({super.key});

  @override
  State<StreakFreezeWidget> createState() => _StreakFreezeWidgetState();
}

class _StreakFreezeWidgetState extends State<StreakFreezeWidget> {
  final _service = StreakTrackerService.instance;
  bool _isLoading = true;
  bool _isFreezeAvailable = false;
  DateTime? _lastFreezeDate;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadFreezeStatus();
  }

  Future<void> _loadFreezeStatus() async {
    final available = await _service.isFreezeAvailable();
    final lastFreeze = await _service.getLastFreezeDate();

    if (!mounted) return;

    setState(() {
      _isFreezeAvailable = available;
      _lastFreezeDate = lastFreeze;
      _isLoading = false;
    });
  }

  Future<void> _useFreeze() async {
    setState(() => _isProcessing = true);

    final success = await _service.freezeIfAvailable();

    if (!mounted) return;

    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getSuccessMessage()),
          backgroundColor: Colors.blue.shade600,
          duration: const Duration(seconds: 3),
        ),
      );

      // Reload status
      await _loadFreezeStatus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getErrorMessage()),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    setState(() => _isProcessing = false);
  }

  String _getSuccessMessage() {
    final locale = Localizations.localeOf(context);
    final isRu = locale.languageCode == 'ru';
    return isRu
        ? 'Заморозка применена! Ваша серия сохранена.'
        : 'Freeze applied! Your streak is safe.';
  }

  String _getErrorMessage() {
    final locale = Localizations.localeOf(context);
    final isRu = locale.languageCode == 'ru';
    return isRu ? 'Заморозка недоступна.' : 'Freeze not available.';
  }

  String _formatDate(DateTime date) {
    final locale = Localizations.localeOf(context);
    final isRu = locale.languageCode == 'ru';
    final format = isRu ? 'd MMM yyyy' : 'MMM d, yyyy';
    return DateFormat(format, locale.languageCode).format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    // Hide if freeze not available and never used
    if (!_isFreezeAvailable && _lastFreezeDate == null) {
      return const SizedBox.shrink();
    }

    final locale = Localizations.localeOf(context);
    final isRu = locale.languageCode == 'ru';
    final title = isRu ? 'Заморозка серии' : 'Streak Freeze';
    final buttonText = isRu ? 'Использовать' : 'Use Freeze';
    final lastUsedText = isRu ? 'Последнее использование:' : 'Last used:';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('❄️', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (_lastFreezeDate != null) ...[
              const SizedBox(height: 8),
              Text(
                '$lastUsedText ${_formatDate(_lastFreezeDate!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
            if (_isFreezeAvailable) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _useFreeze,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(buttonText),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
