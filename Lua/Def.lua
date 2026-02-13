--/--------------------------
--/ 
--/ Defines freeslots, actions, and hooks that have to run BEFORE anyhing else.
--/ Make sure the index of the file is set to 0 before other files
--/ 
--/ SIDENOTE: Mod is not designed for Helcurt to be a bot, at least not yet. It still can be one 
--/ but don't expect anything fancy!
--/
--/--------------------------

--Most player and object sprites
freeslot("S_PRE_TRANSITION", "S_START_TRANSITION", "S_IN_TRANSITION", "S_END_TRANSITION", "S_TRNS", "S_LOCK", "S_FOLLOW",
"S_NIGHT_CHARGE", "S_NIGHT_ACTIVATE", "S_EYES_1", "S_EYES_2", "S_NGHT_1", "S_NGHT_2")

--Most objects
freeslot("MT_LOCK", "MT_TRNS", "MT_FOLLOW", "MT_EYES")

--most player and object sprites
freeslot("SPR_LOCK", "SPR_TRNS", "SPR_NGHT")

--Sound effects
freeslot(
	"sfx_blde1",
	"sfx_trns1", "sfx_trns2", 
	"sfx_nght1", "sfx_nght2", "sfx_nght3", 
	"sfx_upg01", "sfx_upg02", "sfx_upg03", "sfx_upg04", 
	"sfx_stg01", "sfx_stg02", "sfx_stg03", "sfx_stg04", "sfx_stg05",
	"sfx_hide1", "sfx_hide2", "sfx_hide3")

--Monologues
freeslot(
	"sfx_mrwn1", "sfx_mrwn2", 
	"sfx_mdth1", "sfx_mdth2",
	"sfx_mbos1", "sfx_mbos2",
		"sfx_mcon1", 
		"sfx_munc1",
	"sfx_mstg1",
	"sfx_mtlp1",
	"sfx_mnht1", "sfx_mnht2", "sfx_mnht3",
	"sfx_mgrn1", "sfx_mgrn2", "sfx_mgrn3", "sfx_mgrn4", "sfx_mgrn5", 
	"sfx_mkil1", "sfx_mkil2", "sfx_mkil3", "sfx_mkil4",
	"sfx_mnl01", "sfx_mnl02", "sfx_mnl03")

--Particle slots
freeslot("MT_SHDW", "SPR_SHDW", "S_SHDW_PRT", "S_SHDW_HINT")

--constants and functions used throghout the project (rest are defined in other files too)
rawset(_G, "SPAWN_RADIUS_MAX", 10)
--Anything below or equal to this tics counts as pressing a button once instead of holding it
rawset(_G, "TICS_PRESS_RANGE", 5)
rawset(_G, "SPAWN_TIC_MAX", 1)
--Custom objects
rawset(_G, "STYX_EYES_SCALE", FRACUNIT*6)

--A maximum tic value for a monologue timer, actualr timer 
--could possible be set to lover value based on this maximum constant
rawset(_G, "MONOLOGUE_TIC_MAX", TICRATE*40)
rawset(_G, "MONOLOGUE_START_SOUND", sfx_mrwn1)
rawset(_G, "MONOLOGUE_END_SOUND", sfx_mnl03)

rawset(_G, "TARGET_DMG_RANGE", MF_SHOOTABLE|MF_ENEMY|MF_BOSS|MF_MONITOR)--|MF_MONITOR|MF_SPRING)
rawset(_G, "TARGET_NONDMG_RANGE", MF_SPRING)
-- rawset(_G, "TARGET_KILL_RANGE", MT_POINTYBALL|MT_EGGMOBILE_BALL|MT_SPIKEBALL|MT_SPIKE|MT_WALLSPIKE|MT_WALLSPIKEBASE|MT_SMASHINGSPIKEBALL)
rawset(_G, "TARGET_IGNORE_RANGE", MF_MISSILE)

rawset(_G, "TELEPORT_SPEED", 70*FRACUNIT)
rawset(_G, "TELEPORT_STOP_SPEED", 3)

--Duration of the night
rawset(_G, "NIGHT_MAX_TIC", 5*TICRATE)
rawset(_G, "NIGHT_SKYBOX", 6)
rawset(_G, "NIGHT_LIGHT_MULTIPLYER", 3/4)


--Checks whether the mobject is valid and (optionally) has the correct skin 
rawset(_G, "Valid", function(mo, skin)
	
	local isvalid =  mo ~= nil and mo.valid == true and mo.state ~= S_NULL --and mo.state ~= states[mo.state].deathstate
	if(isvalid and skin == nil) then -- In case the skin value was not supplied
		skin = mo.skin
	end
	return isvalid and mo.skin == skin
end)

--Checks if the player is alive (not dead nor just respawned)
rawset(_G, "PAlive", function(p)
	return p ~= nil and p.playerstate == PST_LIVE
end)

-- Combines checking whether the player is alive, player is valid, and skin is correct
rawset(_G, "HelcurtAlive", function(player)
	return Valid(player.mo, 'helcurt') and PAlive(player)
end)

