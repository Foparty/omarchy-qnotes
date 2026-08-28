# omarchy-notes

Bottom nvim scratchpad for [Omarchy](https://github.com/basecamp/omarchy) / Hyprland. Quick notes in `~/notes` with save-on-hide and session resume.

Requires: Omarchy (or Hyprland + `omarchy-launch-tui`), `nvim`, `jq`, `hyprctl`.

## Behavior

- **Toggle** (`omarchy-notes toggle`): open new note / hide (save, keep nvim alive) / resume in insert mode
- **Finish** (`omarchy-notes finish`): save, quit nvim, close panel; next toggle starts a fresh note

Default keys (change in `~/.config/hypr/bindings.lua`): SUPER+BACKSPACE toggle, SUPER+CTRL+BACKSPACE finish.

## Install

```bash
git clone <this-repo> ~/Documents/omarchy-notes
cd ~/Documents/omarchy-notes
chmod +x install.sh bin/omarchy-notes
./install.sh
```

That copies the app to `~/.local/share/omarchy-notes/`, symlinks the command, writes Hypr loaders, patches `hyprland.lua`, and reloads Hyprland.

The git clone is only for running `install.sh`. After install, nothing in `~/.config/hypr` points at your clone path.

## Trust / audit

Before running `install.sh`, review:

- `bin/omarchy-notes` — single bash script (~200 lines)
- `hypr/qnotes.lua` — Hyprland workspace rules and default keybinds (~70 lines)

Install copies the app to `~/.local/share/omarchy-notes/` and writes Hypr loaders that point there (never at the git clone path).

## Customize keybindings

In `~/.config/hypr/bindings.lua`:

```lua
hl.unbind("SUPER + BACKSPACE", "Toggle notes panel")
hl.bind("SUPER + F12", hl.dsp.exec_cmd("omarchy-notes toggle"), {
  description = "Toggle notes panel",
})
```

## Optional bar icon

Copy from `optional/fo.quicknote/` (done by `install.sh`) and:

```bash
omarchy plugin enable fo.quicknote --section right
```

Requires `omarchy-notes` on PATH. The plugin is a launcher only.

## Docs

See `~/Documents/instructions.md` for full architecture and comparison with the agent scratchpad (`qscratchpad.md`).
# omarchy-qnotes
