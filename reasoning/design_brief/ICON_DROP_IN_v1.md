# iOS icon drop-in (B116)
Deliver the owner-approved artwork with rights/provenance as `assets/skin_v1/app_icon.png` (1024 × 1024 PNG, no alpha or transparency).
Use a full square canvas; iOS applies its own corner mask.
From the repository root run: `python3 tools/icon_pack_v1.py` (Pillow, or macOS `sips`).
Verify with `python3 tools/icon_pack_v1.py --check`; replace only the temporary iOS icon, not Android or macOS.
