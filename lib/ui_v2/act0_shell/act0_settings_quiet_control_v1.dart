import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/app_settings_service.dart';
import 'package:poker_analyzer/ui/settings/privacy_terms.dart';
import 'act0_academy_iconography_v1.dart';
import 'act0_home_north_star_preview_v1.dart';

const kAct0SettingsQuietControlPreviewV1 = bool.fromEnvironment(
  'SHARKY_SETTINGS_QUIET_CONTROL_PREVIEW',
);

enum _LearningAction { welcome, placement }

/// Pop the pushed route before handing control back to the shell's real owner.
Future<void> openAct0SettingsQuietControlV1(
  BuildContext context, {
  required VoidCallback onRetakePlacement,
  required VoidCallback? onReplayWelcome,
}) async {
  if (ModalRoute.of(context)?.isCurrent != true) return;
  final action = await Navigator.of(context).push<_LearningAction>(
    MaterialPageRoute(
      builder: (_) =>
          Act0SettingsQuietControlV1(canReplayWelcome: onReplayWelcome != null),
    ),
  );
  if (!context.mounted) return;
  switch (action) {
    case _LearningAction.welcome:
      onReplayWelcome?.call();
    case _LearningAction.placement:
      onRetakePlacement();
    case null:
      break;
  }
}

class Act0SettingsQuietControlV1 extends StatefulWidget {
  const Act0SettingsQuietControlV1({super.key, this.canReplayWelcome = true});
  final bool canReplayWelcome;

  @override
  State<Act0SettingsQuietControlV1> createState() => _SettingsState();
}

class _SettingsState extends State<Act0SettingsQuietControlV1> {
  final _settings = AppSettingsService.instance;
  late Future<void> _loaded;
  bool _leaving = false;
  static const _text = Act0HomeNorthStarPaletteV1.text;
  static const _muted = Color(0xFFA6BEBF);
  static const _aqua = Color(0xFF45DACE);
  static const _gold = Color(0xFFF0CF94);
  static const _rule = Color(0xFF1B4648);

  @override
  void initState() {
    super.initState();
    _loaded = _settings.load();
  }

  void _leave(_LearningAction action) {
    if (_leaving) return;
    _leaving = true;
    Navigator.pop(context, action);
  }

  Future<void> _policy(Widget screen) async {
    if (_leaving) return;
    _leaving = true;
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => screen));
    _leaving = false;
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      brightness: Brightness.dark,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? const Color(0xFF1BBFB2)
              : const Color(0xFF345354),
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? _aqua : _rule,
        ),
      ),
    ),
    child: Scaffold(
      key: const Key('act0_settings_quiet_control_v1'),
      backgroundColor: const Color(0xFF001719),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF03282A), Color(0xFF001719), Color(0xFF001113)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 23, 6),
                child: Row(
                  children: [
                    IconButton(
                      key: const Key('settings_back'),
                      tooltip: 'Back',
                      onPressed: () => Navigator.pop(context),
                      icon: const RotatedBox(
                        quarterTurns: 2,
                        child: Act0AcademyGlyphV1(
                          asset: Act0AcademyIconographyV1.forward,
                          color: _muted,
                        ),
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF0A2A2C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                          side: const BorderSide(color: _rule),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: _text,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<void>(
                  future: _loaded,
                  builder: (context, load) {
                    if (load.hasError) {
                      return Center(
                        child: TextButton(
                          onPressed: () =>
                              setState(() => _loaded = _settings.load()),
                          child: const Text(
                            'Could not load preferences. Retry',
                          ),
                        ),
                      );
                    }
                    if (load.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ValueListenableBuilder<AppSettingsSnapshot>(
                      valueListenable: _settings.changes,
                      builder: (context, saved, _) => ListView(
                        key: const Key('settings_scroll'),
                        padding: const EdgeInsets.fromLTRB(23, 18, 23, 24),
                        children: [
                          const Text(
                            'YOUR EXPERIENCE',
                            style: TextStyle(
                              color: _aqua,
                              fontSize: 10,
                              letterSpacing: 2.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: 'Make Sharky\n'),
                                TextSpan(
                                  text: 'feel right.',
                                  style: TextStyle(color: _gold),
                                ),
                              ],
                            ),
                            style: TextStyle(
                              color: _text,
                              fontSize: 36,
                              height: 1.08,
                              letterSpacing: -1.3,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'A few choices for a focused learning experience.',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                          _label('FEEL & FEEDBACK'),
                          _group([
                            _row(
                              'Sound effects',
                              'Saved preference · audio unavailable',
                              Act0AcademyIconographyV1.sound,
                              color: const Color(0xFF86C9F5),
                              toggle: Switch(
                                key: const Key('settings_sound'),
                                value: saved.soundEnabled,
                                onChanged: (v) => _settings.setSoundEnabled(v),
                              ),
                            ),
                            _row(
                              'Haptics',
                              'Tactile response to decisions',
                              Act0AcademyIconographyV1.haptics,
                              toggle: Switch(
                                key: const Key('settings_haptics'),
                                value: saved.hapticsEnabled,
                                onChanged: (v) =>
                                    _settings.setHapticsEnabled(v),
                              ),
                            ),
                          ]),
                          _label('YOUR LEARNING'),
                          _group([
                            if (widget.canReplayWelcome)
                              _row(
                                'Replay Welcome',
                                'See your introduction again',
                                Act0AcademyIconographyV1.recall,
                                onTap: () => _leave(_LearningAction.welcome),
                              ),
                            _row(
                              'Retake Placement',
                              'Revisit your starting assessment',
                              Act0AcademyIconographyV1.placement,
                              color: _gold,
                              onTap: () => _leave(_LearningAction.placement),
                            ),
                          ]),
                          _label('PRIVACY & INFORMATION'),
                          _group([
                            _row(
                              'Privacy Policy',
                              'How Sharky handles your information',
                              Act0AcademyIconographyV1.privacy,
                              onTap: () => _policy(
                                const PrivacyScreen(quietControl: true),
                              ),
                            ),
                            _row(
                              'Terms of Use',
                              'Read the app terms',
                              Act0AcademyIconographyV1.terms,
                              color: _muted,
                              onTap: () => _policy(
                                const TermsScreen(quietControl: true),
                              ),
                            ),
                          ]),
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text(
                              'Preferences are saved on this device.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: _muted, fontSize: 11),
                            ),
                          ),
                          const SizedBox(height: 26),
                          const Divider(color: _rule),
                          const SizedBox(height: 10),
                          const Text(
                            'SHARKY POKER ACADEMY',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF709294),
                              fontSize: 9,
                              letterSpacing: 1.7,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _label(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 18, 0, 9),
    child: Text(
      title,
      style: const TextStyle(
        color: Color(0xFF83B2B5),
        fontSize: 10,
        letterSpacing: 1.7,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _group(List<Widget> rows) => Material(
    color: const Color(0xFF072629),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: _rule),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.only(left: 64, right: 12),
              child: Divider(height: 1, color: _rule),
            ),
          rows[i],
        ],
      ],
    ),
  );

  Widget _row(
    String title,
    String subtitle,
    String icon, {
    Color color = _aqua,
    Widget? toggle,
    VoidCallback? onTap,
  }) => MergeSemantics(
    child: Semantics(
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Center(
                  child: Act0AcademyGlyphV1(
                    asset: icon,
                    color: color,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 10.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (toggle != null)
                toggle
              else
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: Center(
                    child: Act0AcademyGlyphV1(
                      asset: Act0AcademyIconographyV1.forward,
                      color: _muted,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
