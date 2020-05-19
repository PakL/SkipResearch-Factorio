local askagain = true
local skipresearches = false

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

	local skipthistime = false
	local skipthemall = false
	-- Skip a single research?
	if event.element.name == "skipresearch_yes" then
		skipthistime = true
		skipresearches = true
		if game.players[event.player_index].gui.top.skipresearch_tbl.skipresearch_btns.skipresearch_mem.state then
			askagain = false
		end
	-- Skip all researches?
	elseif event.element.name == "skipresearch_all" then
		skipresearches = true
		askagain = false
		skipthistime = true
		skipthemall = true
	-- Don't skip the research?
	elseif event.element.name == "skipresearch_no" then
		skipresearches = false
		if game.players[event.player_index].gui.top.skipresearch_tbl.skipresearch_btns.skipresearch_mem.state then
			askagain = false
		end
	end

	if skipthistime then
		-- Set research progress to 100%
		game.players[event.player_index].force.research_progress = 1
	elseif event.element.name == "skipresearch_no" then
		-- Remove gui
		for i,plyr in pairs(game.players) do
			if plyr.gui.top.skipresearch_tbl ~= nil then
				plyr.gui.top.skipresearch_tbl.destroy()
			end
		end
	end
	if skipthemall then
		-- Skip all researches
		game.players[event.player_index].force.research_all_technologies()
	end
end)

-- Create gui on new research
-- No gui will be created if the gui is not to be shown again
script.on_event(defines.events.on_research_started, function(event)
	if askagain then
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
		local event_research = event.research
		event_research.force.research_progress = 1
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