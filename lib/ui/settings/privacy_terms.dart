import 'package:flutter/material.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const String _body =
      'Sharky Poker stores learning progress, snapshots, and session history on this device so the training loop can continue reliably. '
      'You can clear local data from the Legal & Compliance screen at any time.';

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
