-- Default keybindings for omarchy-notes.
-- Loaded via ~/.config/hypr/notes-bindings.lua before hypr/bindings.lua.
--
-- Override in ~/.config/hypr/bindings.lua:
--   hl.unbind("SUPER + BACKSPACE", "Toggle notes panel")
--   hl.bind("SUPER + F12", hl.dsp.exec_cmd("omarchy-notes toggle"), {
--     description = "Toggle notes panel",
--   })

hl.unbind(
  "SUPER + BACKSPACE",
  "Toggle window transparency",
  "omarchy-hyprland-window-transparency-toggle"
)
hl.unbind(
  "SUPER + CTRL + BACKSPACE",
  "Toggle single-window square aspect",
  "omarchy-hyprland-window-single-square-aspect-toggle"
)

hl.bind("SUPER + BACKSPACE", hl.dsp.exec_cmd("omarchy-notes toggle"), {
  description = "Toggle notes panel",
})
hl.bind("SUPER + CTRL + BACKSPACE", hl.dsp.exec_cmd("omarchy-notes finish"), {
  description = "Save notes and close session (next open = new note)",
})
