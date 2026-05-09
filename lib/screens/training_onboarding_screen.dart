import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import 'template_library/template_library_screen.dart';

class TrainingOnboardingScreen extends StatefulWidget {
  TrainingOnboardingScreen({super.key});

  @override
  State<TrainingOnboardingScreen> createState() =>
      _TrainingOnboardingScreenState();
}

class _TrainingOnboardingScreenState extends State<TrainingOnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_training_onboarding', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => TemplateLibraryScreen()),
    );
  }

  Widget _page(String title, String text) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final pages = [
      _page(
        'Тренировочный пак',
        'Карточка со спотом, варианты действий и EV каждой опции',
      ),
      _page('Ошибки', 'Неверные ответы сохраняются в «Повторы»'),
      _page(
        'Прогресс и стрик',
        'Проходи споты без ошибок, чтобы растить стрик',
      ),
      _page('Статистика', 'Смотри результаты во вкладке «📊 Insights»'),
    ];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (v) => setState(() => _index = v),
              children: pages,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < pages.length; i++)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _index ? Colors.orange : Colors.white24,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _index == pages.length - 1
                  ? _finish
                  : () => _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
              child: Text(_index == pages.length - 1 ? 'Понял!' : 'Далее'),
            ),
          ),
        ],
      ),
    );
  }
}
