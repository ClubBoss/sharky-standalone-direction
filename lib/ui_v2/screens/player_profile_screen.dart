import 'package:flutter/material.dart';

import '../components/design_button.dart';
import '../components/design_card.dart';
import '../components/design_panel.dart';
import '../components/mastery_indicator.dart';
import '../components/sharky_hint_balloon.dart';
import '../components/sharky_persona_panel.dart';
import '../components/traits_list.dart';
import '../components/xp_progress_bar.dart';
import '../design/design_layout.dart';
import '../design/design_tokens.dart';
import '../design/design_typography.dart';
import '../persona/sharky_persona_events.dart';
import '../persona/sharky_persona_router.dart';
import '../persona/sharky_persona_state.dart';

class PlayerProfileScreen extends StatefulWidget {
  const PlayerProfileScreen({super.key});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  final SharkyPersonaRouter _persona = SharkyPersonaRouter(
    SharkyPersonaEvents.onIdle(),
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _persona.setState(SharkyPersonaEvents.onStreak()));
  }

  @override
  Widget build(BuildContext context) {
    final showHint =
        _persona.state.reaction == SharkyReaction.think ||
        _persona.state.reaction == SharkyReaction.celebrate;
    return Scaffold(
      backgroundColor: Color(DesignColors.surface),
      body: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(DesignLayout.pagePadding),
              child: DesignPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Player Profile',
                      style: TextStyle(
                        fontSize: DesignTypography.h1,
                        fontWeight: FontWeight.bold,
                        color: Color(DesignColors.accent),
                      ),
                    ),
                    const SizedBox(height: DesignLayout.sectionSpacing),

                    DesignPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'XP Progress',
                            style: TextStyle(
                              fontSize: DesignTypography.h2,
                              fontWeight: FontWeight.bold,
                              color: Color(DesignColors.accent),
                            ),
                          ),
                          const SizedBox(height: DesignLayout.itemSpacing),
                          const DesignCard(
                            child: Text(
                              'Level, XP Bar, Streak (future)',
                              style: TextStyle(
                                fontSize: DesignTypography.body,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(height: DesignLayout.itemSpacing),
                          const XpProgressBar(progress: 0.42),
                        ],
                      ),
                    ),

                    const SizedBox(height: DesignLayout.sectionSpacing),

                    Text(
                      'Mastery',
                      style: TextStyle(
                        fontSize: DesignTypography.h2,
                        fontWeight: FontWeight.bold,
                        color: Color(DesignColors.accent),
                      ),
                    ),
                    const SizedBox(height: DesignLayout.itemSpacing),
                    const MasteryIndicator(level: 'Novice'),
                    const SizedBox(height: DesignLayout.sectionSpacing),
                    Text(
                      'Traits',
                      style: TextStyle(
                        fontSize: DesignTypography.h2,
                        fontWeight: FontWeight.bold,
                        color: Color(DesignColors.accent),
                      ),
                    ),
                    const SizedBox(height: DesignLayout.itemSpacing),
                    const TraitsList(
                      traits: ['Focused', 'Adaptive', 'Resilient'],
                    ),

                    const SizedBox(height: DesignLayout.sectionSpacing),

                    DesignButton(
                      label: 'Edit Profile (future)',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
          SharkyPersonaPanel(
            state: _persona.state,
            orchestrator: null,
            message: _persona.state.message,
          ),
          if (showHint) SharkyHintBalloon(text: _persona.state.message),
        ],
      ),
    );
  }
}
