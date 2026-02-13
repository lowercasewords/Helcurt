--How dark the area has to be to activate his passive
local CONCEAL_SHADOW_DIFFERENCE = 20
--Default time to wait for a single stinger to charge  
local STINGER_CHARGE_TIMER = 5*TICRATE

hud.add(function(v, player, camera)
    -- Check if we are in-game and not in a title screen
    if not (player and player.valid and Valid(player.mo, 'helcurt')) then return end

	if player.mo.unconceal_timer <= 0 then return end

	-- v.fadeScreen(0xFF00, 20)
    local patch = v.cachePatch("VIGNETTE")

	local ratio = FixedDiv(UNCONCEAL_MAX_TICS*FRACUNIT, player.mo.unconceal_timer*FRACUNIT)/FRACUNIT
	
	local trans = min(max(V_10TRANS*ratio, V_10TRANS), V_10TRANS)

	local flags = V_NOSCALESTART|trans
    
	local scale_width = FixedDiv(v.width()*FRACUNIT, patch.width*FRACUNIT) / v.dupx()
    local scale_height = FixedDiv(v.height()*FRACUNIT, (patch.height)*FRACUNIT) / v.dupy()

    v.drawStretched(0, 0, scale_width, scale_height, patch, flags)
end, "game")

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
