# Monetization options · B149 / PLAN 1.3

**Decision pending, not a commercial profile.** Compare on beta behavior, then let
the owner choose. No price, feature admission, offer or entitlement is approved by
 this study. The Nov 23 [value index](VALUE_INDEX_v1.md) (source: `l0-audit/reasoning/value_index/value_index_v1.md`)
 labels W1–W12 free; the earlier PLAN 1.3 wall/trial alternatives deliberately test
 a departure from that recommendation, not a change to the free promise today.

## 1. What learners get

**Common free floor:** W1–W4 without a payment gate; J1, explanations, retries,
Review and transfer/recheck of one's own errors, basic Daily Practice, progress,
accessibility, table and language. Finish every started lesson and its repair even
if a subscription/trial lapses. Never charge or deduct credits for errors, retry,
review or refill practice. Basic history, goal route, returner refresh, live-room
lessons and spot search follow the index's free designation wherever available.

| Alternative | Free | Proposed paid | Learning risk and mitigation |
|---|---|---|---|
| W4 wall | Common floor, W1–W4 | W5–W12 new lessons; ongoing volume depth only if approved | Breaks the free-core recommendation at W5; may stop transfer and reduce W12 reach. Show terms before W5; no gate inside an open lesson or repair. A finite course alone may not qualify as recurring value. |
| Lesson bankroll | W1 freeroll; from W2 earned learning credits fund new lessons; no effective barrier to W1–W4; after W4 soft pacing, free refill by practice | High Roller: unlimited new lessons, no credit constraint | Time/effort friction may drive learners away or penalize novices. Correct independent answers reward credits; greatest reward for repairing errors. No purchased credits, debt, cash-out, loss of progress or ads. Always a free route forward. |
| Trial → subscription | Common floor; opt-in trial of W5+ at W4 boundary | Continued new W5+ lessons after trial | Time pressure and expiration may interrupt learning. Trial may end only at a new lesson boundary in effect; repair/started lesson stays free. No forced trial to access W1–W4. |
| Free course + paid practice | All W1–W12 and common floor | Optional fresh generator variants, STYLES, Vol. 2/3 depth, advanced leak trends and other approved candidates | Free practice must remain useful after course; never sell the solution to a mistake. Charge for optional breadth/novelty, not correction. |
| Wall + practice | Same free as wall | One subscription for W5+ plus optional premium practice | Wall risk unchanged; recurring value stronger if novelty is real. |
| Bankroll + practice | Same free as bankroll | One High Roller subscription for unlimited lessons plus optional premium practice | Soft pacing plus optional depth; no separate W5 wall and no double charge. |
| Trial + practice | Same free as trial | One subscription for advanced course and premium practice; optional practice offer independent of course boundary | Trial expiry risk plus pressure to buy novelty; keep the same free floor, no duplicate subscriptions. |

**Candidate feature map** (value index v1.1, premium-candidate column, not a list of
shipped features). The practice add-on in the four practice-bearing models
can draw from VI-24 generator (W13+), VI-37 scripted opponent STYLES, VI-22 W17–W24
and VI-23 W25–W36 transfer/depth (Vol. 2/3, staged), VI-34 leak dashboard/trends,
VI-38 optional warm-up, VI-20 extra 9-max pack, VI-41 extended chart library,
VI-35 own-hand leak finder, VI-15 advanced replay controls and VI-18 extra import
formats. In wall/trial/bankroll alone these are outside the priced bundle and can
remain free if released or simply unavailable; the declared wall affects new
course lessons only. Basic hand history/timeline, W1–W12 fundamentals and repairs
stay free in the practice-only model. Any candidate used in a prescribed repair
or essential accessibility path must be free in that context. VI-31 bots/VI-32 AI
coach remain excluded; VI-42 standalone MTT trainer and VI-45 bankroll log are
Drop, not planned benefits. Do not advertise features still behind gates or flags.

## 2. Store and trust constraints

