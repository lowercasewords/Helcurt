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
freeslot("S_PRE_TRANSITION", "S_START_TRANSITION", "S_IN_TRANSITION","S_END_TRANSITION", "S_TRNS",
"S_BLADE_THURST", "S_BLADE_THURST_HIT", "S_STACK", "S_LOCK", "S_FOLLOW_STAND", "S_FOLLOW_RUN",
"S_AIR_1", "S_GRND_1", "S_AIR_2", "S_GRND_2",
"S_STINGER_AIR_1", "S_STINGER_AIR_2", 
"S_STINGER_GRND_1", "S_STINGER_GRND_2",
"S_NIGHT_CHARGE", "S_NIGHT_ACTIVATE", "S_EYES_1", "S_EYES_2", "S_NGHT_1", "S_NGHT_2")

--Most objects
freeslot("MT_STGP", "MT_STGS", "MT_LOCK", "MT_TRNS", "MT_FOLLOW", "MT_EYES")

--most player and object sprites
freeslot("SPR2_STNG", "SPR2_BLDE", "SPR2_LNCH", "SPR_STGP", "SPR_STGS", "SPR_STGA", "SPR_LOCK", "SPR_TRNS", "SPR_FLWS", "SPR_FLWR",
"SPR_NGHT")

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
rawset(_G, "MONOLOGUE_TIC_MAX", TICRATE*10)
rawset(_G, "MONOLOGUE_START_SOUND", sfx_mrwn1)
rawset(_G, "MONOLOGUE_END_SOUND", sfx_mnl03)


rawset(_G, "TARGET_DMG_RANGE", MF_SHOOTABLE|MF_ENEMY|MF_BOSS|MF_MONITOR)--|MF_MONITOR|MF_SPRING)
rawset(_G, "TARGET_NONDMG_RANGE", MF_SPRING)
-- rawset(_G, "TARGET_KILL_RANGE", MT_POINTYBALL|MT_EGGMOBILE_BALL|MT_SPIKEBALL|MT_SPIKE|MT_WALLSPIKE|MT_WALLSPIKEBASE|MT_SMASHINGSPIKEBALL)
rawset(_G, "TARGET_IGNORE_RANGE", MF_MISSILE)


rawset(_G, "TELEPORT_SPEED", 70*FRACUNIT)
rawset(_G, "TELEPORT_STOP_SPEED", 3)


rawset(_G, "BLADE_THURST_SPEED", 15*FRACUNIT)
rawset(_G, "BLADE_THURST_JUMP", 8*FRACUNIT)
rawset(_G, "BLADE_THRUST_FALL", -FRACUNIT*10)


--Maximum amount of extra stingers (not counting the one you always have)
rawset(_G, "MAX_STINGERS", 4)
rawset(_G, "STINGER_VERT_BOOST", 20*FRACUNIT)
rawset(_G, "STINGER_HORIZ_BOOST", 40*FRACUNIT)
rawset(_G, "STGP_AIR_SPEED", 20*FRACUNIT)
rawset(_G, "STGP_GRND_SPEED", 40*FRACUNIT)
rawset(_G, "STINGER_GRND_COOLDOWN", TICRATE)
--Half of the stinger's angular trajectory a it needs to travel
rawset(_G, "HALF_AIR_ANGLE", ANGLE_135)
--Half of the stinger's angular trajectory a it needs to travel
rawset(_G, "HALF_GRND_ANGLE", ANG105-ANG20)
rawset(_G, "SEPARATION_AIR_ANGLE", ANGLE_45)
rawset(_G, "SEPARATION_GRND_ANGLE", ANG30)
--Extra vertical boost for helcurt when charging the stingers (before release)
rawset(_G, "EXTRA_CHARGE_BOOST", 20*FRACUNIT)
--Slow down Helcurt by this factor once when started charging stingers
rawset(_G, "CHARGE_SLOWDOWN_FACTOR", 3)


