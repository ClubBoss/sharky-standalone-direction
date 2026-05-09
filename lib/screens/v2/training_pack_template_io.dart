import "dart:core" as core;
import 'dart:core';
import 'dart:convert';
import 'dart:io';
part of 'training_pack_template_list_screen.dart';
// ignore_for_file: undefined_identifier, undefined_method, undefined_named_parameter, unchecked_use_of_nullable_value, const_with_non_const, argument_type_not_assignable, ambiguous_import, non_constant_default_value, undefined_class, undefined_getter, list_element_type_not_assignable, non_type_as_type_argument, undefined_prefixed_name, expected_token

mixin _TplListIOMixin on _TplListStateBase {
  Future<void> _export() async {
    final json = jsonEncode([
      for (final template in this._templates)
        if (!template.isDraft) template.toJson(),
    ]);
    await Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Templates copied to clipboard')));
  }

  Future<void> _import() async {
    final clip = await Clipboard.getData('text/plain');
    if (clip?.text == null || clip!.text!.trim().isEmpty) return;
    List? raw;
    try {
      raw = jsonDecode(clip.text!);
    } catch (_) {}
    if (raw is! List) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid JSON')));
      return;
    }
    final imported = [
      for (final entry in raw)
        TrainingPackTemplateV2.fromJson(Map<String, dynamic>.from(entry)),
    ];
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Import templates?'),
        content: Text(
          'This will add ${imported.length} template(s) to your list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Import'),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      setState(() {
        this._templates.addAll(imported);
        this._sortTemplates();
      });
      TrainingPackStorage.save(this._templates);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${imported.length} template(s) imported')),
      );
    }
  }

  Future<void> _importCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final data = file.bytes != null
        ? String.fromCharCodes(file.bytes!)
        : await File(file.path!).readAsString();
    final allRows = CsvToListConverter().convert(data.trim());
    try {
      final template = PackImportService.importFromCsv(
        csv: data,
        templateId: Uuid().v4(),
        templateName: p.basenameWithoutExtension(file.name),
      );
      final exec = context.read<EvaluationExecutorService>();
      for (final spot in template.spots) {
        await exec.evaluateSingle(
          context,
          spot,
          template: template,
          anteBb: template.anteBb,
        );
      }
      final skipped = allRows.length - 1 - template.spots.length;
      setState(() {
        this._templates.add(template);
        this._sortTemplates();
      });
      TrainingPackStorage.save(this._templates);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported ${template.spots.length} spots${skipped > 0 ? ', $skipped skipped' : ''}',
          ),
        ),
      );
      this._edit(template);
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid CSV')));
    }
  }

  Future<void> _pasteCsv() async {
    final clip = await Clipboard.getData('text/plain');
    final text = clip?.text?.trim();
    if (text == null || !text.startsWith('Title,HeroPosition')) return;
    final rows = CsvToListConverter().convert(text);
    try {
      final template = PackImportService.importFromCsv(
        csv: text,
        templateId: Uuid().v4(),
        templateName: 'Pasted Pack',
      );
      final exec = context.read<EvaluationExecutorService>();
      for (final spot in template.spots) {
        await exec.evaluateSingle(
          context,
          spot,
          template: template,
          anteBb: template.anteBb,
        );
      }
      final skipped = rows.length - 1 - template.spots.length;
      setState(() {
        this._templates.add(template);
        this._sortTemplates();
      });
      TrainingPackStorage.save(this._templates);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported ${template.spots.length} spots${skipped > 0 ? ', $skipped skipped' : ''}',
          ),
        ),
      );
      this._edit(template);
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid CSV')));
    }
  }
}