For every paid option, standard iOS digital-content billing uses Apple IAP (App
Review Guidelines 3.1.1); 3.1.2 requires recurring value, at least a seven-day
subscription period and access across supported devices. Disclose actual price,
billing period, renewal, access, cancellation and restore before commitment;
trial terms must explicitly state duration and subsequent charge, use the store's
introductory-offer flow, and respect eligibility. Wall and bankroll offers must
explain free limits before users reach them; practice bundles must not imply all
optional features already exist. On Android later, use Google Play Billing for
standard digital education subscriptions, and follow its subscription disclosure,
management and cancellation rules. Regional exceptions require separate review. If recurring value is not demonstrable,
reject the subscription or separately study a one-time unlock.

This is **poker decision education**, not real-money gaming: no deposits, wagers,
cash prizes, transferable credits, cash-out, gambling referrals or live advice
while wagering. Bankroll credits are earned, non-purchasable learning resources,
not money; label/review the mechanic and age-rating questionnaire honestly,
including simulated gambling where applicable. Avoid gambling imagery or framing
in the offer and metadata; never claim guaranteed winnings. Apple's 5.3 and
Google's gambling rules would constrain real-money features, which are explicitly
out of scope. Check store policy and classifications again at submission; no
claim of approval or legal clearance here.

Sources: [Apple App Review Guidelines §3.1 and §5.3](https://developer.apple.com/app-store/review/guidelines/),
[Google Play payments](https://support.google.com/googleplay/android-developer/answer/9858738),
[Google Play subscriptions](https://support.google.com/googleplay/android-developer/answer/9900533),
[Google Play real-money gambling policy](https://support.google.com/googleplay/android-developer/answer/9877032).

## 3. Simulator and decision procedure

Run from repository root:

```sh
python3 tools/monetization_sim_v1.py tools/monetization_sim_inputs_assumed_v1.json
python3 -B tools/test/monetization_sim_v1_test.py
```

Replace low/base/high ranges and provenance in a local copy with observed beta
aggregates where available; see [beta measurement list](MONETIZATION_BETA_MEASUREMENT_v1.md).
The simulator uses 4,000 paired virtual installs scaled to 1,000, 365 days from
first open, fixed seed, 12 approximate monthly billing periods. D0 is active;
D1/D7/D30 exact-age active rates are interpolated linearly, with an explicit
post-D30 decay. A mix of persistent ranked and independent intermittent activity
preserves those daily marginals without treating app retention as paid churn.
Daily lessons are completed new lessons per active day. Course list counts
(W1–W12: 15/7/7/7/7/7/3/5/4/4/6/7) come from the three `act0_shell_lessons_w*_v1.dart`
source lists: W4 ends at 36 and W12 unlocks at 72 completions. Recheck counts at beta.
W12 unlocked is the learning-completion proxy, not mastery or observed W12 entry.

Each offer has one eligible opportunity; wall/trial/bankroll at the new-lesson
boundary after W4, optional practice at first active day on/after novelty loss among the assumed
practice-participating share.
Trial starts only with opt-in and can convert at expiration even without an app
visit. One paid episode per learner; no reactivation, no payment stacking.
Bankroll models use effective post-W4 free pace (practice refill/time cost), not
an approved currency economy. Lessons are aggregate progress units; repairs are
free in every option and not counted as monetizable lesson units. Subscription
churn controls renewal and paid access; progress already made survives expiry.

Gross billed USD, not profit: no refunds, fees, taxes, advertising, acquisition
costs or annual plans. Same retention/price/churn inputs across models to isolate
access mechanics; real offer uptake and behavioral response are unknown. Wall,
bankroll and practice have separately editable conversion ranges; default brackets
are deliberately equal, so some revenue ties are by construction. Low/base/high
are **parameter sets**, not revenue confidence bounds (later repeat and higher
churn can reduce revenue). Test one parameter at a time around base and rerun
with alternate offer/churn scenarios before making a choice. No beta willingness
to pay, model-specific churn, repair harm, feature demand or price elasticity is
inferred from the simulation. All inputs shipped here are assumed, with benchmark
context or explicitly internal stress ranges in JSON.

Compare revenue and W12 reach against the free control and first-week B0 learning
criteria. Discard any model that puts a repair behind payment or breaks the free
floor; examine remaining learning/revenue trade-offs across ranges, not just the
base ranking. Seek owner selection only after actual beta evidence and uncertainty
review. COM-01–04 original acceptance (approved profile, actual WTP/value evidence,
access/purchase/restore/failure and transparent offer) remains open. B149 supplies
COM.pre scope discovery only; no app, paywall or entitlement code.
