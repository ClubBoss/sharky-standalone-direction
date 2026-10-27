import 'package:flutter/material.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';

/// Source-bound internal information. Public legal approval is a release gate.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key, this.quietControl = false});
  final bool quietControl;

  @override
  Widget build(BuildContext context) => _PolicyPage(
    pageKey: const Key('privacy_screen_v1'),
    title: AppLocalizations.of(context)?.privacyPolicy ?? 'Privacy Policy',
    quietControl: quietControl,
    sections: const [
      (
        'About this notice',
        'This internal preview explains the learning and preference information used by the current Sharky experience. It is available for review before public release. Operator identity, a privacy request contact and the published policy have not yet been supplied. This notice is not an approved public-release privacy policy.',
      ),
      (
        'Learning information on this device',
        'Sharky saves completed task and lesson identifiers, earned XP, placement results, skill signals, answer outcomes and learning evidence on this device. Review mistakes, repair records, independent rechecks, review timing and session records support training continuity. These records describe activity in Sharky; they do not establish professional ability or mastery.',
      ),
      (
        'Preferences',
        'Sound and haptic preferences are saved on this device and can be changed in Settings. Replaying Welcome uses the existing introduction. Retaking Placement starts another starting assessment; it does not award lesson completion or reset earned lesson XP.',
      ),
      (
        'Diagnostics and external services',
        'The learning route uses in-memory event records. A separately enabled research trace can write learning events to a local file. The current settings-event analytics adapter does not transmit Firebase Analytics events. A separate crash-reporting integration can be enabled in other configurations; it is not initialized by the current app entry. This source review is not a guarantee that no information ever leaves a device. The final release configuration and third-party services still require a complete data-flow audit.',
      ),
      (
        'Why these records are used',
        'Learning records let Sharky resume training, show earned progress, revisit mistakes and schedule review. Preferences let the app respect feedback choices. Local diagnostic records help examine behavior in internal testing.',
      ),
      (
        'Storage, retention and backups',
        'Learning records and preferences use local application storage. There is no verified cloud backup or cross-device restoration promise in this experience. Device and operating-system backup behavior can affect stored copies. Retention periods, backup coverage and any external processing must be established for the released product.',
      ),
      (
        'Local data controls',
        'Settings does not offer account deletion or complete data erasure. An older local reset affects specific learning-path, snapshot and session-fingerprint records. It has not been shown to remove all current learning records, preferences, diagnostic files or external records. Do not rely on that reset as complete erasure.',
      ),
      (
        'Privacy requests and sharing',
        'A verified operator contact and procedure for privacy requests are still required before release. The final notice must identify any active service providers, information shared with them, processing locations, retention and applicable privacy choices. This preview does not offer an unverified request or deletion button.',
      ),
      (
        'Security and audience',
        'Local storage alone does not guarantee anonymity, encryption or complete security. Security controls, the intended audience, age rating and distribution territories remain subject to release review. Sharky uses simulated poker decisions for learning.',
      ),
      (
        'Publication and changes',
        'Before public release, the operator must approve a dated policy, provide a working privacy contact and public policy address, and align this page with the shipped data practices. Updated public terms and notices will require the appropriate owner and legal review.',
      ),
    ],
  );
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key, this.quietControl = false});
  final bool quietControl;

  @override
  Widget build(BuildContext context) => _PolicyPage(
    pageKey: const Key('terms_screen_v1'),
    title: AppLocalizations.of(context)?.termsOfUse ?? 'Terms of Use',
    quietControl: quietControl,
    sections: const [
      (
        'About these terms',
        'These internal preview terms describe the current Sharky learning experience. They have not been approved for public release. The contracting operator, verified contact, effective date and applicable jurisdiction have not yet been supplied; no contracting party or governing law is invented here.',
      ),
      (
        'The learning service',
        'Sharky provides poker lessons, simulated decisions, practice, feedback and review. The current learning route does not require account creation and does not offer real-money deposits, wagers or payouts. This statement describes this learning route, not every integration present elsewhere in the project.',
      ),
      (
        'Learning outcomes',
        'Feedback and explanations support learning and can contain errors. XP, streaks, achievements and completed tasks record activity in the app. They are not a qualification, proof of mastery, financial advice or a promise of winnings or real-game results. Use independent judgment.',
      ),
      (
        'Responsible use and eligibility',
        'Use the learning experience responsibly and follow the laws that apply where you use it. Simulated poker education does not establish eligibility to participate in real-money poker. Audience, age rating and territory requirements must be settled before release.',
      ),
      (
        'Access and purchases',
        'This Settings experience contains no account, subscription, purchase or restore-purchase control. It does not promise paid access, refunds, account synchronization or cloud backup. Any future commercial offering requires its own verified terms and working store behavior.',
      ),
      (
        'Use of the app and materials',
        'Use the app for lawful learning. Do not attempt unauthorized access, interfere with its operation or misrepresent learning records. App software, lesson text, illustrations and other materials remain subject to their applicable rights and licenses. Final licensing terms and content rights require operator review.',
      ),
      (
        'Progress and device data',
        'Learning records and preferences are stored locally to support continuity. Device replacement, operating-system behavior and removal of local records can affect access to progress. No cross-device restoration or permanent availability is promised. Read the Privacy Policy for the current storage and data-control limitations.',
      ),
      (
        'Welcome and Placement',
        'Replay Welcome reopens the introduction. Retake Placement remeasures starting skills using the existing assessment. It does not grant lesson rewards or remove earned lesson XP. Assessment results and skill signals may change after a retake.',
      ),
      (
        'Availability and changes',
        'Features and educational content may change as the product develops. This preview makes no uptime or support commitment. Material public terms and changes require a dated, approved version and an appropriate notice process.',
      ),
      (
        'Rights, contact and public release',
        'No blanket waiver of consumer rights or liability limitation is asserted by this preview. A qualified legal review must establish appropriate public terms, operator and contact details, eligibility, licensing and dispute provisions for the actual release and its markets. A verified contact channel is still required before publication.',
      ),
    ],
  );
}

class _PolicyPage extends StatelessWidget {
  const _PolicyPage({
    required this.pageKey,
    required this.title,
    required this.quietControl,
    required this.sections,
  });
  final Key pageKey;
  final String title;
  final bool quietControl;
  final List<(String, String)> sections;

  @override
  Widget build(BuildContext context) => Scaffold(
    key: pageKey,
    backgroundColor: quietControl ? const Color(0xFF001719) : null,
    appBar: AppBar(
      title: Text(title),
      backgroundColor: quietControl ? const Color(0xFF03282A) : null,
      foregroundColor: quietControl ? const Color(0xFFF1FBF8) : null,
    ),
    body: SafeArea(
      child: SelectionArea(
        child: ListView(
          key: const Key('policy_scroll'),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            const Text(
              'Internal preview · Publication pending',
              style: TextStyle(color: Color(0xFFE4BB68), fontSize: 13),
            ),
            const SizedBox(height: 20),
            for (final section in sections) ...[
              Semantics(
                header: true,
                child: Text(
                  section.$1,
                  style: const TextStyle(
                    color: Color(0xFFF1FBF8),
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                section.$2,
                style: const TextStyle(
                  color: Color(0xFFB6C8D5),
                  fontSize: 16,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    ),
  );
}
