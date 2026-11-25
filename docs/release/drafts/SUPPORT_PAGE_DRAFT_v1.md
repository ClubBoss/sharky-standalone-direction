# Sharky Poker support

Contact: [[OWNER: working support email]]

Operated by [[OWNER: legal name, country and contact address]].

For help with a lesson, a wrong-looking answer or a problem with the app,
email us with your app version and build (in You → Settings), iPhone model,
iOS version and the steps that led to the problem. For a lesson issue,
include its world, lesson and question if you can. Please leave private
information out of screenshots.

Settings → Support lets you copy a local diagnostic summary to include if
useful. In beta builds with Beta activity enabled, you can also choose to
copy the activity summary. Nothing is sent just by copying it.

## Frequently asked questions

**Where is my progress?**  
Sharky keeps completed lessons, practice, mistakes, XP and your place in the
course on this device. Return to Home to continue, or Review to revisit
missed decisions. No sign-in is needed.

**How do I start again?**  
Open **You → Settings → Delete local data** and confirm only if you want to
erase your progress and settings, including saved own-hand records. This
erases local recovery copies and
cancels the practice reminder too. It cannot be undone. If deletion fails,
follow the retry prompt. Other copies you sent or device backups are not
erased by this action.

**Will I keep progress if I reinstall or change phones?**  
The app has no account-based sync or built-in cloud restore. Under the
current beta default, plan to start again after reinstalling; do not rely
on a restored backup. Apple backup/restore behavior depends on your device
settings. [[OWNER: O4 — confirm start again or approve a different restore
contract; verify reinstall on the signed RC and replace this placeholder
before publishing]]. If progress seems missing, contact support before
deleting or reinstalling the app.

**Can I turn reminders off?**  
Yes. Go to You → Settings and disable Practice reminder, or manage
notification permission in iOS Settings.

**Can I play for money?**  
No. Sharky is for practising poker decisions with simulated hands and
training chips. There are no cash prizes or real-money games.

**How is my data used?**  
Read our privacy policy: [[OWNER: public HTTPS privacy policy URL]].

---

Internal publication check: set `SHARKY_SUPPORT_EMAIL` to the approved
address for the RC (`lib/ui_v2/act0_shell/act0_release_support_v1.dart`).
Check the Support and Delete local data paths on the build, publish the
support page at [[OWNER: public HTTPS support URL]], open both public URLs
without signing in and send a test email through the approved channel.
Confirm receipt and response. O4 and active channel verification remain
owner gates. This draft is not evidence that a support service is live.
