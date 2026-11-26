# POST.17 — device acceptance checklist (B106 preflight)

Reference: English, iPhone 14 Pro (393×852). Record the build/commit, pilot flag,
entry point, task/recipe IDs, observed result and any failure. This checklist is
not a device-pass receipt.

Logic prerequisite: `test/ui_v2/act0_post17_timed_logic_v1_test.dart` (Tier A,
with and without `--dart-define=SHARKY_W13_PLUS_PILOT=true`). It covers expiry at
the deadline, late submissions, authored grades before the deadline, terminal
result stability, generated harder-variant source/action parity, pilot isolation,
and the exact W1–W12 release snapshot.

Current boundary: Act0 has no timed-decision entry or countdown wired to
`Act0TimedDecisionV1`. Do not confuse replay/theory timers with decision timing.
The timed steps remain blocked until an actual learner-facing integration exists;
this package changes no UI or route. The W14 `slightly_harder` authored drills
are counterfactuals, not same-answer copies: seven of their ten embedded
baselines intentionally have a different best action. Same-answer parity applies
to the six source-linked generated Daily Practice variants, not those original
counterfactuals. Four authored harder drills have no generated recipe.

## Ten steps

1. Verify both targeted CI invocations pass on the candidate; use the recorded
   iPhone build for all observations. Do not substitute a historical green run.
2. With the pilot off, open an ordinary W1–W12 drill. Confirm no timer or harder
   pilot entry appears and the ordinary answer/feedback path is unchanged.
3. In a pilot-enabled debug build, reach W14 → `A slightly harder next step`
   through Learn; complete eligible source drills. Confirm actual task IDs and
   authored answers (including a case whose changed facts reverse the baseline
   answer). Do not bypass locked progress to claim a learner-path pass.
4. Open the integrated timed learner entry once supplied; confirm that its timer
   starts on the decision, not the previous screen, and record the configured
   duration. If no entry exists, record **BLOCKED** for steps 4–9.
5. Submit the preferred option before expiry: the feedback must match the
   authored grade, with no subsequent timeout overwriting it.
6. Start a fresh attempt and submit a nonpreferred option before expiry: feedback
   must match that option's authored grade, not receive a timing bonus.
7. Start a fresh attempt and let the countdown reach zero with no selection:
   observe one incorrect miss, no correct-answer or independent mastery credit,
   and a usable continuation/repair path (expiry test).
8. Try selecting the preferred option at or after expiry and repeatedly tapping
   the answer: the result must remain the original miss with no duplicate
   submission or credit (deadline and terminal-result tests).
9. Retry/leave and reopen: verify there is no stale timer or late callback
   corrupting a new attempt; check that reopening saved progress does not turn
   the missed decision into success. Record the observed lifecycle behavior.
10. From Daily Practice, open a generated harder rep for an eligible completed
    source (e.g. `harder_dirty_flush`). Confirm the recipe identifies that source,
    the new table is legal, the preferred action matches the source, and the
    rep awards no course XP. Check the W1–W12 snapshot test remains green. Record
    PASS only after all ten steps pass; otherwise retain the exact blocker.