--Randomly starts a random sound in range
--mo is the origin object
--a random sound is played between start_sound and end_sound (inclusive)
--chance number is between 0 and FRACUNIT, being a chance to play the sound
--Returns the sound that was chosen to play, doesn't mean it 100% was played. Returns nil if nothing was chosen
rawset(_G, "TrySoundInRange", function(mo, start_sound, end_sound, chance)
	
	--If the origin object is valid and sound is determined to play by chance
	if(not Valid(mo) and chance ~= nil and not P_RandomChance(chance))then
		return nil
	end

	--In case that end_sound is not supplied
	if(end_sound == nil) then
		end_sound = start_sound
	end
	
	--[[
	--If the sound in range is already playing
	for i = start_sound, end_sound, 1 do
		if(S_SoundPlaying(mo, i)) then
			S_StopSoundByID(mo, i)
		end
	end
	]]--

	local sound = P_RandomRange(start_sound, end_sound) 
	S_StartSound(mo, sound)

	return sound
end)


rawset(_G, "StopSoundsRange", function(mo, start_sound, end_sound, ignore_start, ignore_end) 
	if(not Valid(mo))then
		return false
	end

	local wasStopped = false

	--In case one or two of ignore sounds are not supplied
	if(ignore_start == nil or ignore_end == nil) then
		ignore_start = -1
		ignore_end = -1
	end

	--If the sound in range is already playing
	for i = start_sound, end_sound, 1 do
		if(S_SoundPlaying(mo, i) and 
		(i < ignore_start or i > ignore_end)) then
			S_StopSoundByID(mo, i)
			wasStopped = true
		end
	end

	return wasStopped
end)

rawset(_G, "IsSoundPlayingRange", function(mo, start_sound, end_sound, ignore_start, ignore_end) 
	if(not Valid(mo))then
		
		return false
	end

	--In case one or two of ignore sounds are not supplied
	if(ignore_start == nil or ignore_end == nil) then
		ignore_start = -1
		ignore_end = -1
	end

	--If the sound in range is already playing
	for i = start_sound, end_sound, 1 do
		if(S_SoundPlaying(mo, i) and (i < ignore_start or i > ignore_end)) then
			return true
		end
	end

	return false
end)


--Immediately interrupts all monologue sounds in favor of desired monologue
rawset(_G, "HelcurtSpeakOverride", function(mo, start_sound, end_sound, chance) 
	if(not Valid(mo))then
		return nil
	end

	StopSoundsRange(mo, MONOLOGUE_START_SOUND, MONOLOGUE_END_SOUND)

	--Reset the random monologue timer
	if(mo.player ~= nil) then
		mo.player.monologue_timer = MONOLOGUE_TIC_MAX
	end

	local monologue = TrySoundInRange(mo, start_sound, end_sound, chance)

	return monologue
end)

--Says something without interruption
rawset(_G, "HelcurtSpeak", function(mo, start_sound, end_sound, chance) 
	if(not Valid(mo) or IsSoundPlayingRange(mo, MONOLOGUE_START_SOUND, MONOLOGUE_END_SOUND))then
		return nil
	end
		
	local monologue = TrySoundInRange(mo, start_sound, end_sound, chance)

	return monologue
end)

rawset(_G, "GetDarkArea", function(sector, dark_level, relative_z)
	local dark_enough = nil
	--Check for overall lightlevel to conceal if dark enough
	-- print("S: "..sector.lightlevel)
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
			-- print("F	: "..fof.toplightlevel)
		end
	end

	return dark_enough
end)

rawset(_G, "StartHelcurtNightBuff", function(originplayer)
    if(not Valid(originplayer.mo, "helcurt") or not PAlive(originplayer)) then
        return nil
    end
 end)

rawset(_G, "EndHelcurtNightBuff", function(originplayer)
    if(not Valid(originplayer.mo, "helcurt") or not PAlive(originplayer)) then
        return nil
    end
end)

rawset(_G, "StartTheNight", function(originplayer) 
    if(not Valid(originplayer.mo, "helcurt")) then
        return nil
    end

    StartHelcurtNightBuff(originplayer)
    
    --Changes the background for the Night Fall
    P_SetupLevelSky(NIGHT_SKYBOX)
    P_SetSkyboxMobj(nil)  
    -- P_SwitchWeather(PRECIP_STORM)

    --Starting the monologue and night sound
	HelcurtSpeakOverride(originplayer.mo, sfx_mnht1, sfx_mnht3)
	S_StartSound(originplayer.mo, sfx_nght1)

    --Fading the background music
    S_FadeMusic(50, 20)
    -- S_SpeedMusic(FRACUNIT/2)
    
    --Make each sector of the map darker
    for sector in sectors.iterate do
        -- sector.oglightlevel = 0
        -- sector.oglightlevel = sector.lightlevel
        -- P_FadeLight(sector.tag, sector.lightlevel - sector.lightlevel/NIGHT_LIGHT_MULTIPLYER, 3)
       sector.lightlevel = $*3/4
    end
end)

