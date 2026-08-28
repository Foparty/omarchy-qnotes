#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
local_bin="${HOME}/.local/bin"
hypr_config="${HOME}/.config/hypr"
hyprland_lua="${hypr_config}/hyprland.lua"

echo "omarchy-notes install"
echo "  repo: ${repo_root}"
echo

mkdir -p "${local_bin}" "${hypr_config}"

ln -sf "${repo_root}/bin/omarchy-notes" "${local_bin}/omarchy-notes"
echo "linked: ${local_bin}/omarchy-notes -> ${repo_root}/bin/omarchy-notes"

cat > "${hypr_config}/qnotes.lua" <<EOF
-- Loader for omarchy-notes workspace rules.
dofile("${repo_root}/hypr/qnotes.lua")
EOF
echo "wrote:  ${hypr_config}/qnotes.lua"

cat > "${hypr_config}/notes-bindings.lua" <<EOF
-- Default omarchy-notes keybindings. Override in hypr/bindings.lua.
dofile("${repo_root}/hypr/bindings.example.lua")
EOF
echo "wrote:  ${hypr_config}/notes-bindings.lua"

patch_hyprland_lua() {
  python3 - "${hyprland_lua}" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
block = [
    'require("hypr.qnotes")',
    'require("hypr.notes-bindings")',
]

if not path.exists():
    print(f"skip:   {path} not found — create it and add the require lines manually")
    sys.exit(0)

text = path.read_text()
lines = text.splitlines(keepends=True)

if all(entry in text for entry in block):
    bindings_idx = next((i for i, ln in enumerate(lines) if 'require("hypr.bindings")' in ln), None)
    notes_idx = next((i for i, ln in enumerate(lines) if 'require("hypr.notes-bindings")' in ln), None)
    if bindings_idx is not None and notes_idx is not None and notes_idx > bindings_idx:
        print(f"warn:   {path} loads notes-bindings AFTER bindings — overrides may not work")
        print("        move both require lines above require(\"hypr.bindings\")")
    else:
        print(f"ok:     {path} already has omarchy-notes requires")
    sys.exit(0)

# Drop partial lines so we can insert a clean pair once.
filtered = [ln for ln in lines if not any(entry in ln for entry in block)]
insert_at = next(
    (i for i, ln in enumerate(filtered) if 'require("hypr.bindings")' in ln),
    next((i for i, ln in enumerate(filtered) if 'require("hypr.looknfeel")' in ln), len(filtered)),
)

indent = "  "
for i, ln in enumerate(filtered):
    if ln.strip().startswith("require("):
        indent = ln[: len(ln) - len(ln.lstrip())]
        break

new_lines = (
    filtered[:insert_at]
    + [f"{indent}{entry}\n" for entry in block]
    + filtered[insert_at:]
)
path.write_text("".join(new_lines))
print(f"patched: {path} (inserted omarchy-notes requires before bindings)")
PY
}

patch_hyprland_lua

if command -v hyprctl >/dev/null 2>&1; then
  hyprctl reload 2>/dev/null && echo "reloaded Hyprland" || true
fi

echo
echo "Done. Toggle with your keybind (default SUPER+BACKSPACE)."
echo "Guide: ${repo_root}/README.md"
