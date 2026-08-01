# Visual Control Center Sites Update v1

The local Atlas is canonical engineering evidence. ChatGPT Sites, when
available, is only a private versioned mirror and never the product or design
SSOT.

## Rebuild and validate

From the repository root:

```bash
./tools/serve_visual_control_center_v1.sh
```

Open `http://127.0.0.1:4173`, check the evidence and tooling baselines in the
header, then stop the server with Ctrl-C. The generated `output/` bundle is
local-only and must not be committed.

The canonical local evidence input is
`output/visual_control_center/evidence/current/`. To use a different prepared
local evidence set, pass `--evidence=<path>`; `--no-watch` disables polling and
`--port=<port>` changes the local port. The wrapper runs typed discovery and
rebuilds before serving, then polls the registry, discovery tool, and evidence
input for changes. Each rebuild updates `site_version.json` for browser reload.

The rebuild also writes the upload-ready local review package at
`output/visual_control_center/current/review_export/SHARKY_VISUAL_REVIEW_PACK_V1.zip`.
It contains only explicitly mapped full-resolution representatives; uncovered
states remain explicit missing records rather than receiving filename fallback.

## Mirror lifecycle

After a locally accepted visual delta, regenerate evidence, rebuild this
bundle, review the changed states, then update `site_version.json` through the
generator. Preview the new snapshot before deploying it to the same private
Site. Confirm its access remains owner-only (or the narrowest private setting)
and record the version identifier.

The header's evidence baseline and tooling baseline identify a stale mirror:
either differs from the accepted local snapshot. Sites never receives updates
automatically. To take a mirror down, use the Site owner's unpublish/delete
control; this does not remove the canonical local Atlas.
