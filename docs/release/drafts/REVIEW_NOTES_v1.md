# App Review notes — draft

## Text for App Review

Sharky Poker is a Texas Hold'em education and decision-practice app for
micro-stakes learners. It uses simulated hands, fixed learning tasks and
training chips. Chips have no cash value. There is no real-money gambling,
deposit, withdrawal, cash prize or real-money poker service in the app.
Review can also replay previously played hands that the learner enters or
imports; displayed past bet and payout amounts are historical study data,
not transactions or prizes offered by Sharky.

No account or review credentials are required. The public course includes
worlds W1–W12 with progression through lessons. To review the main flow:

1. Launch the app and proceed through the introduction. Choose to start
   with the basics.
2. Open the first lesson, read the explanation and answer a table question.
   Choose an incorrect answer to see feedback, then retry the decision
   when offered.
3. Open Practice and Review to see learning practice and missed decisions.
   Complete a lesson, close and reopen the app to see saved progress.
4. Open You → Settings → Privacy Policy. Use Delete local data and confirm
   if you want to test starting again; this removes local progress and
   settings. No login or network connection is required to study.

Learning records are stored on the device; the public build does not send
them to an analytics service. Practice reminders are local and optional.
The table and chip amounts are for learning rather than real-money play.

## Owner submission check (not reviewer copy)

- Verify exact button names and walkthrough on the signed RC. Source:
  `lib/main.dart`, `lib/ui_v2/app_root.dart`,
  `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`,
  `act0_lesson_runner_shell_v1.dart`, `act0_shell_preview_screen_v1.dart`.
- Public RC has beta metrics and diagnostic flags off. Verify the privacy
  disclosure and support contact per the other drafts.
- [[OWNER: reviewer contact name, phone, email in private App Store Connect
  fields; valid public support and privacy URLs]].
- [[OWNER: confirm accurate age-rating questionnaire including simulated
  gambling; no real-money gambling is not a claim that simulated gambling
  is absent. Confirm rights and territories]]. See
  [Apple age ratings](https://developer.apple.com/help/app-store-connect/reference/app-information/age-ratings-values-and-definitions).
- Not a claim of App Review approval, readiness to release or completed
  signed-device verification.
