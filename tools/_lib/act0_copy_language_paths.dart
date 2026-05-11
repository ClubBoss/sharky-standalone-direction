String act0NormalizedLanguageCodeForToolsV1(String languageCode) =>
    languageCode.trim().toLowerCase().split(RegExp('[-_]')).first;

String act0LanguageCopyFilePathV1(String languageCode) {
  final normalized = act0NormalizedLanguageCodeForToolsV1(languageCode);
  return 'lib/ui_v2/act0_shell/l10n/act0_copy_${normalized}_v1.dart';
}
