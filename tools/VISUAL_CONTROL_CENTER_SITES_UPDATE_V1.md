# Visual Control Center Sites Update v1

The local Atlas is canonical engineering evidence. ChatGPT Sites, when
available, is only a private versioned mirror and never the product or design
SSOT.

## Rebuild and validate

From the repository root:

```bash
dart run tools/act0_visual_state_discovery_v1.dart --output=output/visual_control_center/current/runtime_discovery.json
python3 tools/build_visual_control_center_v1.py --discovery=output/visual_control_center/current/runtime_discovery.json
./tools/serve_visual_control_center_v1.sh
```

Open `http://127.0.0.1:4173`, check the evidence and tooling baselines in the
header, then stop the server with Ctrl-C. The generated `output/` bundle is
local-only and must not be committed.

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
