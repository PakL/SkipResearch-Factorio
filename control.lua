local skipresearches = false
local skipthistime = false
local skipstartclock = 0
local skipresearch_research = nil

-- Handle GUI click events
script.on_event(defines.events.on_gui_click, function(event)
	-- Check if research is even running
	-- Remove GUI to make sure
	if game.players[event.player_index].force.current_research == nil then
		if game.players[event.player_index].gui.top.skipresearch_tbl ~= nil then
			game.players[event.player_index].gui.top.skipresearch_tbl.destroy()
		end
		return
	end

	if event.element.name == "skipresearch_mem" then
		return
	end

	local skipthemall = false
	-- Skip a single research?
	if event.element.name == "skipresearch_yes" then
		skipthistime = true
		skipresearches = true
		if game.players[event.player_index].gui.top.skipresearch_tbl.skipresearch_btns.skipresearch_mem.state then
			settings.global["skip-research-askagain"] = {value = false}
			askagain = false
		end
	-- Skip all researches?
	elseif event.element.name == "skipresearch_all" then
		skipresearches = true
		settings.global["skip-research-askagain"] = {value = false}
		skipthistime = false
		skipthemall = true
	-- Don't skip the research?
	elseif event.element.name == "skipresearch_no" then
		skipresearches = false
		if game.players[event.player_index].gui.top.skipresearch_tbl.skipresearch_btns.skipresearch_mem.state then
			settings.global["skip-research-askagain"] = {value = false}
		end
	end

	-- Remove gui
	for i,plyr in pairs(game.players) do
		if plyr.gui.top.skipresearch_tbl ~= nil then
			plyr.gui.top.skipresearch_tbl.destroy()
		end
	end

	if skipthistime then
		-- Set research progress to 100%
		skipstartclock = game.ticks_played
	end
	if skipthemall then
		skipresearch_research = nil
		-- Skip all researches
		game.players[event.player_index].force.research_all_technologies()
	end
end)

-- Create gui on new research
-- No gui will be created if the gui is not to be shown again
script.on_event(defines.events.on_research_started, function(event)
	skipresearch_research = event.research
	if settings.global["skip-research-askagain"].value then
		for i,plyr in pairs(game.players) do
			if plyr.gui.top.skipresearch_tbl ~= nil then
				plyr.gui.top.skipresearch_tbl.destroy()
			end
			plyr.gui.top.add{type="table", name="skipresearch_tbl", column_count=1}
			plyr.gui.top.skipresearch_tbl.add{type="label", name="skipresearch_lbl", caption={"skip-research-label"}}
			plyr.gui.top.skipresearch_tbl.add{type="flow", name="skipresearch_btns"}
			plyr.gui.top.skipresearch_tbl.skipresearch_btns.add{type="button", name="skipresearch_yes", caption={"skip-research-yes"}}
			plyr.gui.top.skipresearch_tbl.skipresearch_btns.add{type="button", name="skipresearch_no", caption={"skip-research-no"}}
			plyr.gui.top.skipresearch_tbl.skipresearch_btns.add{type="checkbox", name="skipresearch_mem", caption={"skip-research-mem"}, state=false}
			plyr.gui.top.skipresearch_tbl.add{type="button", name="skipresearch_all", caption={"skip-research-all"}}
		end
	elseif skipresearches then
		skipthistime = true
		skipstartclock = game.ticks_played
	end
end)

-- Remove gui for all players if research is finished
script.on_event(defines.events.on_research_finished, function(event)
	for i,plyr in pairs(game.players) do
		if plyr.gui.top.skipresearch_tbl ~= nil then
			plyr.gui.top.skipresearch_tbl.destroy()
		end
	end
end)

-- Update research progress
script.on_event(defines.events.on_tick, function(event)
	if skipthistime and skipresearch_research ~= nil then
		if skipresearch_research.researched then
			skipthistime = false
			skipresearch_research = nil
			return
		end

		local now = game.ticks_played * game.speed / 60
		local sthen = skipstartclock * game.speed / 60
		local diff = now - sthen
		if diff >= settings.global["skip-research-timeout"].value then
			skipresearch_research.force.research_progress = 1
			skipthistime = false
			skipresearch_research = nil
		else
			local progress = 1 / settings.global["skip-research-timeout"].value * diff
			if progress < 1 then
				skipresearch_research.force.research_progress = progress
			end
		end
	end
end)