--Call this function ONLY IF THE NIGHT ABILITY IS ON, 
rawset(_G, "EndTheNight", function(originplayer, skybox, skynum)
    if(not Valid(originplayer.mo, "helcurt")) then
        return nil
    end

    EndHelcurtNightBuff(originplayer)

   --Changes the background back to the OG (OriGinal)
   P_SetupLevelSky(skynum)
   -- P_SwitchWeather(current_mapinfo.weather)
   if(originplayer.og_skybox.valid and originplayer.og_skybox ~= nil) then
       P_SetSkyboxMobj(skybox)
   end

   --Wrapping-up the night sound and bringing back original level sounds
   S_FadeMusic(100, 20)
   S_StopSoundByID(originplayer.mo, sfx_nght2)
   S_StartSound(originplayer.mo, sfx_nght3)
   S_SpeedMusic(FRACUNIT)
   
   for sector in sectors.iterate do
       -- P_FadeLight(sector.tag, -sector.lightlevel/2, 20)
       -- sector.lightlevel = sector.oglightlevel
       sector.lightlevel = $*4/3
   end
end)

--mo is an object to make an after image of 
--trans is the translucency frame flag
rawset(_G, "SpawnAfterImage", function(mo, trans)
	if(not Valid(mo)) then
		return false
	end
-- 	print("Spawning image")
	local image = P_SpawnGhostMobj(mo) -- P_SpawnMobj(mo.x, mo.y, mo.z, mo.type)
	image.state = mo.state
	if(trans ~= nil) then
		image.frame = trans
	end
	image.momx = 0
	image.momy = 0
	image.momz = 0
-- 	image.sprite = mo.sprite
-- 	image.frame = mo.frame
-- 	print(image.state)
-- 	image.flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_NOGRAVITY
end)

--Spawns a mobject of specified type relative to existing mobject position and angle (facing that angle)
--mobj (mobj_t): the existing object which position and angle is used to spawn a new one
--x (int): non-fracunit relative x-axis offset
--y (int): non-fracunit relative y-axis offset
--z (int): non-fracunit relative z-axis offset
--mtype (int): the type of spawned object
--returns: spawned object
rawset(_G, "RelativeSpawn", function(mobj, mtype, x, y, z, angle)
	--Formula of two-dimansional rotation of the point
	--was taken from here: https:--danceswithcode.net/engineeringnotes/rotations_in_2d/rotations_in_2d.html
	local xspawn = (mobj.x - mobj.x+x) * cos(mobj.angle) - (mobj.y - mobj.y+y) * sin(mobj.angle) + mobj.x+x
	local yspawn = (mobj.x - mobj.x+x) * sin(mobj.angle) + (mobj.y - mobj.y+y) * cos(mobj.angle) + mobj.y+y
	local zspawn = mobj.z + z
	local obj = P_SpawnMobj(xspawn, yspawn, zspawn, mtype)
	obj.angle = angle
	return obj
end)

--Formula for creating a mobject relative at a certain angle and distance from the og (origin) object
--x (FRACUNIT): x-coordinate of origin object
--y (FRACUNIT): y-coordinate of origin object
--z (FRACUNIT): z-coordinate of origin object
--distance (fixed_t): distance away from original coordinates
--angle (angle_t): angle the mobject will be facing
--mtype (enum MT_*): the type of mobject to spawn
--returns: spawned object
rawset(_G, "SpawnDistance", function(og_x, og_y, og_z, distance, angle, mtype)
	local x = og_x + distance * cos(angle)
	local y = og_y + distance * sin(angle)
	local z = og_z + z
	
	local obj = P_SpawnMobj(x, y, z, mtype)
	obj.angle = angle
	return obj
end)

--Function mostly shown by clairebun to use on SRB2 discord page
--mo1 (mobj_t): first mobj to check for collision
--mo2 (mobj_t): second mobj to check for collision
--extraheight (int): extra height added to the mo2
--returns: true if two mobjects collide vertically, false otherwise
rawset(_G, "L_ZCollide", function(mo1, mo2, extraheight)
	if(extraheight == nil) then
		extraheight = 0
	end
    if mo1.z > mo2.height+mo2.z+extraheight then return false end
    if mo2.z > mo1.height+mo1.z then return false end
    return true
end)


