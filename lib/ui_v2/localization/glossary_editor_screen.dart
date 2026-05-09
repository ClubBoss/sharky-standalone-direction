import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/localization_core.dart';
import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

class GlossaryEditorScreen extends StatefulWidget {
  const GlossaryEditorScreen({super.key});

  @override
  State<GlossaryEditorScreen> createState() => _GlossaryEditorScreenState();
}

class _GlossaryEditorScreenState extends State<GlossaryEditorScreen> {
  final LocalizationCore _localization = LocalizationCore.instance;
  final List<_GlossaryEntry> _entries = <_GlossaryEntry>[];
  final List<String> _languages = <String>['en', 'ru'];
  String _language = 'ru';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _registerDefaultTranslations();
    _loadEntries();
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  Future<void> _loadEntries() async {
    for (final entry in _entries) {
      entry.dispose();
    }
    _entries.clear();

    final translations = _localization.translationsForLanguage(_language);
    final glossary = _localization.glossaryEntries();
    final keys = <String>{
      ...translations.keys,
      ...(_language == 'ru' ? glossary.keys : const <String>{}),
    };
    final sortedKeys = keys.toList()..sort();

    final entries = sortedKeys
        .map(
          (term) => _GlossaryEntry(
            term: term,
            translation:
                translations[term] ??
                (_language == 'ru' ? glossary[term] ?? '<untranslated>' : term),
          ),
        )
        .toList();

    if (_language == 'ru' && entries.isEmpty) {
      for (final item in glossary.entries) {
        entries.add(_GlossaryEntry(term: item.key, translation: item.value));
      }
    }

    setState(() {
      _entries
        ..clear()
        ..addAll(entries);
      _loading = false;
    });
  }

  Future<void> _saveEntry(_GlossaryEntry entry) async {
    final trimmed = entry.controller.text.trim();
    final translation = trimmed.isEmpty ? '<untranslated>' : trimmed;

    _localization.addTranslation(
      source: entry.term,
      languageCode: _language,
      translation: translation,
    );

    if (_language == 'ru') {
      final current = _localization.glossaryEntries();
      current[entry.term] = translation;
      await _localization.saveGlossary(current);
      await _localization.loadGlossary();
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_label('Glossary updated'))));
    setState(() {});
  }

  Future<void> _showAddEntryDialog() async {
    final termController = TextEditingController();
    final translationController = TextEditingController();
    final result = await showDialog<_DialogResult>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_label('Add term')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: termController,
                decoration: InputDecoration(labelText: _label('Term')),
              ),
              TextField(
                controller: translationController,
                decoration: InputDecoration(labelText: _label('Translation')),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_label('Cancel')),
            ),
            TextButton(
              onPressed: () {
                final term = termController.text.trim();
                final translation = translationController.text.trim().isEmpty
                    ? '<untranslated>'
                    : translationController.text.trim();
                Navigator.of(
                  context,
                ).pop(_DialogResult(term: term, translation: translation));
              },
              child: Text(_label('Save')),
            ),
          ],
        );
      },
    );

    termController.dispose();
    translationController.dispose();

    if (result == null || result.term.isEmpty) {
      return;
    }

    if (_entries.any((entry) => entry.term == result.term)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_label('Term already exists'))));
      return;
    }

    setState(() {
      _entries.add(
        _GlossaryEntry(term: result.term, translation: result.translation),
      );
    });
    await _saveEntry(_entries.last);
    await _loadEntries();
  }

  void _changeLanguage(String language) {
    if (language == _language) {
      return;
    }
    setState(() {
      _language = language;
      _loading = true;
    });
    _loadEntries();
  }

  String _label(String value) {
    final translated = _localization.translate(value, _language);
    if (translated.trim().isEmpty) {
      return value;
    }
    return translated;
  }

  void _registerDefaultTranslations() {
    const translations = <String, String>{
      'Glossary Editor': 'Редактор глоссария',
      'Glossary updated': 'Глоссарий обновлен',
      'Add term': 'Добавить термин',
      'Term': 'Термин',
      'Translation': 'Перевод',
      'Cancel': 'Отмена',
      'Save': 'Сохранить',
      'Term already exists': 'Термин уже существует',
    };
    translations.forEach((source, translated) {
      _localization.addTranslation(
        source: source,
        languageCode: 'ru',
        translation: translated,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: VisualThemeV3.theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_label('Glossary Editor')),
          actions: [
            PopupMenuButton<String>(
              initialValue: _language,
              onSelected: _changeLanguage,
              itemBuilder: (context) => _languages
                  .map(
                    (lang) => PopupMenuItem<String>(
                      value: lang,
                      child: Text(lang.toUpperCase()),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _entries.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(VisualThemeV3.spacingM),
                  child: Text(
                    _label('No actions yet.'),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: VisualThemeV3.spacingL,
                  vertical: VisualThemeV3.spacingM,
                ),
                child: ListView.separated(
                  itemCount: _entries.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: VisualThemeV3.spacingS),
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    return Card(
                      elevation: VisualThemeV3.elevationLow,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(
                          VisualThemeV3.spacingM,
                        ),
                        title: Text(
                          entry.term,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: TextField(
                          controller: entry.controller,
                          decoration: InputDecoration(
                            labelText: _label('Translation'),
                          ),
                          onSubmitted: (_) => _saveEntry(entry),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.save),
                          onPressed: () => _saveEntry(entry),
                        ),
                      ),
                    );
                  },
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddEntryDialog,
          tooltip: _label('Add term'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _GlossaryEntry {
  _GlossaryEntry({required this.term, required String translation})
    : controller = TextEditingController(text: translation);

  final String term;
  final TextEditingController controller;

  void dispose() {
    controller.dispose();
  }
}

class _DialogResult {
  const _DialogResult({required this.term, required this.translation});

  final String term;
  final String translation;
}
