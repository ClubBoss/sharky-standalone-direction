import 'package:flutter/material.dart';
import '../services/user_profile_service.dart';
import '../services/account_service.dart';

/// Profile screen for viewing and editing local user profile.
///
/// Features:
/// - Edit username
/// - Toggle email opt-in
/// - Manage experiment flags
/// - View account ID
/// - Reset profile
class UserProfileScreen extends StatefulWidget {
  UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _profileService = UserProfileService();
  final _accountService = AccountService();
  final _nameController = TextEditingController();

  UserProfile? _profile;
  String? _accountId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getOrCreate();
      final accountId = await _accountService.getUserId();

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _accountId = accountId;
        _nameController.text = profile.name ?? '';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showError('Не удалось загрузить профиль');
    }
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    try {
      await _profileService.updateName(name);
      if (!mounted) return;
      _showSuccess('Имя сохранено');
    } catch (e) {
      if (!mounted) return;
      _showError('Не удалось сохранить имя');
    }
  }

  Future<void> _toggleEmailOptIn(bool value) async {
    try {
      await _profileService.updateEmailOptIn(value);
      final updated = await _profileService.getOrCreate();
      if (!mounted) return;
      setState(() {
        _profile = updated;
      });
    } catch (e) {
      if (!mounted) return;
      _showError('Не удалось изменить настройку');
    }
  }

  Future<void> _toggleExperiment(String experimentId) async {
    try {
      await _profileService.toggleExperiment(experimentId);
      final updated = await _profileService.getOrCreate();
      if (!mounted) return;
      setState(() {
        _profile = updated;
      });
    } catch (e) {
      if (!mounted) return;
      _showError('Не удалось изменить эксперимент');
    }
  }

  Future<void> _resetProfile() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сбросить профиль?'),
        content: const Text(
          'Это удалит все настройки профиля. Действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final accountId = await _accountService.getUserId();
      await _profileService.delete(accountId);
      _profileService.clearCache();
      await _loadProfile();
      if (!mounted) return;
      _showSuccess('Профиль сброшен');
    } catch (e) {
      if (!mounted) return;
      _showError('Не удалось сбросить профиль');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red[700]),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green[700]),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Профиль игрока')),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _profile == null
        ? _buildErrorState()
        : _buildProfileContent(),
  );

  Widget _buildErrorState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'Не удалось загрузить профиль',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loadProfile,
          child: const Text('Попробовать снова'),
        ),
      ],
    ),
  );

  Widget _buildProfileContent() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _buildNameSection(),
      const SizedBox(height: 24),
      _buildEmailOptInSection(),
      const SizedBox(height: 24),
      _buildExperimentsSection(),
      const SizedBox(height: 32),
      const Divider(),
      const SizedBox(height: 16),
      _buildFooterSection(),
    ],
  );

  Widget _buildNameSection() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Имя игрока',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Введите ваше имя',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveName,
                tooltip: 'Сохранить',
              ),
            ),
            onSubmitted: (_) => _saveName(),
          ),
        ],
      ),
    ),
  );

  Widget _buildEmailOptInSection() => Card(
    child: SwitchListTile(
      title: const Text('Получать новости по email'),
      subtitle: const Text('Анонсы новых функций и обновлений'),
      value: _profile?.emailOptIn ?? false,
      onChanged: _toggleEmailOptIn,
    ),
  );

  Widget _buildExperimentsSection() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Экспериментальные функции',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            title: const Text('Инструменты отладки'),
            subtitle: const Text('Показывать дополнительную информацию'),
            value: _profile?.experiments.contains('show_debug_tools') ?? false,
            onChanged: (_) => _toggleExperiment('show_debug_tools'),
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            title: const Text('Ранний доступ'),
            subtitle: const Text('Новые функции до официального релиза'),
            value: _profile?.experiments.contains('early_access') ?? false,
            onChanged: (_) => _toggleExperiment('early_access'),
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            title: const Text('Расширенная статистика'),
            subtitle: const Text('Детальная аналитика игры'),
            value: _profile?.experiments.contains('advanced_stats') ?? false,
            onChanged: (_) => _toggleExperiment('advanced_stats'),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    ),
  );

  Widget _buildFooterSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Информация об аккаунте',
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
      ),
      const SizedBox(height: 8),
      Card(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.fingerprint, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID аккаунта',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _accountId ?? 'Неизвестно',
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _resetProfile,
          icon: const Icon(Icons.refresh),
          label: const Text('Сбросить профиль'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red[700]),
        ),
      ),
    ],
  );
}
