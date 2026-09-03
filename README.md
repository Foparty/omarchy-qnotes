# Omarchy-notes (quake style)

Version **0.2.0**.

![preview](/preview.png)

Bottom nvim scratchpad for [Omarchy](https://github.com/basecamp/omarchy) / Hyprland. Quick notes (default `~/notes`) with optional save-on-hide and session resume.

Requires: Omarchy (or Hyprland + `omarchy-launch-tui`), `nvim`, `jq`, `hyprctl`.

## Behavior

- **Toggle** (`omarchy-notes toggle`): open new note / hide (keep nvim alive) / resume in insert mode. Hide can save and/or leave insert mode (see config).
- **Finish** (`omarchy-notes finish`): always save, quit nvim, close panel; next toggle starts a fresh note

Default keys (change in `~/.config/hypr/bindings.lua`): SUPER+' toggle, SUPER+CTRL+' finish.

## Install

```bash
git clone <this-repo> omarchy-notes
cd omarchy-notes
chmod +x install.sh bin/omarchy-notes
./install.sh
```

That copies the app to `~/.local/share/omarchy-notes/`, symlinks the command, writes Hypr loaders, patches `hyprland.lua`, and reloads Hyprland.

The git clone is only for running `install.sh`. After install, nothing in `~/.config/hypr` points at your clone path.

## Trust / audit

Before running `install.sh`, review:

- `bin/omarchy-notes` — bash CLI (toggle / finish / launch)
- `bin/omarchy-notes-config.sh` — config file parser
- `hypr/qnotes.lua` — Hyprland workspace rules and default keybinds

Install copies the app to `~/.local/share/omarchy-notes/` and writes Hypr loaders that point there (never at the git clone path).

## Customize keybindings

In `~/.config/hypr/bindings.lua`:

```lua
hl.unbind("SUPER + APOSTROPHE", "Toggle notes panel")
hl.bind("SUPER + F12", hl.dsp.exec_cmd("omarchy-notes toggle"), {
  description = "Toggle notes panel",
})
```

## Config

Copy `config.example` to `~/.config/omarchy-notes/config` (install never overwrites that file):

```
notes_dir=~/notes
exit_insert_on_hide=true
save_on_hide=true
```

`notes_dir` is where new notes are created. `exit_insert_on_hide` and `save_on_hide` apply to **toggle hide only**. Finish still always writes and quits.

Environment overrides (win over the file): `OMARCHY_NOTES_DIR`, `OMARCHY_NOTES_EXIT_INSERT_ON_HIDE`, `OMARCHY_NOTES_SAVE_ON_HIDE`.

`omarchy-notes print-dir` prints the resolved notes folder.

## Optional bar icon

Copy from `optional/fo.quicknote/` (done by `install.sh`) and:

```bash
omarchy plugin enable fo.quicknote --section right
```

Requires `omarchy-notes` on PATH. The plugin is a launcher only.

## Docs

See `~/Documents/instructions.md` for full architecture and comparison with the agent scratchpad (`qscratchpad.md`).
# omarchy-qnotes
