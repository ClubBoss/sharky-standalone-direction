import 'package:flutter/material.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const String _body =
      'Sharky privacy — English iPhone beta\n\n'
      'Stored on this device\n'
      'Sharky saves your completed lessons and tasks, answers and use of help, '
      'mistakes and repair attempts, practice queue and history, XP, activity dates '
      'and streaks, resume position, introduction choices and app preferences. '
      'Recovery copies protect local progress. These records support learning '
      'and restoring your place; they are not a verified mastery score.\n\n'
      'Network and accounts\n'
      'The current Act0 learning route runs without an account or cloud sync. '
      'It does not send your learning records to an analytics, advertising or '
      'AI service. There is no cross-app tracking. Local app data may be included '
      'in device backups managed by your operating system.\n\n'
      'Optional practice reminder\n'
      'If you turn on Practice reminder, iOS can schedule one local reminder with a generic message. '
      'Turn it off in Sharky Settings at any time. Deleting local data cancels the reminder.\n\n'
      'Retention and deletion\n'
      'Sharky keeps progress between launches. Recent-answer histories are bounded; '
      'older entries can be replaced by newer practice. Open You → Settings → Delete '
      'local data to erase learning records, recovery copies, introduction choices '
      'and preferences on this device. Deletion cannot be undone. If storage '
      'refuses deletion, Sharky asks you to retry before learning can resume. '
      'Deleting in Sharky does not delete earlier Apple backups, exported files '
      'or feedback already sent through TestFlight.\n\n'
      'TestFlight and voluntary feedback\n'
      'Apple processes beta installation, usage, crash and feedback data under '
      'TestFlight’s own privacy terms. Feedback or screenshots you choose to send '
      'may reach the app developer through Apple. Avoid including private '
      'information in feedback. Manage those records through Apple’s services. '
      'TestFlight feedback is also the beta support channel.\n\n'
      'Development diagnostics\n'
      'A separately enabled debug build can retain a filtered local learning '
      'trace. It is off in normal builds and disabled in release builds. '
      'Delete local data also removes that local trace.\n\n'
      'Updated 19 November 2026. This notice describes the current beta route; '
      'new online features require a revised notice before they are enabled.';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      key: const Key('privacy_screen_v1'),
      appBar: AppBar(title: Text(l10n.privacyPolicy)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(child: const SelectableText(_body)),
        ),
      ),
    );
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const String _body =
      'Sharky Poker is a training product for guided poker decision practice. '
      'Core training flows run without account creation in this build. '
      'Use the app responsibly and rely on in-app legal and support surfaces for current product truth.';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      key: const Key('terms_screen_v1'),
      appBar: AppBar(title: Text(l10n.termsOfUse)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(child: const SelectableText(_body)),
        ),
      ),
    );
  }
}
