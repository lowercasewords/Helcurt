--/--------------------------
--/// ShadoeOfStyx.lua
--///
--/// Defines most of Helcurt's passive ability
--/ where ore idea is the transition between 3 states of the passive with
--/ this process: 'Prowler state' -> 'Ambush state' -> 'Exposed state' -> ..repeat step 1..
--///
--/// Note that Helcurt's passive of this addon works quite similarly in the idea
--/ to the original passive in Mobile Legends: Bang Bang.
--/--------------------------


---------------------------------
--/ Global definitions available
--/ outside this file
--------------------------------

--How dark the area has to be to activate his passive
rawset(_G, "CONCEAL_DARKNESS_LEVEL", 200)
rawset(_G, "CONCEAL_ACCELERATION_BOOST", 20)
rawset(_G, "CONCEAL_NORMALSPEED_BOOST",  10*FRACUNIT)
rawset(_G, "CONCEAL_JUMPFACTOR_BOOST",  FRACUNIT/2)

--------------------------
--/ Global variables only 
--/ Seen to this file
--------------------------

local EXPOSED_RUN_FACTOR = 2*FRACUNIT/3
local PROWLER_RUN_FACTOR = 3*FRACUNIT/2
-- Particle related
local MAX_TICS = TICRATE
-- Particle related
local counter = 0

-- State criterias for the passive bar 
-- The given state is active until its (lower) threshold is reached
local PassiveBar = {
	PROWLER_THRESHOLD = 4*TICRATE,
	--Minimum tics to be in ambush mode
	AMBUSH_THRESHOLD = 3*TICRATE,
	--Minimum tics to be in prowler mode
	EXPOSED_THRESHOLD = 3*TICRATE/2,
	MIN_BAR_VALUE = 0
}
-- Current state of Helcurt's passive
local PassiveState = {
	PROWLER = 1,
	AMBUSH = 2,
	EXPOSED = 3
}

--------------------------
--/ Console Commands 
--------------------------

COM_AddCommand("hel_particlecolor", function(player, color)
	if(color == nil or color < 0 or color > 113) then
		print("Incorrect color!")
	else
		print("Setting particle to color"..color)
		player.particlecolor = color
	end
end, COM_LOCAL)

--------------------------
--/ HUD ITEMS 
--------------------------

