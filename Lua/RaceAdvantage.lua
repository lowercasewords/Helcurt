--How dark the area has to be to activate his passive
local CONCEAL_SHADOW_DIFFERENCE = 20
--Default time to wait for a single stinger to charge  
local STINGER_CHARGE_TIMER = 5*TICRATE

--[[
COM_AddCommand("la", function(player, lightlevel)
	for sector in sectors.iterate do
       sector.lightlevel = lightlevel
    end
end)

COM_AddCommand("l", function(player, lightlevel)
	local sector = player.mo.subsector.sector 
	sector.lightlevel = lightlevel
end)
]]--

--GLOBAL: Edits the lightlevel requirements for a sector/fof to be considered as dark enough to trigger passive effects
COM_AddCommand("debug_dark", function(player, lightlevel)
	print("Changing Darkness lightlevel requirements from "..CONCEAL_DARKNESS_LEVEL.." to "..lightlevel)
	CONCEAL_DARKNESS_LEVEL = tonumber(lightlevel)
end)


addHook("PlayerThink", function(player)
	if(not Valid(player.mo, "helcurt") or not PAlive(player)) then
		return
	end

	--Recharge stingers over time while concealed
	if(player.mo.unconceal_timer > 0 and player.mo.stingers < MAX_STINGERS) then
		--If less than maxinteger stingers: start the countdown
		if(player.mo.stingers < MAX_STINGERS and player.mo.stinger_charge_countdown <= -1) then
			player.mo.stinger_charge_countdown = STINGER_CHARGE_TIMER
		--Keep counting if the countdown has not ended
		elseif(player.mo.stinger_charge_countdown > 0) then
			player.mo.stinger_charge_countdown = $-1
		--If countdown ended: give a stinger
		elseif(player.mo.stinger_charge_countdown == 0) then
			AddStingers(player.mo, 1)
			player.mo.stinger_charge_countdown = $-1
		end
		
	end
	
end)




addHook("PostThinkFrame", function()
	for player in players.iterate() do
		if(not Valid(player.mo, "helcurt") or not PAlive(player)) then
			return
		end
		local dark_enough = nil
		
		--Try to find a place dark enough to be concealed in
		if(player.mo.subsector ~= nil and player.mo.subsector.sector ~= nil) then
			local sector = player.mo.subsector.sector 

			dark_enough = GetDarkArea(sector, CONCEAL_DARKNESS_LEVEL, player.mo.z)

			--Conceal if possible and not concealed already
			if(dark_enough ~= nil and player.mo.unconceal_timer <= 0) then
				Conceal(player.mo)
			--If time is up on concealment -> Unconceal
			elseif(player.mo.unconceal_timer == 0) then
				Unconceal(player.mo)
			end
		end
		
		--While concealed
		if(player.mo.unconceal_timer >= 0) then
		 	ConcealEffects(player.mo)
			--Counting down the timer to be concealed when not dark enough
			if(dark_enough == nil) then
				player.mo.unconceal_timer = $-1
			end
		end

	end
end)
