import 'package:flutter/material.dart';
import '../services/skill_summary_service.dart';

/// Displays a personal skill map showing strengths, weaknesses, and new topics
/// based on recent training session analysis.
///
/// **Sections:**
/// - **Strong**: Topics with ≥3 correct spots, no mistakes (last 14 days)
/// - **Needs Practice**: Topics with ≥2 mistakes (last 14 days)
/// - **New Topics**: First-ever sessions completed in last 7 days
///
/// Each section displays 2-3 topics with icons and labels. Empty sections are hidden.
///
/// **Integration:**
/// ```dart
/// SkillFocusCard(), // Add to profile_screen.dart
/// ```
class SkillFocusCard extends StatefulWidget {
  const SkillFocusCard({super.key});

  @override
  State<SkillFocusCard> createState() => _SkillFocusCardState();
}

class _SkillFocusCardState extends State<SkillFocusCard> {
  bool _loading = true;
  List<String> _strongTopics = [];
  List<String> _weakTopics = [];
  List<String> _newTopics = [];

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    setState(() => _loading = true);

    try {
      final service = SkillSummaryService.instance;
      await service.load();

      setState(() {
        _strongTopics = service.getStrongTopics(limit: 3);
        _weakTopics = service.getWeakTopics(limit: 3);
        _newTopics = service.getNewTopics(limit: 3);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';

    // Hide card if all sections are empty
    if (!_loading &&
        _strongTopics.isEmpty &&
        _weakTopics.isEmpty &&
        _newTopics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.psychology, size: 24),
                const SizedBox(width: 8),
                Text(
                  isRu ? 'Карта навыков' : 'Skill Focus',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              // Strong Topics Section
              if (_strongTopics.isNotEmpty) ...[
                _buildSection(
                  title: isRu ? 'Сильные стороны' : 'Strong',
                  icon: Icons.star,
                  iconColor: Colors.amber,
                  topics: _strongTopics,
                ),
                const SizedBox(height: 12),
              ],

              // Weak Topics Section
              if (_weakTopics.isNotEmpty) ...[
                _buildSection(
                  title: isRu ? 'Требует практики' : 'Needs Practice',
                  icon: Icons.fitness_center,
                  iconColor: Colors.orange,
                  topics: _weakTopics,
                ),
                const SizedBox(height: 12),
              ],

              // New Topics Section
              if (_newTopics.isNotEmpty) ...[
                _buildSection(
                  title: isRu ? 'Новые темы' : 'New Topics',
                  icon: Icons.lightbulb,
                  iconColor: Colors.blue,
                  topics: _newTopics,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> topics,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Section header
      Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),

      // Topic chips
      Wrap(
        spacing: 8,
        runSpacing: 6,
        children: topics.map(_buildTopicChip).toList(),
      ),
    ],
  );

  Widget _buildTopicChip(String topicId) {
    // Format topic ID: "preflop_basics" → "Preflop Basics"
    final formatted = topicId
        .split('_')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        formatted,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
