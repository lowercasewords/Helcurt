
--How dark the area has to be to activate his passive
rawset(_G, "CONCEAL_DARKNESS_LEVEL", 200)
rawset(_G, "CONCEAL_ACCELERATION_BOOST", 20)
rawset(_G, "CONCEAL_NORMALSPEED_BOOST",  10*FRACUNIT)
rawset(_G, "CONCEAL_JUMPFACTOR_BOOST",  FRACUNIT/2)
--Maximum tics for a player's passive to be active after the player exited the dark area
rawset(_G, "PROWLER_STATE_BAR_MAX", 3*TICRATE)

local EXPOSED_RUN_FACTOR = 2*FRACUNIT/3  
local PROWLER_RUN_FACTOR = 3*FRACUNIT/2

hud.add(function(v, player, camera)
    -- Check if we are in-game and not in a title screen
    if not (player and player.valid and Valid(player.mo, 'helcurt')) then return end

	if player.mo.prowler_state_bar <= 0 then return end

	-- v.fadeScreen(0xFF00, 20)
    local patch = v.cachePatch("VIGNETTE")

	local ratio = FixedDiv(PROWLER_STATE_BAR_MAX*FRACUNIT, player.mo.prowler_state_bar*FRACUNIT)/FRACUNIT
	
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
end

end)

--Conceals the player in the darkness (called once)
rawset(_G, "Conceal", function(mo)
	if(not Valid(mo)) then
		return nil
	end

	mo.prowler_state_bar = PROWLER_STATE_BAR_MAX

	S_StartSound(mo, sfx_hide1)
	HelcurtSpeak(mo, sfx_mcon1, sfx_mcon1, FRACUNIT/10)

	--Attribute increase
	-- mo.player.acceleration = $+CONCEAL_ACCELERATION_BOOST
	-- mo.player.normalspeed = $+CONCEAL_NORMALSPEED_BOOST
	-- mo.player.jumpfactor = $+CONCEAL_JUMPFACTOR_BOOST
	local skin = skins[mo.player.skin]
    mo.player.normalspeed = skin.normalspeed

end)

--Conceal effects to be put every tic 
rawset(_G, "ConcealEffects", function(mo)
	if(not S_SoundPlaying(mo, sfx_hide1) and not S_SoundPlaying(mo, sfx_hide2) and not S_SoundPlaying(mo, sfx_hide3)) then
		S_StartSound(mo, sfx_hide2)
	end

	mo.frame = $|FF_TRANS50--|FF_FULLBRIGHT
end)

--Stops concealing the player in the darkness (called once)
rawset(_G, "Unconceal", function(mo)
	if(not Valid(mo)) then
		return nil
	end
	local skin = skins[mo.player.skin]

	if(Valid(mo, "helcurt")) then
		HelcurtSpeak(mo, sfx_munc1, sfx_munc1, FRACUNIT/10)
	end

	S_StopSound(mo, sfx_hide1)
	S_StopSound(mo, sfx_hide2)
	S_StartSound(mo, sfx_hide3)

	-- print("UnConceal!")
--[[
    mo.player.acceleration = skin.acceleration
    mo.player.normalspeed =  skin.normalspeed
	mo.player.jumpfactor = skin.jumpfactor
]]--
end)


local function OnProwlerExposed(player)
	local skin = skins[player.skin]
--player.normalspeed = FixedMul(skin.normalspeed, EXPOSED_RUN_FACTOR)
	player.normalspeed = FixedMul(skin.normalspeed, EXPOSED_RUN_FACTOR)
end

addHook("PlayerThink", function(p)
	if(not Valid(p.mo, "helcurt") or not PAlive(p)) then return false end

	local pb = p.mo.prowler_state_bar
	if pb == -1 then
		OnProwlerExposed(p)
	end

	-- print("prowler bar: "..pb)
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
			if(dark_enough ~= nil and player.mo.prowler_state_bar <= 0) then
				Conceal(player.mo)
			--If time is up on concealment -> Unconceal
			elseif(player.mo.prowler_state_bar == 0) then
				Unconceal(player.mo)
			end
		end
		
		--While concealed
		if(player.mo.prowler_state_bar >= 0) then
		 	ConcealEffects(player.mo)
			--Counting down the timer to be concealed when not dark enough
			if(dark_enough == nil) then
				player.mo.prowler_state_bar = $-1
			end
		end

	end
end)
