#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

source_copy_doc="$repo_root/docs/release/store_package_v1.md"
assets_script="$repo_root/tools/store_assets_v1.sh"
assets_dir="$repo_root/out/store_assets/v1"
bundle_dir="$repo_root/out/store_bundle/v1"
bundle_assets_dir="$bundle_dir/assets"
bundle_copy="$bundle_dir/STORE_COPY.md"
bundle_readme="$bundle_dir/README.md"
final_zip="$repo_root/out/store_bundle_v1.zip"

if [[ ! -f "$assets_script" ]]; then
  echo "ERROR: missing required script: tools/store_assets_v1.sh" >&2
  exit 1
fi

if [[ ! -f "$source_copy_doc" ]]; then
  echo "ERROR: missing required doc: docs/release/store_package_v1.md" >&2
  exit 1
fi

if ! command -v zip >/dev/null 2>&1; then
  echo "ERROR: zip is not available on PATH." >&2
  exit 1
fi

cd "$repo_root"

bash "$assets_script"

rm -rf "$bundle_dir"
mkdir -p "$bundle_assets_dir"

copy_section_tmp="$repo_root/out/.store_copy_section_tmp.md"
awk '
/^## App Store Copy SSOT v1$/ {capture=1}
/^## Versioning Rule$/ {if (capture) exit}
capture {print}
' "$source_copy_doc" > "$copy_section_tmp"

if [[ -s "$copy_section_tmp" ]]; then
  {
    echo "# Snapshot: App Store Copy v1"
    echo
    echo "Source: docs/release/store_package_v1.md"
    echo
    cat "$copy_section_tmp"
  } > "$bundle_copy"
else
  {
    echo "# Snapshot: App Store Copy v1"
    echo
    echo "Source: docs/release/store_package_v1.md"
    echo "Note: section extraction fallback used; full SSOT copied."
    echo
    cat "$source_copy_doc"
  } > "$bundle_copy"
fi
rm -f "$copy_section_tmp"

cat > "$bundle_readme" <<'README_EOF'
# Store Bundle v1 Submission Checklist
1. Run: bash tools/store_bundle_v1.sh
2. Open: out/store_bundle/v1/STORE_COPY.md
3. Pick screenshots using Screenshot Selection Checklist v1 order.
4. Confirm caption length is within 30-40 characters.
5. Confirm subtitle/promotional text/description variant selection.
6. Confirm keyword line stays near 100 characters.
7. Upload map/progress screenshots first in store flow.
8. Upload table action screenshots second.
9. Upload reward/progress screenshot(s) last.
10. Submit using out/store_bundle_v1.zip as the artifact pack.
README_EOF

if [[ ! -d "$assets_dir" ]]; then
  echo "ERROR: missing generated assets directory: out/store_assets/v1" >&2
  exit 1
fi

cp -R "$assets_dir"/. "$bundle_assets_dir/"

rm -f "$final_zip"
mapfile -t bundle_files < <(cd "$bundle_dir" && find . -type f | LC_ALL=C sort)
if [[ ${#bundle_files[@]} -eq 0 ]]; then
  echo "ERROR: no files found to package in $bundle_dir" >&2
  exit 1
fi
(cd "$bundle_dir" && zip -X -q "$final_zip" "${bundle_files[@]}")

bundle_file_count=$(find "$bundle_dir" -type f | wc -l | awk '{print $1}')
bundle_size=$(wc -c < "$final_zip" | awk '{print $1}')

if command -v shasum >/dev/null 2>&1; then
  bundle_hash=$(shasum -a 256 "$final_zip" | awk '{print $1}')
else
  bundle_hash="sha256-unavailable"
fi

echo "[store-bundle] generated"
echo "  bundle_dir: $bundle_dir"
echo "  store_copy: $bundle_copy"
echo "  readme: $bundle_readme"
echo "  assets_dir: $bundle_assets_dir"
echo "  final_zip: $final_zip"
echo "  file_count: $bundle_file_count"
echo "  zip_size_bytes: $bundle_size"
echo "  zip_sha256: $bundle_hash"
