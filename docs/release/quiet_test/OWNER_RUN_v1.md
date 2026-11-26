# Owner run — O2 / F1M

1. **Build.** Once the owner opens human testing (including designer visuals),
   select one merged candidate and record its commit, version and device.
   Install the signed English iPhone build using
   [docs/RELEASE.md](../../RELEASE.md) (Personal Team on the owner's test phone,
   or approved TestFlight if available). Prepare clean test-only progress
   for each participant; never delete personal learner data. Verify the app
   launches before recruiting. Do not use the web mirror or the F1 startup
   marker as a substitute.
2. **Prepare.** Recruit 3–5 people, at least one who plays poker, for
   20–30 minutes each. Assign codes T01–T05, not names. Give each the
   [tester guide](TESTER_GUIDE_v1.md). With consent, record the screen from
   before opening Sharky to the final W1 screen/stop (no microphone or
   unrelated personal screens). Store recordings, feedback and logs in a
   private folder **outside the Git worktree**.
3. **Observe.** Let the participant open the app and work through W1 without
   coaching, explanation or exposing the 180-second target. Observe stalls,
   misread instructions, confusing feedback, inaccessible answers and next
   steps. Record any technical intervention. If they stop, note the last
   visible lesson/task/screen; if they finish, note the W1 completion screen.
   Ask the [five feedback questions](FEEDBACK_QUESTIONS_v1.md) afterwards.
4. **Collect.** Copy any existing raw `ui_metrics_events.jsonl` from each
   test run to the private folder as `T01.jsonl`, etc. (if available). The
   exporter creates aggregate JSON, not a journey export; do not fabricate
   a participant file if no raw capture exists. Because the existing UI
   stream lacks milestones, use the recording and progress UI to enter one
   observation row per participant in `observations.csv` (see below).
   Keep the recording offsets as reproducible evidence, not a stopwatch.
5. **Run one report.** From the repository root, for example:

   ```sh
   python3 tools/f1m_report_v1.py --observations /private/quiet-test/observations.csv /private/quiet-test/T01.jsonl /private/quiet-test/T02.jsonl
   ```

   Substitute your actual private paths; omit unavailable JSONL arguments.
   The CSV alone works when the app produces no raw file; JSONL alone
   reports unknowns rather than invented measurements. Each JSONL filename
   stem matches a tester code (one file per tester). Include every recruited
   participant who started, including incomplete/unknown sessions.
6. **Verdict.** Review per-tester table and `F1M pass k/n (≤180 s)`.
   PASS means an evidenced timely answer, LATE means a measured answer after
   180 s, NOT REACHED means the observed session ended without one, and UNKNOWN
   means timing evidence is missing. Unknowns remain in the denominator; do
   not conclude F1M is met if evidence is missing. Report W1 completions out
   of participants separately for O2. Classify observations as "blocks
   understanding" or "minor", including evidence for JRN-02 (entry), JRN-04
   (choices), ENG-01 (truthful result) and ENG-03 (next step). Fix and retest
   material blockers before claiming O2 complete. Owner adjudicates the
   real outcomes; prep or synthetic tests do not count as human acceptance.
   Retain only necessary consented private evidence, never commit actual logs,
   CSVs, recordings or participant feedback.

## Observation CSV (local-only fallback, not app telemetry)

Header, followed by one row per participant. The example is fictional:

```csv
tester,app_open_s,first_decision_s,end_s,w1_tasks_done,repairs_taken,drop_off
T01,5.2,142.6,1100,12,2,W1 complete
T02,3.5,,280,2,1,First Table Guide
T03,,,,,,Recording unavailable
```

- Times are seconds on the **same continuous recording**, from its beginning:
  the tap on the Sharky icon, the first committed Fold/Call/Raise answer in
  an actual poker spot (even wrong; not a teaching Next, seat pick, card
  identification, quiz about action definitions, or just an enabled choice),
  and the final frame of the session. If choosing also requires confirmation,
  use commitment, not the uncommitted tap. Do not trim out onboarding,
  reading time, or retries.
- If the entire session was observed without a decision, leave
  `first_decision_s` blank but provide both start and end. If either timing
  boundary is unavailable or there is an unobserved interval before first
  decision, leave all timing cells blank.
- Count distinct W1 course tasks visibly completed (not just answered, not
  the repair tasks) and actual repair entries taken during the session
  (not prompts offered; repeated entries count separately). Use visible
  progress or the recording; leave a count blank when it cannot be verified.
  A verified zero is written as `0`.
- Drop-off is the final observed lesson/task/screen, or `W1 complete`; blank
  means unknown. It describes where, not why, a learner stopped.

The table automates arithmetic and aggregation. Reviewing recordings to
identify missing milestones still requires the owner; the original UI
telemetry does not support a fully automatic F1M/O2 verdict.
