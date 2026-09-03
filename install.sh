#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
install_root="${HOME}/.local/share/omarchy-notes"
local_bin="${HOME}/.local/bin"
hypr_config="${HOME}/.config/hypr"
hyprland_lua="${hypr_config}/hyprland.lua"

echo "omarchy-notes install"
echo "  from: ${repo_root}"
echo "  to:   ${install_root}"
echo

mkdir -p "${install_root}" "${local_bin}" "${hypr_config}"

rm -rf "${install_root}/bin" "${install_root}/hypr"
cp -a "${repo_root}/bin" "${repo_root}/hypr" "${install_root}/"
cp -a "${repo_root}/config.example" "${install_root}/config.example"
cp -a "${repo_root}/VERSION" "${install_root}/VERSION"
chmod +x "${install_root}/bin/"omarchy-notes "${install_root}/bin/"omarchy-notes-launch.sh
echo "installed app files -> ${install_root}"

ln -sf "${install_root}/bin/omarchy-notes" "${local_bin}/omarchy-notes"
echo "linked: ${local_bin}/omarchy-notes"

cat > "${hypr_config}/qnotes.lua" <<'EOF'
-- omarchy-notes workspace rules and default keybinds (~/.local/share/omarchy-notes).
dofile((os.getenv("HOME") or "") .. "/.local/share/omarchy-notes/hypr/qnotes.lua")
EOF
echo "wrote:  ${hypr_config}/qnotes.lua"

if [[ -f "${hypr_config}/notes-bindings.lua" ]]; then
  rm -f "${hypr_config}/notes-bindings.lua"
  echo "removed legacy ${hypr_config}/notes-bindings.lua"
fi

patch_hyprland_lua() {
  python3 - "${hyprland_lua}" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
qnotes = 'require("hypr.qnotes")'
legacy = 'require("hypr.notes-bindings")'

if not path.exists():
    print(f"skip:   {path} not found — create it and add {qnotes} before require(\"hypr.bindings\")")
    sys.exit(0)

text = path.read_text()
lines = text.splitlines(keepends=True)

filtered = [ln for ln in lines if legacy not in ln]

if qnotes in text:
    bindings_idx = next((i for i, ln in enumerate(filtered) if 'require("hypr.bindings")' in ln), None)
    qnotes_idx = next((i for i, ln in enumerate(filtered) if qnotes in ln), None)
    if bindings_idx is not None and qnotes_idx is not None and qnotes_idx > bindings_idx:
        print(f"warn:   {path} loads qnotes AFTER bindings — overrides may not work")
        print("        move require(\"hypr.qnotes\") above require(\"hypr.bindings\")")
    elif legacy in text:
        path.write_text("".join(filtered))
        print(f"patched: {path} (removed legacy notes-bindings require)")
    else:
        print(f"ok:     {path} already has {qnotes}")
    sys.exit(0)

insert_at = next(
    (i for i, ln in enumerate(filtered) if 'require("hypr.bindings")' in ln),
    next((i for i, ln in enumerate(filtered) if 'require("hypr.looknfeel")' in ln), len(filtered)),
)

indent = "  "
for ln in filtered:
    if ln.strip().startswith("require("):
        indent = ln[: len(ln) - len(ln.lstrip())]
        break

new_lines = filtered[:insert_at] + [f"{indent}{qnotes}\n"] + filtered[insert_at:]
path.write_text("".join(new_lines))
print(f"patched: {path} (inserted {qnotes} before bindings)")
PY
}

patch_hyprland_lua

if command -v hyprctl >/dev/null 2>&1; then
  hyprctl reload 2>/dev/null && echo "reloaded Hyprland" || true
fi

echo
echo "Done. App lives in ${install_root}"
echo "Hypr loader: ${hypr_config}/qnotes.lua"
echo "Re-run ./install.sh after upgrading the git clone to refresh installed files."
