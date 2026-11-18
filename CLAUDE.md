# Sharky — Claude

Follow `AGENTS.md` (instructions) and `docs/PLAN.md` (the single plan). They override older
documents under `docs/`.

- Answer the owner in Russian unless asked otherwise; code, commits and docs for agents stay in English.
- Keep context small: read targeted line ranges of the large Act0 files
  (`act0_shell_state_v1.dart`, `act0_lesson_runner_shell_v1.dart`); never stream full test logs —
  write them to a file and extract the failing lines.
- Graphify is advisory navigation only. Never commit `graphify-out/`.