--OMG THERE ARE SO MANY ARGUMENTS I'M SORRY, wait who do I appologize to if I'm the only one using it :O
--rotatemo (mobj_t): the object to rotate
--pivotx (int): x-coordinate of a pivot point (around which rotatemo should be corrected by rotation)
--pivoty (int): y-coordinate of a pivot point (around which rotatemo should be corrected by rotation)
--desiredx (int): x-coordinate desired location (without rotation points forward (positive) and back (negative))
--desiredy (int): y-coordinate desired location (without rotation points left (positive) and right (negative))
--desiredz (int): z-coordinate desired location (won't be rotated)
--angle (angle_t): the correction angle of rotation
rawset(_G, "CorrectRotationHoriz", function(rotatemo, pivotx, pivoty, desiredx, desiredy, desiredz, angle)
	--The desired coordinates for rotatemo without rotation 
	-- local x = desired.x + desired.radius/3-5*FRACUNIT
	-- local y = desired.y + desired.radius/3-((1-1)*32/2)*FRACUNIT
	-- local z = desired.z + desired.height
	
	--The desired coordinates for rotatemo without rotation 
	local x = desiredx
	local y = desiredy 
	local z = desiredz 

	--The angle of rotation
	local c = cos(angle)
	local s = sin(angle)

	--New rotated coordinates
	local xnew = 0
	local ynew = 0
	
	--Translating coordinates of rotatemo to the desired to perform rotation
	x = $ - pivotx
	y = $ - pivoty

	--rotate point
	xnew = FixedMul(x, c) - FixedMul(y, s)
	ynew = FixedMul(y, c) + FixedMul(x, s)

	--translate point back:
	x = xnew + pivotx
	y = ynew + pivoty

	P_MoveOrigin(rotatemo, x, y, z)
	
end)

--Sets up Helcurts attributes when player switches to him
local function SetUp(player)
	if(not Valid(player.mo, "helcurt")) then
		return false
	end
	
	HelcurtSpeakOverride(player.mo, sfx_mrwn1, sfx_mrwn2)
	
	player.spinheld = 0 --Increments each tic it's held IN PRETHINK, use PF_SPINDOWN to get previous update
	player.jumpheld = 0 --Increments each tic it's held IN PRETHINK, use PF_JUMPDOWN to get previous update
	player.prevjumpheld = 0 --Value of jumpheld in previous tic
	player.prevspinheld = 0
	--Did player jump? Resets to 0 when hits the floor
	player.mo.hasjumped = 0
	--Carried by anything last tic
	player.mo.prevcarried = 0

	--Timer on which Helcurt says a random monologue phrase
	player.monologue_timer = MONOLOGUE_TIC_MAX

	player.mo.can_teleport = 0
	player.mo.teleported = 0
	player.mo.enhanced_teleport = 0

	player.mo.can_blade = 1

	player.mo.can_stinger = 0
	--Cooldown for a ground stinger cooldown
	player.mo.ground_tic_cd = 0 
	player.mo.stung = 0
	--Amount of extra stingers Helcurt has currently (not counting the current one)
	player.mo.stingers = 0
	player.mo.stinger_charge_countdown = -1
	player.mo.hudstingers = {} --keeping track of HUD elements that represent the string

	player.killcount = 0
	--Separate kill count to summon the night,
	--resets to zero when the night is summoned by the player
	player.killnight = 0
	player.lockon = nil
	
	--Time for the conceal to last after leaving the darkness (decreases 'till hits zero to unconceal)
	player.mo.prowler_state_bar = PROWLER_STATE_BAR_MAX
	
	-- if(player.night_timer ~= nil) then
	-- 	EndHelcurtNightBuff(originplayer)
	-- end
	
	if(player.night_timer ~= nil and player.night_timer ~= 0) then
		SPEED_BUG_PREVENTION(player)
	end
	player.night_timer = 0
	
	--DEPRECATED - Prevent changing to default particle color each time player respawns
	if(player.particlecolor == nil) then
		player.particlecolor = SKINCOLOR_DUSK
	end

	-- Unconceal(player.mo)

	-- P_SpawnMobj(player.mo.x, player.mo.y, player.mo.z, MT_FOLLOW)
	-- player.mo.tail.flags2 = MF2_LINKDRAW
	
	return true
end
local function CleanUp(player)
	if(not Valid(player.mo)) then
		return false
	end

	player.spinheld = nil 
	player.jumpheld = nil 
	player.prevjumpheld = nil 
	player.prevspinheld = nil
	player.mo.hasjumped = nil

	player.monologue_timer = -1

	player.mo.can_teleport = nil
	player.mo.teleported = nil
	player.mo.enhanced_teleport = nil

	player.mo.can_stinger = nil
	player.mo.ground_tic_cd = nil 
	player.mo.stung = nil
	player.mo.stingers = nil
	player.mo.stinger_charge_countdown = nil

	for i = 0, #hudstingers-1, 1 do
		P_KillMobj(player.mo.hudstingers[i])
	end

	player.mo.hudstingers = nil 

	player.killcount = nil
	player.killnight = nil
	player.lockon = nil
	
	player.night_timer = nil

	player.particlecolor = nil
	
	-- Unconceal(player.mo)

	return true
end
--------------------------
--/ THESE HOOKS ARE RAN FIRST
----------------------------/

--Handle needed variables on spawn
addHook("PlayerSpawn", function(player)
	-- if((not player.mo) or not (player.mo.skin == "helcurt"))  then

	--Set up if the player is helcurt, but doesn't work if the host player starts the server as helcurt
	--because skin is set to helcurt AFTER player spawns
	if(Valid(player.mo, "helcurt")) then
		SetUp(player)
	end
	

	--Sets up special server attributes
	if(player == server) then
		--information about the map so that the night won't last forever
		server.current_mapinfo = 0
		--original skybox, it is stored separately because skybox is not stored in mapheaderinfo
		server.og_skybox = 0
	end
end)

--The Base Thinker that plays before others,
--mostly used to record players input  before interacting with the abilities
addHook("PreThinkFrame", function()
	for player in players.iterate() do
		if(not Valid(player.mo, "helcurt") or not PAlive(player)) then
			continue
		end

		-- if(player.mo)

		--[[
		if(P_IsObjectOnGround(player.mo) and (player.powers[pw_justsprung] ~= 0 or player.powers[pw_carry] ~= 0)) then
			player.mo.hasjumped = 1
			-- player.mo.can_teleport = 1
			-- player.mo.teleported = 0

			-- player.mo.can_blade = 1

			-- player.mo.stung = 0
			-- player.mo.can_stinger = 1
		end 
		]]--
		
		
		--Noclip while teleporting, thus not be damaged by anything
		if(player.mo.state == S_START_TRANSITION or player.mo.state == S_IN_TRANSITION) then
			player.mo.flags = $|MF_NOCLIPTHING
		elseif(player.mo.flags&MF_NOCLIPTHING ~= 0) then
			player.mo.flags = $&~MF_NOCLIPTHING
		end

		--Retrieves the current input
		if(player.cmd.buttons & BT_SPIN) then
			player.spinheld = $+1
		elseif(player.spinheld ~= 0 and player.cmd.buttons ~= BT_SPIN) then
			player.spinheld = 0
		end
		if(player.cmd.buttons & BT_JUMP) then
			player.jumpheld = $+1
		elseif(player.jumpheld ~= 0 and player.cmd.buttons ~= BT_JUMP) then
			player.jumpheld = 0
		end


		--Gets the horizontal direction of inputs
		player.inputangle = player.cmd.angleturn*FRACUNIT + R_PointToAngle2(0, 0, player.cmd.forwardmove*FRACUNIT, -player.cmd.sidemove*FRACUNIT)
	-- 	player.mo.x = player.mo.x*cos(player.mo.angle) - player.mo.y*sin(player.mo.angle)
	-- 	player.mo.y = player.mo.y*cos(player.mo.angle) + player.mo.x*sin(player.mo.angle)

		-- print(player.mo.hasjumped)
		-- print(player.mo.prevcarried.." vs "..player.powers[pw_carry])
		-- print("tpan"..player.mo.can_teleport.."	tped"..player.mo.teleported)
		-- print("sted"..player.mo.stung.."	stcn"..player.mo.can_stinger)
		-- print("blcn"..player.mo.can_blade)
		-- Detect voluntery jumping
		if(((P_IsObjectOnGround(player.mo) and player.jumpheld == 1) or player.powers[pw_justsprung] ~= 0) and player.mo.hasjumped == 0) then
		-- if(not P_IsObjectOnGround(player.mo) and ) then
			player.mo.hasjumped = 1
		elseif(player.mo.eflags&MFE_JUSTHITFLOOR ~= 0 or player.powers[pw_carry] ~= 0) then
			player.mo.hasjumped = 0
		end

	end
end)

addHook("PlayerThink", function(p)
	if(not Valid(p.mo, "helcurt") or not PAlive(p)) then
		return false
	end

	--Detect when the player has left the carry in order to allow to perform the abilities
	if((p.mo.prevcarried ~= 0 and p.powers[pw_carry] == 0)) then
		p.mo.hasjumped = 1
	end

	if(p.monologue_timer ~= nil and p.monologue_timer > 0*TICRATE) then
		p.monologue_timer = $-1
	else 
		HelcurtSpeak(p.mo, sfx_mnl01, sfx_mnl03, FRACUNIT/3) 
		p.monologue_timer = P_RandomRange(MONOLOGUE_TIC_MAX/2, 3*MONOLOGUE_TIC_MAX/2)
	end

	
end)



--The Thinker that plays after other thikers,
--mostly used to clean up, record the previous state, 
--and jump and spin button holding
addHook("PostThinkFrame", function()
	for player in players.iterate() do
		if(Valid(player.mo, "helcurt")) then
			--Rotate the folllow object around the player just a tiny bit to make it appear behind the player
			if(PAlive(player)) then
				
				if player.followmobj then
					CorrectRotationHoriz(player.followmobj, player.mo.x, player.mo.y,
											player.mo.x-FRACUNIT, 
											player.mo.y, 
											player.mo.z, player.followmobj.angle)
				end



				player.prevjumpheld = player.jumpheld
				player.prevspinheld = player.spinheld
				player.mo.prevstate = player.mo.state
				-- print("prev: "..player.mo.prevcarried.." vs "..player.powers[pw_carry])
				player.mo.prevcarried = player.powers[pw_carry]

				--Charging shadow particles during the ultimate
				if(player.mo.state == S_NIGHT_CHARGE) then

					--Max distance for charging shadow particles around the player
					local distance = 80*FRACUNIT

					--Spawn shadow particles around 
					local shadow = P_SpawnMobjFromMobj(player.mo, 
										P_RandomRange(-distance/FRACUNIT, distance/FRACUNIT)*FRACUNIT,
										P_RandomRange(-distance/FRACUNIT, distance/FRACUNIT)*FRACUNIT,
										P_RandomRange(-distance/FRACUNIT, distance/FRACUNIT)*FRACUNIT,
										MT_SHDW)
					
					if not shadow.valid then return end
					
					--Setting the visual properties
					shadow.state = S_SHDW_PRT
					shadow.frame = FF_TRANS10

					--Setting the speed to match player's speed
					shadow.momx = player.mo.momx
					shadow.momy = player.mo.momy
					shadow.momz = player.mo.momz

					--Move "into" the direction of the player
					P_Thrust(shadow, 
							R_PointToAngle2(shadow.x, shadow.y, player.mo.x, player.mo.y),
							R_PointToDist2(shadow.x, shadow.y, player.mo.x, player.mo.y)/TICRATE)

					P_SetObjectMomZ(shadow, (player.mo.z - shadow.z)/(TICRATE/3), true)
				end

				
			end
		end
	end
end)


--Determines how to handle the killing of targets
addHook("MobjDeath", function(target, inflictor, source, dmgtype)
	--If Helcurt is the death source for targets in defined target-range (enemies, monitors, etc? NOT RINGS)
	-- if(source == nil or source.valid == nil or source.skin == nil or source.skin ~= "helcurt" or source.player == nil
	-- or target == nil or not (target.flags & TARGET_DMG_RANGE)) then

	if(not Valid(source, "helcurt")) then
		return nil
	end
	
	

	-- print(source.skin)
	if(target.flags & TARGET_DMG_RANGE ~= 0) then
		source.player.killcount = $+1
		source.player.killnight = $+1
		HelcurtSpeak(inflictor, sfx_mkil1, sfx_mkil4, FRACUNIT)
	-- elseif(target.flags & TARGET_DMG_RANGE|MF_BOSS and target.) then
	-- 	HelcurtSpeakOverride(target, sfx_mbos1, sfx_mbos2, FRACUNIT)
	end

end)


--Determines how to handle Helcurt's death
addHook("MobjDeath", function(target, inflictor, source, dmgtype)
	if(not Valid(target, "helcurt")) then
		return nil
	end
	
	HelcurtSpeakOverride(target, sfx_mdth1, sfx_mdth2, FRACUNIT)
	  

end, MT_PLAYER)


--Determines how to handle when Helcurt is damaged
addHook("MobjDamage", function(target, inflictor, source, dmgtype)
	if(not Valid(target, "helcurt")) then
		return nil
	end
	
	HelcurtSpeakOverride(target, sfx_mgrn3, sfx_mgrn4, FRACUNIT/5)
	  

end, MT_PLAYER)



--/--------------------------
--/ ACTIONS
--/--------------------------


---------------- CUSTOM OBJECT ACTIONS ---------------- 
local function A_ShdwHint(actor, var1, var2) 
	if(not Valid(actor)) then
		return nil
	end

	actor.spritexscale = FRACUNIT*4
	actor.spriteyscale = FRACUNIT*4

	P_SetObjectMomZ(actor, P_RandomRange(-2, 2)*FRACUNIT, false)
end

local function A_Eyes_1(actor, var1, var2) 
	if(not Valid(actor)) then
		return nil
	end

end

local function A_Eyes_2(actor, var1, var2) 
	if(not Valid(actor)) then
		return nil
	end

	-- print("night!")
	actor.spritexscale = STYX_EYES_SCALE
	actor.spriteyscale = STYX_EYES_SCALE
end


---------------- PLAYER ACTIONS ---------------- 

local function A_NightCharge(actor, par1, par2)

	if(not Valid(actor, "helcurt") or not PAlive(actor.player)) then
		return nil
	end

	--Prevents activation of other abilities during and after
	actor.can_teleport = 0
	actor.can_blade = 0
	
	--Visual effect that look like "eyes" while summoning the night
	local styx_eyes = P_SpawnMobj(actor.x, actor.y, actor.z, MT_EYES)
	--Who'm to follow
	styx_eyes.target = actor
	styx_eyes.state = S_EYES_1
end

local function A_NightActivate(actor, par1, par2)

	if(not Valid(actor, "helcurt") or not PAlive(actor.player)) then
		return nil
	end
	
	actor.player.night_timer = NIGHT_MAX_TIC

	P_Thrust(actor, actor.angle, 50*FRACUNIT)
	
	StartTheNight(actor.player)
end

local function A_Pre_Transition(actor, par1, par2)
	if(not Valid(actor, "helcurt") or not PAlive(actor.player)) then
		return nil
	end

	actor.can_teleport = 0
	actor.teleported = 1

	S_StartSound(actor, sfx_trns1)

	actor.momz = $/10
	actor.momy = $/2
	actor.momx = $/2
end


--Start the teleportation transition
local function A_Start_Transition(actor, par1, par2)
	if(not Valid(actor, "helcurt") or not PAlive(actor.player)) then
		return nil
	end
	
	P_SpawnMobj(actor.x, actor.y, actor.z, MT_TRNS)

	--Thrusts forward, increased with the nightfall.
	--NOTE: consider making teleport's speed relative to helcurt's, the faster he moves
	--the fastere teleport is, but give the teleport the base speed so that Helcurt can teleport
	--from stand still
	P_InstaThrust(actor, actor.angle, (actor.player.night_timer == 0 and TELEPORT_SPEED or TELEPORT_SPEED + TELEPORT_SPEED/3))
	P_SetObjectMomZ(actor, 0, false)

end

--End the transition
local function A_End_Transition(actor, par1, par2)
	if(not Valid(actor, "helcurt") or not PAlive(actor.player)) then
		return nil
	end

	S_StartSound(actor, sfx_trns2)
	HelcurtSpeak(actor, sfx_mtlp1, sfx_mtlp1, FRACUNIT/3)
	P_SpawnMobj(actor.x, actor.y, actor.z, MT_TRNS)

	--Regular teleport (momentum is decreased)
	if(actor.enhanced_teleport == 0) then
		actor.momy = $/TELEPORT_STOP_SPEED
		actor.momx = $/TELEPORT_STOP_SPEED
	--Enhanced teleport
	else
		actor.enhanced_teleport = 0
	end

	--Add a stinger only if already stung (to avoid teleport spamming to get free stacks)
	if(actor.stung == 1) then
		--Add a stinger for a teleport
		AddStingers(actor, 1)
	end

	--Recharge the stinger ability (technically just air stinger you're in the air)
	actor.can_stinger = 1
	
	
end

--/--------------------------
--/ MOBJECT INFOS
--/--------------------------

mobjinfo[MT_EYES] = { 
	spawnstate = S_EYES_1,
	deathstate = S_NULL,
	height = FRACUNIT,
	radius = FRACUNIT,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_FLOAT|MF_NOGRAVITY|MF_SCENERY
}

mobjinfo[MT_LOCK] = {
	spawnstate = S_LOCK,
	deathstate = S_NULL,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_FLOAT|MF_NOGRAVITY
}

mobjinfo[MT_TRNS] = {
	spawnstate = S_TRNS,
	height = FRACUNIT,
	radius = FRACUNIT,
	deathstate = S_NULL,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_FLOAT|MF_NOGRAVITY--|MF_SCENERY
}

-- The follow object (the cape and tail)
mobjinfo[MT_FOLLOW] = {
	spawnstate = S_FOLLOW,
	height = FRACUNIT,
	radius = FRACUNIT,
	dispoffset = -1,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_FLOAT|MF_NOGRAVITY
}

mobjinfo[MT_SHDW] = {
	spawnstate = S_SHDW_PRT,
	height = 16*FRACUNIT,
	radius = 8*FRACUNIT,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_FLOAT|MF_NOGRAVITY|MF_SCENERY
}


--/--------------------------
--/ SOUNDS
--/--------------------------


------------ Sound effects ------------


sfxinfo[sfx_blde1] = {
	singular = false,
	priority = 60
}


sfxinfo[sfx_trns1] = {
	singular = false,
	priority = 64
}
sfxinfo[sfx_trns2] = {
	singular = false,
	priority = 65
}


sfxinfo[sfx_nght1] = {
	singular = false,
	priority = 60
}
sfxinfo[sfx_nght2] = {
	singular = false,
	priority = 60
}
sfxinfo[sfx_nght3] = {
	singular = false,
	priority = 60
}


sfxinfo[sfx_upg01] = {
	singular = false,
	priority = 60
}
sfxinfo[sfx_upg02] = {
	singular = false,
	priority = 60
}
sfxinfo[sfx_upg03] = {
	singular = false,
	priority = 60
}
sfxinfo[sfx_upg04] = {
	singular = false,
	priority = 60
}


sfxinfo[sfx_stg01] = {
	singular = false,
	priority = 60
}
sfxinfo[sfx_stg02] = {
	singular = false,
	priority = 60
}
sfxinfo[sfx_stg03] = {
	singular = false,
	priority = 60
}
sfxinfo[sfx_stg04] = {
	singular = false,
	priority = 60
}
sfxinfo[sfx_stg05] = {
	singular = false,
	priority = 60
}


sfxinfo[sfx_hide1] = {
	singular = true,
	priority = 60
}
sfxinfo[sfx_hide2] = {
	singular = true,
	priority = 60
}
sfxinfo[sfx_hide3] = {
	singular = true,
	priority = 60
}

------------ MONOLOGUES ------------

sfxinfo[sfx_mbos1] = {
	singular = true,
	priority = 60
}
sfxinfo[sfx_mbos2] = {
	singular = true,
	priority = 60
}


sfxinfo[sfx_mcon1] = {
	singular = true,
	priority = 60
}
sfxinfo[sfx_munc1] = {
	singular = true,
	priority = 60
}
sfxinfo[sfx_mgrn1] = {
	singular = true,
	priority = 60
}
sfxinfo[sfx_mgrn2] = {
	singular = true,
	priority = 60
}
sfxinfo[sfx_mgrn3] = {
	singular = true,
	priority = 60
}
sfxinfo[sfx_mgrn4] = {
	singular = true,
	priority = 60
}
sfxinfo[sfx_mgrn5] = {
	singular = true,
	priority = 60
}


sfxinfo[sfx_mkil1] = {
	singular = true,
	priority = 60
}
sfxinfo[sfx_mkil2] = {
	singular = true,
	priority = 60
}
sfxinfo[sfx_mkil3] = {
	singular = true,
	priority = 60
}
sfxinfo[sfx_mkil4] = {
	singular = true,
	priority = 60
}


sfxinfo[sfx_mnht1] = {
	singular = true,
	priority = 60
}
sfxinfo[sfx_mnht2] = {
	singular = true,
	priority = 60
}
sfxinfo[sfx_mnht3] = {
	singular = true,
	priority = 60
}


sfxinfo[sfx_mnl01] = {
	singular = true,
	priority = 60
}
sfxinfo[sfx_mnl02] = {
	singular = true,
	priority = 60
}
sfxinfo[sfx_mnl03] = {
	singular = true,
	priority = 60
}


sfxinfo[sfx_mrwn1] = {
	singular = true,
	priority = 60
}
sfxinfo[sfx_mrwn2] = {
	singular = true,
	priority = 60
}


sfxinfo[sfx_mdth1] = {
	singular = true,
	priority = 60
}
sfxinfo[sfx_mdth2] = {
	singular = true,
	priority = 60
}


sfxinfo[sfx_mstg1] = {
	singular = true,
	priority = 60
}


sfxinfo[sfx_mtlp1] = {
	singular = true,
	priority = 60
}


--/--------------------------
--/ STATES
--/--------------------------


---------------- PLAYER STATES ---------------- 

--Charges in order to activate the night manually
states[S_NIGHT_CHARGE] = {
	sprite = SPR_PLAY,
	frame = SPR2_FALL,
	tics = TICRATE/2,
	action = A_NightCharge,
	nextstate = S_NIGHT_ACTIVATE
}

--Activates the night 
states[S_NIGHT_ACTIVATE] = {
	sprite = SPR_PLAY,
	frame = SPR2_BLDE,
	tics = 5,
	action = A_NightActivate,
	nextstate = S_PLAY_FALL
}

states[S_PRE_TRANSITION] = {
	sprite = SPR_PLAY,
	frame = SPR2_JUMP|FF_FULLDARK,
	tics = 2,
	action = A_Pre_Transition,
	nextstate = S_START_TRANSITION
}

states[S_START_TRANSITION] = {
	sprite = SPR_NULL,
	tics = 1,
	action = A_Start_Transition,
	sound = sfx_trns1,
	nextstate = S_IN_TRANSITION
}

states[S_IN_TRANSITION] = {
	tics = 10,
	-- action = A_In_Transition,
	nextstate = S_END_TRANSITION
}

states[S_END_TRANSITION] = {
	sprite = SPR_PLAY,
	frame = SPR2_FALL,
	tics = -1,
	action = A_End_Transition,
	nextstate = S_PLAY_FALL
}

---------------- CUSTOM OBJECT STATES ---------------- 

states[S_EYES_1] = {
	sprite = SPR_NGHT,
	frame = FF_ANIMATE|FF_TRANS90,
	action = A_Eyes_1,
	tics = states[S_NIGHT_CHARGE].tics,
	nextstate = S_EYES_2
}

states[S_EYES_2] = {
	sprite = SPR_NGHT,
	frame = FF_ANIMATE|FF_TRANS50,
	tics = TICRATE/3,
	action = A_Eyes_2,
	nexstate = S_NULL
}

states[S_TRNS] = {
	sprite = SPR_TRNS,
	tics = TICRATE
}

states[S_SHDW_PRT] = {
	sprite = SPR_SHDW,
	frame = FF_TRANS50,
	tics = TICRATE/2
}

states[S_SHDW_HINT] = {
	sprite = SPR_SHDW,
	frame = FF_TRANS10,
	action = A_ShdwHint,
	tics = TICRATE*2
}

states[S_FOLLOW] = {
	sprite = SPR_FLWR,
	frame = FF_ANIMATE,
	var1 = 3, --Number of frames minus 1
	var2 = 10, --Tics before cycle to a new frame
	tics = -1
}

--[[
states[S_LOCK] = {
	sprite = SPR_LOCK,
	tics = -1,
	nextstate = S_NULL
}
]]--