--How dark the area has to be to activate his passive
rawset(_G, "CONCEAL_DARKNESS_LEVEL", 180)
rawset(_G, "CONCEAL_ACCELERATION_BOOST", 20)
rawset(_G, "CONCEAL_NORMALSPEED_BOOST",  10*FRACUNIT)
rawset(_G, "CONCEAL_JUMPFACTOR_BOOST",  FRACUNIT/2)
--Maximum tics for a player's passive to be active after the player exited the dark area
rawset(_G, "UNCONCEAL_MAX_TICS", TICRATE)


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


--Adds stingers to the (player's) helcurt mobject 
--mo (mobj_t): the mobject to add stingers
--amount (int): the number of stingers to add (won't exceed the limit)
rawset(_G, "AddStingers", function(mo, amount)
	--add a stinger if possible	
	if(Valid(mo, "helcurt")) then
		for i = 1, amount, 1 do
			if(mo.stingers < MAX_STINGERS) then
				mo.hudstingers[mo.stingers].frame = $&~FF_FULLDARK
				mo.stingers = $ + 1
				if(mo.stingers ~= MAX_STINGERS) then
					S_StartSound(mo, sfx_upg04)
				else
					S_StartSound(mo, sfx_upg01)
					S_StopSoundByID(mo, sfx_upg04)
				end
			end 
		end
	end
end)

--Removes stingers from the (player's) helcurt mobject 
--mo (mobj_t): the mobject to remove stingers stingers
--amount (int): the number of stingers to remove (won't exceed the limit)
rawset(_G, "RemoveStingers", function(mo, amount)
	-- if(mo and mo.stingers ~= nil and mo.skin == "helcurt") then
	if(Valid(mo, "helcurt")) then
		for i = 1, amount, 1 do
			if(mo.stingers > 0) then
				mo.hudstingers[mo.stingers - 1].frame = $|FF_FULLDARK
				mo.stingers = $ - 1
			end 
		end
	end
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


--Conceals the player in the darkness (called once)
rawset(_G, "Conceal", function(mo)
	if(not Valid(mo)) then
		return nil
	end

	mo.unconceal_timer = UNCONCEAL_MAX_TICS

	--Immediate extra stinger upon concealing
	if(mo.stingers < MAX_STINGERS) then
		AddStingers(mo, 1)
	end

	S_StartSound(mo, sfx_hide1)
	HelcurtSpeak(mo, sfx_mcon1, sfx_mcon1, FRACUNIT/10)

	--Attribute increase
	mo.player.acceleration = $+CONCEAL_ACCELERATION_BOOST
	mo.player.normalspeed = $+CONCEAL_NORMALSPEED_BOOST
	mo.player.jumpfactor = $+CONCEAL_JUMPFACTOR_BOOST
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
    mo.player.acceleration = skin.acceleration
    mo.player.normalspeed =  skin.normalspeed
	mo.player.jumpfactor = skin.jumpfactor
end)

rawset(_G, "StartHelcurtNightBuff", function(originplayer)
    if(not Valid(originplayer.mo, "helcurt") or not PAlive(originplayer)) then
        return nil
    end
        --[[
        local skin = skins[originplayer.skin] 

        --Reset attributes to be boosted
        originplayer.acceleration = skin.acceleration
        originplayer.normalspeed = skin.normalspeed

        --Boost in attributes
        originplayer.acceleration = $+CONCEAL_ACCELERATION_BOOST*2
        originplayer.normalspeed = $+CONCEAL_NORMALSPEED_BOOST*2
        ]]--
end)

rawset(_G, "EndHelcurtNightBuff", function(originplayer)
    if(not Valid(originplayer.mo, "helcurt") or not PAlive(originplayer)) then
        return nil
    end

    --[[
    local skin = skins[originplayer.skin]
    
    --Changes the speed back
    originplayer.acceleration = skin.acceleration
    originplayer.normalspeed = skin.normalspeed
    ]]--
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


--Rotates the mobject around the pivot, think of a circle with pivot as a center and
--torotate being on the edge of the circle (distance between pivot and torotate is the radius of a circle)
--roll (angle_t): rotation along absolute x-axis
--yaw (angle_t): rotation along absolute z-axis (due to doom's engine coordinate system)
--pitch (angle_t): rotation along absolute y-axis (due to doom's engine coordinate system)
--[[
rawset(_G, "Rotate", function(torotate, pivotx, pivoty, pivotz, roll, yaw, pitch) 

	-- local radius = torotate.target.radius*2
	-- local x = FixedMul(FixedMul(radius, cos(torotate.rollcounter)),cos(torotate.yawcounter-(torotate.num-1)*torotate.yawcounter)) + torotate.target.x
	-- local y = FixedMul(FixedMul(radius, cos(torotate.rollcounter)),sin(torotate.yawcounter-(torotate.num-1)*torotate.yawcounter)) + torotate.target.y
	-- local z = FixedMul(radius, sin(torotate.rollcounter)) + torotate.target.z
	-- CorrectRotationHoriz(torotate, pivotx, pivoty, x, y, z, torotate.target.angle)

	--Initial coordinates of the object without the rotation
	local initx = torotate.x
	local inity = torotate.y
	local initz = torotate.z
	
	--Distance between the object to be rotated and pivot point
	local radius = FixedSqrt(
	FixedMul(torotate.x-pivotx, torotate.x-pivotx) +
	FixedMul(torotate.y-pivoty, torotate.y-pivoty) +
	FixedMul(torotate.z-pivotz, torotate.z-pivotz) )
	
	--Updated to be around the origin
	local normx = initx-pivotx
	local normy = inity-pivoty
	local normz = initz-pivotz

	local rolledx = FixedMul(radius, cos(roll))
	local rolledy = FixedMul(y, c) + FixedMul(x, s)

	initx = rolledx + pivotx
	inity = inity + pivoty
	initz = initz + pivotz

	P_MoveOrigin(torotate, rolledx, inity, initz)

end)
]]--

--[[

THOSE THREE FUNCTIONS CANNOT BE MIXED AT ALL! Read the answer for this post for more 
questions: https://stackoverflow.com/questions/14607640/rotating-a-vector-in-3d-space
"This works perfectly fine for 2D and for simple 3D cases; 
but when rotation needs to be performed around all three axes at the same time 
then Euler angles may not be sufficient due to an inherent deficiency in this system 
which manifests itself as Gimbal lock. People resort to Quaternions in such situations, 
which is more advanced than this but doesn't suffer from Gimbal locks when used correctly."


--Rotates around z-axis 
rawset(_G, "Yaw", function(torotate, pivotx, pivoty, angle)

	--The desired coordinates for rotatemo without rotation 
	local x = torotate.x
	local y = torotate.y 

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

	P_MoveOrigin(torotate, x, y, torotate.z)
end)

--Rotates arounc x-axis
rawset(_G, "Roll", function(torotate, pivoty, pivotz, angle)

	--The desired coordinates for rotatemo without rotation 
	local y = torotate.y 
	local z = torotate.z 

	--The angle of rotation
	local c = cos(angle)
	local s = sin(angle)

	--New rotated coordinates
	local ynew = 0
	local znew = 0
	
	--Translating coordinates of rotatemo to the desired to perform rotation
	y = $ - pivoty
	z = $ - pivotz

	--rotate point
	znew = FixedMul(z, c) - FixedMul(y, s)
	ynew = FixedMul(y, c) + FixedMul(z, s)
	

	--translate point back:
	y = ynew + pivoty
	z = znew + pivotz

	P_MoveOrigin(torotate, torotate.x, y, z)
end)


--Rotates arounc y-axis
rawset(_G, "Pitch", function(torotate, pivotx, pivotz, angle)

	--The desired coordinates for rotatemo without rotation 
	local x = torotate.x
	local z = torotate.z

	--The angle of rotation
	local c = cos(angle)
	local s = sin(angle)

	--New rotated coordinates
	local xnew = 0
	local znew = 0
	
	--Translating coordinates of rotatemo to the desired to perform rotation
	x = $ - pivotx
	z = $ - pivotz

	--rotate point
	xnew = FixedMul(x, c) - FixedMul(z, s)
	znew = FixedMul(z, c) + FixedMul(x, s)
	

	--translate point back:
	x = xnew + pivotx
	z = znew + pivotz

	P_MoveOrigin(torotate, x, torotate.y, z)
end)

]]--

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
	player.mo.unconceal_timer = -1
	
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


	for i = 0, MAX_STINGERS-1, 1 do
		--The spawn location doesn't matter because the object
		--will be constantly set to the desired location (locked to the player)
		player.mo.hudstingers[i] = P_SpawnMobjFromMobj(player.mo, 0,0,0,MT_STGS)
		player.mo.hudstingers[i].frame = $|FF_FULLDARK
	end
	
	Unconceal(player.mo)

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
	
	Unconceal(player.mo)

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
		

		--Can detect:
			--When 


		--Not allow to move during these states
		if(player.mo.state == S_IN_TRANSITION or 
		player.mo.state == S_STINGER_GRND_1 or 
		player.mo.state == S_STINGER_GRND_2 or 
		player.mo.state == S_NIGHT_CHARGE) then
			player.cmd.forwardmove = 0
			player.cmd.sidemove = 0
		end
		
		
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
			--Setting positions of HUD stingers 
			for i = 0, MAX_STINGERS-1, 1 do
				--How Desired y-coordinate should depend on amount of maximum stingers 
				--So their position should be dependant on number of maximum stingers (in case we want to change it)
				--But right now it only works with 3 stingers because I neither have time nor skills :(
				--   1 
				--  1 2 
				-- 1 2 3

				CorrectRotationHoriz(player.mo.hudstingers[i], player.mo.x, player.mo.y,
									player.mo.x-player.mo.radius, 
									-- player.mo.y+player.mo.radius-player.mo.radius*i, 
									player.mo.y - (player.mo.radius*i) + (player.mo.radius/3) * MAX_STINGERS, 
									player.mo.z+player.mo.height, R_PointToAngle(player.mo.x, player.mo.y))
				
			end

			--Rotate the folllow object around the player just a tiny bit to make it appear behind the player
			if(PAlive(player)) then
				
				CorrectRotationHoriz(player.followmobj, player.mo.x, player.mo.y,
										player.mo.x-FRACUNIT, 
										player.mo.y, 
										player.mo.z, player.followmobj.angle)



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

--Action performed by a stinger when charging is complete in the air
local function A_Air2(actor, var1, var2)
	-- if(actor.target == nil or actor.target.player == nil) then
	if(not Valid(actor) or not Valid(actor.target, "helcurt") or actor.target.player == nil) then
		return nil
	end
	
	local ownerspeed = FixedHypot(actor.target.momx, actor.target.momy)

	--Point towards the player
	actor.angle = 
		R_PointToAngle2(actor.x, actor.y, actor.target.x, actor.target.y) -
		actor.target.angle +
		actor.target.player.inputangle

	--Fixed momentum change for the stinger
	P_SetObjectMomZ(actor, -STGP_AIR_SPEED, false)
	P_Thrust(actor, actor.angle, -STGP_GRND_SPEED/2)

	--Contribute to the vertical boost of the player
	-- P_SetObjectMomZ(actor.target, STINGER_VERT_BOOST, true)	

end

--Action performed by a stinger when charging is complete on the ground
local function A_Grnd2(actor, var1, var2)
	if(not Valid(actor) or not Valid(actor.target, "helcurt")) then
		return nil
	end
	
	--How far ahead the stingers are going to cross each other
	local forward = 150*FRACUNIT
	local ownerspeed = FixedHypot(actor.target.momx, actor.target.momy)

	local c = cos(actor.target.angle) 
	local s = sin(actor.target.angle)
	
	local x = actor.target.x + FixedMul(forward, c) - FixedMul(0, s)
	local y = actor.target.y + FixedMul(0, c) + FixedMul(forward, s)

	actor.angle = R_PointToAngle2(actor.x, actor.y, x, y)

	--Fixed momentum change for the stinger
	P_Thrust(actor, actor.angle, ownerspeed+STINGER_HORIZ_BOOST)
end

local function A_Air3(actor, var1, var2)
	if(not Valid(actor) or not Valid(actor.target, "helcurt")) then
		return nil
	end

	local ownerspeed = FixedHypot(actor.momx, actor.momy)

	actor.angle = R_PointToAngle2(actor.x, actor.y, actor.target.x, actor.target.y)
	P_InstaThrust(actor, actor.angle, ownerspeed+STINGER_HORIZ_BOOST*3)
	
end


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

--Thursts in the direction of the movement input while canceling all vertical momentum
local function A_BladeThrust(actor, par1, par2)
	if(not Valid(actor, "helcurt") or not PAlive(actor.player)) then
		return nil
	end
	
	local ownerspeed = FixedHypot(actor.momx, actor.momy)
	P_SetObjectMomZ(actor, BLADE_THRUST_FALL, false)
	P_InstaThrust(actor, actor.player.inputangle, ownerspeed/2+BLADE_THURST_SPEED)
	
	-- actor.player.pflags = $|PF_SPINNING
	--Empower springs
	actor.player.powers[pw_strong] = $|STR_SPRING
	actor.can_blade = 0
end


local function A_BladeThrustHit(actor, par1, par2)
	if(not Valid(actor, "helcurt") or not PAlive(actor.player)) then
		return nil
	end
	local ownerspeed = FixedHypot(actor.momx, actor.momy)
	
	
	P_Thrust(actor, actor.player.inputangle + ANGLE_180, ownerspeed/5)
	P_SetObjectMomZ(actor, BLADE_THURST_JUMP, false)
	
	S_StartSound(actor, sfx_blde1)

	--Recharge the stinger ability (technically just air stinger you're in the air)
	actor.can_stinger = 1
	actor.stung = 0

	--Allow to teleport
	actor.can_teleport = 1
	--Allow to performed an enhanced teleport
	actor.enhanced_teleport = 1
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


--[[
--Perform single time once in transition
local function A_In_Transition(actor, par1, par2)
	if(not Valid(actor, "helcurt") or not PAlive(actor.player)) then
		return nil
	end
-- 	actor.flags = $|MF_NOCLIPTHING
	-- print("in")
	
end
]]--


--End the transition
local function A_End_Transition(actor, par1, par2)
	if(not Valid(actor, "helcurt") or not PAlive(actor.player)) then
		return nil
	end

	S_StartSound(actor, sfx_trns2)
	HelcurtSpeak(actor, sfx_mtlp1, sfx_mtlp1, FRACUNIT/3)
	P_SpawnMobj(actor.x, actor.y, actor.z, MT_TRNS)


-- 	if(actor.player and actor.player.valid) then
		-- actor.can_blade = true
-- 	end
	-- print("end!")
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

--Not an action by itself by is called by different actions that do a very similar job 
local function Stinger(playmo, startrollangle, stingerstate)
	if(not Valid(playmo, "helcurt") or not PAlive(playmo.player)) then
		return nil
	end
	
	playmo.can_stinger = 0
	playmo.stung = 1
	-- print("Release "..playmo.stingers.." deadly stingers!")
	
	playmo.momx = $/CHARGE_SLOWDOWN_FACTOR
	playmo.momy = $/CHARGE_SLOWDOWN_FACTOR
	playmo.momz = $/CHARGE_SLOWDOWN_FACTOR

	HelcurtSpeak(playmo, sfx_mstg1, sfx_mstg1, FRACUNIT/5)
	S_StartSound(playmo, sfx_stg01+playmo.stingers)

	--Spawning each of Helcurt available stingers and one Helcurt always has
	for i = 1, playmo.stingers+1, 1 do
		--Spawn location doesn't really matter because it would immediately be displaced with no regards to its position
		local stinger = P_SpawnMobj(playmo.x, playmo.y, playmo.z+playmo.height, MT_STGP)
		stinger.target = playmo --object that "shot" a stinger			
		stinger.homing_enemy = nil --Is a stinger locked-on to a target
		stinger.rollcounter = startrollangle --Vertical counter relative to the player
		stinger.num = i --The number of the current stinger
		stinger.released = playmo.stingers + 1 --How many stingers were released (not the best way to do it I know but it works just fine)
		stinger.state = stingerstate
	end
	
end

--Helcurt prepares to stinger jump
local function A_StingerAir1(actor, var1, var2)
	if(not Valid(actor, "helcurt") or not PAlive(actor.player)) then
		return nil
	end

	--Helcurt's when he started charging his stinger attack (that circly thing process around Helcurt)
	P_SetObjectMomZ(actor, STINGER_VERT_BOOST, true)
	Stinger(actor, var1, var2)
end


--Helcurt stinger jumps
local function A_StingerAir2(actor, var1, var2)
	if(not Valid(actor, "helcurt") or not PAlive(actor.player)) then
		return nil
	end
	
	local vertboost = STINGER_VERT_BOOST * actor.stingers
	P_SetObjectMomZ(actor, vertboost/MAX_STINGERS, true)
	P_Thrust(actor, actor.player.inputangle, STINGER_HORIZ_BOOST)

	-- P_SetObjectMomZ(actor.target, STINGER_VERT_BOOST, true)	
	--Reset stingers after usage
	RemoveStingers(actor, MAX_STINGERS)
end


--Helcurt prepares ground stinger
local function A_StingerGrnd1(actor, var1, var2)
	if(not Valid(actor, "helcurt") or not PAlive(actor.player)) then
		return nil
	end
	
	-- P_Thurst(pla)
	Stinger(actor, var1, var2)
	local ownerspeed = FixedHypot(actor.momx, actor.momy)

	actor.ground_tic_cd = STINGER_GRND_COOLDOWN
	P_SetObjectMomZ(actor, 2*FRACUNIT, false)
	-- P_Thrust(actor, actor.player.inputangle, STINGER_HORIZ_BOOST/2)

	RemoveStingers(actor, MAX_STINGERS)
end

--Helcurt uses ground stinger
local function A_StingerGrnd2(actor, var1, var2)
	
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

--A stinger Projectile
mobjinfo[MT_STGP] = {
	spawnstate = S_NULL,
	deathstate = S_NULL,
	height = 64*FRACUNIT,
	radius = 32*FRACUNIT,
	flags = MF2_SUPERFIRE|MF_NOGRAVITY

}

-- The follow object (the cape and tail)
mobjinfo[MT_FOLLOW] = {
	spawnstate = S_FOLLOW_STAND,
	height = FRACUNIT,
	radius = FRACUNIT,
	dispoffset = 1,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_FLOAT|MF_NOGRAVITY
}


mobjinfo[MT_SHDW] = {
	spawnstate = S_SHDW_PRT,
	height = 16*FRACUNIT,
	radius = 8*FRACUNIT,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_FLOAT|MF_NOGRAVITY|MF_SCENERY
}

--[[
--A stinger Projectile
mobjinfo[MT_STGA] = {
	spawnstate = S_GHOST,
	deathstate = S_NULL,
	height = 1,
	radius = 1,
	flags = MF_NOGRAVITY
}
]]--

--A stinger hud Stack 
mobjinfo[MT_STGS] = {
	spawnstate = S_STACK,
	height = 4*FRACUNIT,
	radius = 4*FRACUNIT,
	deathstate = S_NULL,
	xdeathstate = S_NULL,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_FLOAT|MF_NOGRAVITY
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

states[S_STINGER_AIR_1] = {
	sprite = SPR_PLAY,
	frame = SPR2_FALL,
	action = A_StingerAir1,
	var1 = -ANGLE_90,
	var2 = S_AIR_1,
	tics = states[S_AIR_1].tics,
	nextstate = S_STINGER_AIR_2 
}

states[S_STINGER_GRND_1] = {
	sprite = SPR_PLAY,
	frame = SPR2_FALL,
	action = A_StingerGrnd1,
	var1 = ANGLE_157h,
	var2 = S_GRND_1,
	tics = states[S_GRND_1].tics,
	nextstate = S_STINGER_GRND_2 
}

states[S_STINGER_AIR_2] = {
	sprite = SPR_PLAY,
	frame = SPR2_STNG,
	action = A_StingerAir2,
	tics = 20,
	nextstate = S_PLAY_FALL
}

states[S_STINGER_GRND_2] = {
	sprite = SPR_PLAY,
	frame = SPR2_RUN_,
	action = A_StingerGrnd2,
	-- tics = states[S_GRND_2].tics,
	tics = 5,
	nextstate = S_PLAY_STND
}

--[[
states[S_BLADE_HIT] = {
	sprite = SPR_PLAY,
	frame = SPR2_BLDE,
	tics = 200,
	action = A_BladeHit,
	nextstate = S_PLAY_FALL
}

states[S_BLADE_LAUNCH] = {
	sprite = SPR_PLAY,
	frame = SPR2_LNCH,
	tics = 30,
	action = A_BladeLaunch,
	nextstate = S_PLAY_FALL
}
]]--

states[S_BLADE_THURST] = {
	sprite = SPR_PLAY,
	frame = SPR2_BLDE,
	tics = 2*TICRATE,
	action = A_BladeThrust,
	nextstate = S_PLAY_FALL
}

states[S_BLADE_THURST_HIT] = {
	sprite = SPR_PLAY,
	frame = SPR2_JUMP,
	tics = TICRATE,
	action = A_BladeThrustHit,
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

states[S_STACK] = {
	sprite = SPR_STGS,
	frame = FF_TRANS20,
	tics = -1
}

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

states[S_FOLLOW_STAND] = {
	sprite = SPR_FLWS,
	frame = FF_ANIMATE,
	var1 = 2, --Number of frames
	var2 = 7, --Tics before cycle to a new frame
	tics = -1
}

states[S_FOLLOW_RUN] = {
	sprite = SPR_FLWR,
	frame = FF_ANIMATE,
	var1 = 2, --Number of frames - 1
	var2 = 3, --Tics before cycle to a new frame
	tics = -1
}

--[[
states[S_LOCK] = {
	sprite = SPR_LOCK,
	tics = -1,
	nextstate = S_NULL
}
]]--

--[[
states[S_GHOST] = {
	sprite = SPR_STGA,
	frame = FF_FULLBRIGHT,
	tics = -1,
	nextstate = S_NULL
}
]]--

states[S_AIR_1] = {
	sprite = SPR_STGP,
	frame = FF_FULLBRIGHT|B,
	tics = 6,
	nextstate = S_AIR_2
}

states[S_AIR_2] = {
	sprite = SPR_STGP,
	frame = FF_FULLBRIGHT|B,
	tics = TICRATE,
	action = A_Air2,
	nextstate = S_GRND_2
}

--[[
states[S_AIR_3] = {
	sprite = SPR_STGP,
	frame = FF_FULLBRIGHT,
	tics = TICRATE,
	action = A_Air3,
	nextstate = S_NULL
}
]]--

states[S_GRND_1] = {
	sprite = SPR_STGP,
	frame = FF_FULLBRIGHT|A,
	tics = 10,
	nextstate = S_GRND_2
}

states[S_GRND_2] = {
	sprite = SPR_STGP,
	frame = FF_FULLBRIGHT|A,
	tics = TICRATE/2,
	action = A_Grnd2,
	nextstate = S_NULL
}