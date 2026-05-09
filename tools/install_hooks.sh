#!/usr/bin/env bash
set -euo pipefail

HOOKS_DIR=".git/hooks"
mkdir -p "$HOOKS_DIR"

cat > "$HOOKS_DIR/pre-commit" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [ -x tools/guard_stray_dirs.sh ]; then
  tools/guard_stray_dirs.sh
fi
EOF

chmod +x "$HOOKS_DIR/pre-commit"

# Ensure guard script is executable for local runs
chmod +x tools/guard_stray_dirs.sh

echo "Git hooks installed."

