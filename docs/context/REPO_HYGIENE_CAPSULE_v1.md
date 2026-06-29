# Repo Hygiene Capsule v1

Status: ACTIVE repo sync/checkpoint capsule.

Use this for future cheap mainline sync, branch hygiene, and checkpoint tasks.

## Read First

- `AGENTS.md`
- `docs/context/CURRENT_STATE_CAPSULE_v1.md`
- latest repo integration checkpoint artifact if relevant

Do not read product docs unless the task requires a product claim.

## Standard Inspection

Run:

- `git status --short --branch`
- `git branch --show-current`
- `git log --oneline --decorate -n 20`
- `git remote -v`
- `git fetch --prune origin` when remote truth matters
- `git rev-parse HEAD origin/main main` when checking main sync

## Output Folder Rule

- Do not stage `output/`.
- Do not delete `output/`.
- Do not inspect screenshots/output contents unless the prompt explicitly makes visual evidence the task.
- Report untracked output folders by path only.

## Merge / Push Rules

- Prefer fast-forward.
- Stop on conflicts.
- Do not resolve conflicts silently.
- No force push.
- Push only when local checks pass and remote is not divergent.
- Leave repo on the branch requested by the prompt, usually clean `main` for integration checkpoints.

## Artifact Limit

- Repo hygiene artifact max: 80 lines.
- Include verdict, starting/ending branch, commits, status before/after, validation, push result, final hash, and remaining risks.
- Do not paste long logs.

## Validation Commands

- `git status --short --branch`
- `git log --oneline --decorate -n 20`
- `git diff --check`
- `git diff --cached --check`
- `graphify hook-check`
- direct ASCII check on changed docs
- trailing whitespace / CRLF / final-newline checks
- `flutter analyze` only if product/source files changed unexpectedly

## Expected Final Summary

- identity;
- starting branch;
- ending branch;
- commits integrated or checkpointed;
- files changed;
- validation;
- push status;
- final hash;
- output folder status;
- forbidden scope proof;
- next recommendation.
