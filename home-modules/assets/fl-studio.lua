-- Wine must not re-enter fullscreen after the compositor toggles it off.
-- Match only the main window, not the untitled owner, menus, or plugins.
hl.window_rule({
	name = "fl-studio-main-fullscreen",
	match = {
		class = "^fl64[.]exe$",
		initial_title = "^(.* - )?FL Studio( [0-9]+)?$",
		xwayland = true,
	},
	-- Wine advertises a fixed-size main window, which otherwise auto-floats.
	tile = true,
	suppress_event = "fullscreen maximize",
	scrolling_width = 1.0,
})

-- FL menus are untitled too: only the blank 800x800 Wine owner is hidden.
local function is_fl_studio_owner(window)
	return window and window.class == "fl64.exe" and window.xwayland
		and window.floating and window.initial_title == "" and window.title == ""
		and window.size.x == 800 and window.size.y == 800
end

local function hide_fl_studio_owner(window)
	if is_fl_studio_owner(window) then
		hl.dispatch(hl.dsp.window.move({
			window = window,
			workspace = "special:fl-studio-helper",
			follow = false,
		}))
	end
end

-- Launchers can select the owner because it shares FL's application class.
local function focus_fl_studio_main(owner)
	if not is_fl_studio_owner(owner) then
		return
	end
	local pid = owner.pid
	-- Wait until the launcher finishes opening the owner's special workspace.
	hl.timer(function()
		local active = hl.get_active_window()
		if not is_fl_studio_owner(active) or active.pid ~= pid then
			return
		end
		for _, window in ipairs(hl.get_windows()) do
			if window.class == "fl64.exe" and window.pid == pid
				and window.title:match("FL Studio %d+$") then
				hl.dispatch(hl.dsp.focus({ window = window }))
				return
			end
		end
	end, { timeout = 1, type = "oneshot" })
end

hl.on("window.open", hide_fl_studio_owner)
hl.on("window.active", focus_fl_studio_main)
for _, window in ipairs(hl.get_windows()) do
	hide_fl_studio_owner(window)
end
