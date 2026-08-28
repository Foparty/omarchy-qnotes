-- Bottom notes scratchpad: nvim in ~/notes on special:notes.
-- Mirrors qconsole.lua (agent / SUPER+grave) but anchored to the bottom.

local share = 0.45
local seed = "[workspace special:notes silent] omarchy-notes launch"

local covering = nil

local function cover(top)
  if covering == top then
    return
  end
  covering = top

  hl.workspace_rule({
    workspace = "special:notes",
    gaps_in = 0,
    gaps_out = { top = top, right = 0, bottom = 0, left = 0 },
    no_border = true,
    on_created_empty = seed,
  })
end

local function fit()
  local monitor = hl.get_active_monitor()
  if not monitor or not monitor.scale or monitor.scale <= 0 then
    return
  end

  local reserved = monitor.reserved
  local usable = monitor.height / monitor.scale - reserved.top - reserved.bottom

  cover(math.max(0, math.floor(usable * (1 - share))))
end

cover(0)
fit()

hl.on("monitor.layout_changed", fit)
hl.on("monitor.focused", fit)

-- specialWorkspaceIn/Out are swapped by omarchy-notes before each toggle, then
-- restored for the agent scratchpad (SUPER+grave).

-- Default keybindings. Override in ~/.config/hypr/bindings.lua (loaded after this file):
--   hl.unbind("SUPER + APOSTROPHE", "Toggle notes panel")
--   hl.bind("SUPER + F12", hl.dsp.exec_cmd("omarchy-notes toggle"), {
--     description = "Toggle notes panel",
--   })

hl.bind("SUPER + APOSTROPHE", hl.dsp.exec_cmd("omarchy-notes toggle"), {
  description = "Toggle notes panel",
})
hl.bind("SUPER + CTRL + APOSTROPHE", hl.dsp.exec_cmd("omarchy-notes finish"), {
  description = "Save notes and close session (next open = new note)",
})
