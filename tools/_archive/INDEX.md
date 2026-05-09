# tools/_archive Index

Bucket type: `DEPRECATED`

Purpose:
- Store low-risk legacy tooling scripts that are not part of current `tools/` SSOT workflows.
- Keep them for traceability and possible manual recovery without cluttering active tool roots.

Current tooling SSOT:
- `tools/README.md`
- `tools/TOOLS_INDEX.md`

Archived scripts (batch 1)
- `tools/_archive/check_head_refs.sh` — legacy git head/ref hidden-character checker. Replacement: none (archived helper).
- `tools/_archive/copy_pack_release.dart` — legacy pack release copy helper. Replacement: use current release/packaging flow docs + maintained `tools/*` scripts.
- `tools/_archive/fix_core_imports.sh` — one-off import rewrite helper. Replacement: none (archived helper).
- `tools/_archive/fix_ui_safe_patterns.sh` — one-off UI pattern rewrite helper. Replacement: none (archived helper).
- `tools/_archive/rebase_autofix.sh` — local conflict autofix helper. Replacement: none (archived helper).
- `tools/_archive/smoke_generate_l2.dart` — legacy L2 generation smoke helper. Replacement: current `tools/` production pipeline scripts.
- `tools/_archive/test_all.sh` — legacy local test wrapper. Replacement: current policy scripts in `tools/` (for example release/fast loops).
- `tools/_archive/verify_pack.dart` — one-off pack verification helper. Replacement: current pack validation/export tooling in `tool/`/`tools/` as documented.
