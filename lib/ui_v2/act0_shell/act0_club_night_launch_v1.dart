import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_club_night_components_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_club_night_tokens_v1.dart';

typedef _T = Act0ClubNightTokensV1;

/// Club Night launch view, shown while the app prepares the first screen.
///
/// Same wall colour as the native launch screen and every other screen, so
/// there is no white flash and no spinner: Sharky in a brass-edged ring,
/// the wordmark and one brass line.
class Act0ClubNightLaunchViewV1 extends StatelessWidget {
  const Act0ClubNightLaunchViewV1({super.key});

  static const String wordmark = 'Sharky';
  static const String tagline = 'POKER COACH';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        key: const Key('act0_club_night_launch'),
        backgroundColor: _T.wall,
        body: Act0ClubTextScaleV1(
          child: Center(
            child: Semantics(
              label: 'Sharky is getting ready',
              liveRegion: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _T.brassEdge, width: 1.5),
                    ),
                    child: const ExcludeSemantics(
                      child: Act0ClubSharkyRingV1(
                        moment: Act0ClubSharkyMomentV1.hint,
                        size: 96,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(wordmark, style: _T.figure),
                  const SizedBox(height: 4),
                  Text(
                    tagline,
                    style: _T.sectionLabel.copyWith(
                      color: _T.brass,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
