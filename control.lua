local askagain = true
local skipresearches = false

script.on_event(defines.events.on_gui_click, function(event)
	if event.element.name == "skipresearch_yes" then
		skipresearches = true
		game.players[event.player_index].force.research_progress = 1
		if game.players[event.player_index].gui.top.skipresearch_tbl.skipresearch_btns.skipresearch_mem.state then
			askagain = false
		end
	elseif event.element.name == "skipresearch_all" then
		skipresearches = true
		askagain = false
		game.players[event.player_index].force.research_progress = 1
		game.players[event.player_index].force.research_all_technologies()
	elseif event.element.name == "skipresearch_no" then
		skipresearches = false
		if game.players[event.player_index].gui.top.skipresearch_tbl.skipresearch_btns.skipresearch_mem.state then
			askagain = false
		end
	end

	if event.element.name ~= "skipresearch_mem" then
		for i,plyr in pairs(game.players) do
			if not plyr.gui.top.skipresearch_tbl then else plyr.gui.top.skipresearch_tbl.destroy() end
		end
	end
end)

script.on_event(defines.events.on_research_started, function(event)
	if askagain then
		for i,plyr in pairs(game.players) do
			if plyr.gui.top.skipresearch_tbl ~= nil then
				plyr.gui.top.skipresearch_tbl.destroy()
			end
			plyr.gui.top.add{type="table", name="skipresearch_tbl", colspan=1}
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