hud.add(function(v, player, camera)
    -- Check if we are in-game and not in a title screen
    if not (player and player.valid and Valid(player.mo, 'helcurt')) then return end

	if player.passive_state_bar <= 0 then return end

	-- v.fadeScreen(0xFF00, 20)
    local patch = v.cachePatch("VIGNETTE")

	local ratio = FixedDiv(PASSIVE_STATE_BAR_MAX*FRACUNIT, player.passive_state_bar*FRACUNIT)/FRACUNIT
	
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
COM_AddCommand("hel_debug_dark", function(player, lightlevel)
	print("Changing Darkness lightlevel requirements from "..CONCEAL_DARKNESS_LEVEL.." to "..lightlevel)
	if lightlevel ~= nil then
		CONCEAL_DARKNESS_LEVEL = tonumber(lightlevel)
	end

end)

-- Returns the sector which is dark enough for prowler to activate
local function GetDarkArea(sector, dark_level, relative_z)
	local dark_enough = nil
	--Check for overall lightlevel to conceal if dark enough
	if(sector.lightlevel <= dark_level) then
		dark_enough = sector
	--Finds all floor-over-floor to check for lightlevel of shadows under blocks 
	else
		for fof in sector.ffloors() do
			
			--Check for lightlevel under blocks to conceal if dark enough
			--Ignore certain fof's since they trigger conceal when it is not dark enough
			--(standing above water would have triggered this affect)
			if(relative_z < fof.bottomheight and fof.toplightlevel < dark_level and fof.flags&FF_SWIMMABLE == 0) then
				dark_enough = fof
				break
			end
		end
	end

	return dark_enough
end


-- Switches Helcurt to the Prowler State
-- Called once
local function SwitchToProwler(player)
	if not HelcurtAlive(player) then return false end

	local skin = skins[player.skin]

	player.passive_state = PassiveState.PROWLER
	player.passive_state_bar = PassiveBar.PROWLER_THRESHOLD

	S_StartSound(player.cmo, sfx_hide1)
	HelcurtSpeak(player.cmo, sfx_mcon1, sfx_mcon1, FRACUNIT/10)

	--Attribute increase
	-- mo.player.acceleration = $+CONCEAL_ACCELERATION_BOOST
	-- mo.player.normalspeed = $+CONCEAL_NORMALSPEED_BOOST
	-- mo.player.jumpfactor = $+CONCEAL_JUMPFACTOR_BOOST
    player.normalspeed = skin.normalspeed

	return true
end

-- Prowler effects every tic
local function ProwlerEffectThinker(mo)
	if(not S_SoundPlaying(mo, sfx_hide1) and not S_SoundPlaying(mo, sfx_hide2) and not S_SoundPlaying(mo, sfx_hide3)) then
		S_StartSound(mo, sfx_hide2)
	end

	mo.frame = $|FF_TRANS50--|FF_FULLBRIGHT
end

-- Switches Helcurt to the Ambush State
-- Called once
local function SwitchToAmbush(player)
	if not HelcurtAlive(player) then return false end
	local skin = skins[player.skin]

	player.passive_state = PassiveState.AMBUSH
	player.passive_state_bar = PassiveBar.AMBUSH_THRESHOLD

	HelcurtSpeak(player.mo, sfx_munc1, sfx_munc1, FRACUNIT/10)
	S_StopSound(player.mo, sfx_hide1)
	S_StopSound(player.mo, sfx_hide2)
	S_StartSound(player.mo, sfx_hide3)

	-- print("UnConceal!")
	--[[
    mo.player.acceleration = skin.acceleration
    mo.player.normalspeed =  skin.normalspeed
	mo.player.jumpfactor = skin.jumpfactor
	]]--

	return true
end

local function SwitchToExposed(player)
	if not HelcurtAlive(player) then return false end

	player.passive_state = PassiveState.EXPOSED
	player.passive_state_bar = PassiveBar.EXPOSED_THRESHOLD

	local skin = skins[player.skin]
	--player.normalspeed = FixedMul(skin.normalspeed, EXPOSED_RUN_FACTOR)
    player.normalspeed = FixedMul(skin.normalspeed, EXPOSED_RUN_FACTOR)
	
	return true
end

local function PassiveThinker(player)
	if not HelcurtAlive(player) then return false end

	-- If hiden, go to prowler
	-- If left the hidden posiition, ambush
	-- If in ambush position for too long, exposed
	
	-- Checks if helcurt is currently in circumnstances where he is surely hidden
	local is_helcurt_hidden = false

	--[[
	-- Nil checks
	if player.passive_state_bar == nil or player.passive_state == nil then
		SwitchToExposed(player)
		player.passive_state_bar = PassiveBar.EXPOSED_THRESHOLD
		player.passive_state = PassiveState.EXPOSED
	end
	]]--

	--Try to find a sector dark enough to be concealed in
	if(player.mo.subsector ~= nil and player.mo.subsector.sector ~= nil) then
		-- Sector player is currently in which is dark enough to be hidden in.
		-- If not dark enough, the value is nil
		local concealing_sector = GetDarkArea(
												player.mo.subsector.sector, 
												CONCEAL_DARKNESS_LEVEL, 
												player.mo.z
											)
		-- 
		if concealing_sector ~= nil then
			is_helcurt_hidden = true
		end
	end



	-- Switches the passive thinker by monitoring state bar
	local function SwitchPassiveThinker()

		local switched = false	
		
		if player.passive_state == nil then
			if is_helcurt_hidden then
				switched = SwitchToProwler(player)
			else
				switched = SwitchToExposed(player)
			end
		else
			if(is_helcurt_hidden and 
			player.passive_state ~= PassiveState.PROWLER and
			player.passive_state_bar < PassiveBar.PROWLER_THRESHOLD) then
				switched = SwitchToProwler(player)
			elseif(player.passive_state == PassiveState.PROWLER
			and player.passive_state_bar < PassiveBar.AMBUSH_THRESHOLD) then
				switched = SwitchToAmbush(player)
			elseif(player.passive_state == PassiveState.AMBUSH and
			player.passive_state_bar < PassiveBar.EXPOSED_THRESHOLD) then
				switched = SwitchToExposed(player)
			end
		end
		return switched
	end	

	-- Was the state switched this tic?
	local has_switched_state = SwitchPassiveThinker()

	-- Deplete the bar if not hidden
	if not is_helcurt_hidden and player.passive_state_bar > PassiveBar.MIN_BAR_VALUE then
		player.passive_state_bar = $-1
	end

	-- Passive state thinker
	if player.passive_state == PassiveState.PROWLER then
		ProwlerEffectThinker(player.mo)
	elseif player.passive_state == PassiveState.AMBUSH then
		-- ...
	elseif player.passive_state == PassiveState.EXPOSED then
		-- ...
	end

	return true
end



addHook("PlayerThink", function(player)
-- 	if(player.valid and player.mo and player.mo.valid and player.mo.skin and player.mo.skin.valid
-- 	and player.mo.skin == "helcurt")
	if not HelcurtAlive(player) then return nil end 
	
	--Concealment particles
	if(player.passive_state_bar > 0) then
		local particle = P_SpawnMobj(player.mo.x+P_RandomRange(SPAWN_RADIUS_MAX, -SPAWN_RADIUS_MAX)*FRACUNIT, 
									player.mo.y+P_RandomRange(SPAWN_RADIUS_MAX, -SPAWN_RADIUS_MAX)*FRACUNIT,  
									player.mo.z+P_RandomRange(0, player.mo.height/(2*FRACUNIT))*FRACUNIT,
									MT_SHDW)
		particle.color = player.mo.color--particlecolor
		particle.momx = player.mo.momx/2
		particle.momy = player.mo.momy/2
		P_SetObjectMomZ(particle, FRACUNIT/2, false)
	end

	if(counter <= 0) then
		counter = MAX_TICS
		searchBlockmap("lines", function(playmo, line)
			
			for i = 0, 1, 1 do
				local area = nil
				if(i == 0) then
				--Checks if the area is dark, retrieves either a fof or sector
					area = GetDarkArea(line.frontsector, CONCEAL_DARKNESS_LEVEL, line.frontsector.floorheight)
				elseif(line.backsector ~= nil) then
					area = GetDarkArea(line.backsector, CONCEAL_DARKNESS_LEVEL, line.backsector.floorheight)
				end

				--If dark area (either sector or fof was found)
				if(area ~= nil) then
					local linesarr = nil
					local bottom = nil
					local top = nil

					if(area.bottomheight ~= nil) then --If a FOF (floor over floor)
						linesarr = area.target.lines
						bottom = area.target.floorheight
						top = area.bottomheight
					else -- if a sector
						linesarr = area.lines
						bottom = area.floorheight
						top = area.ceilingheight
					end

						--Spawning behavior (chooses between current and random line of the sector)
						if(linesarr ~= nil and #linesarr >= 3) then

							local l1 = line --CAN'T THE FIRST LINE BE THE LINE IN THE BLOCKMAP FUNCTINO???
							local l2 = linesarr[P_RandomRange(0, #linesarr-1)]

							local x = P_RandomRange(l1.v1.x/FRACUNIT, l2.v1.x/FRACUNIT)*FRACUNIT
							local y = P_RandomRange(l1.v1.y/FRACUNIT, l2.v1.y/FRACUNIT)*FRACUNIT

							local subsector = R_PointInSubsectorOrNil(x, y)


							if(subsector ~= nil and subsector.sector ~= nil and ((subsector.sector == area) or (area.target ~= nil and subsector.sector == area.target))) then
								--Spawn with immediate state change (look in the end of the line I hope it's not changed in the end bc I would look dumb)
								P_SpawnMobj(x, y, P_RandomRange(bottom/FRACUNIT, top/FRACUNIT)*FRACUNIT, MT_SHDW).state = S_SHDW_HINT
								P_SpawnMobj(x, y, P_RandomRange(bottom/FRACUNIT, top/FRACUNIT)*FRACUNIT, MT_SHDW).state = S_SHDW_HINT
							end
							
						end

						return false
					
				end

				area = nil
			end
		end, 
		player.mo, 
		player.mo.x-2000*FRACUNIT, 
		player.mo.x+2000*FRACUNIT, 
		player.mo.y-2000*FRACUNIT, 
		player.mo.y+2000*FRACUNIT)
			
		else 
			counter = $ - 1
	end
end)

addHook("PostThinkFrame", function()
	for player in players.iterate() do
		PassiveThinker(player)
	end
end)
