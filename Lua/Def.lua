--/--------------------------
--/ 
--/ Defines freeslots, actions, and hooks that have to run BEFORE anyhing else.
--/ Make sure the index of the file is set to 0 before other files
--/ 
--/ SIDENOTE: Mod is not designed for Helcurt to be a bot, at least not yet. It still can be one 
--/ but don't expect anything fancy!
--/
--/--------------------------

freeslot("S_PRE_TRANSITION", "S_START_TRANSITION", "S_IN_TRANSITION","S_END_TRANSITION",
"S_BLADE_HIT", "S_BLADE_ATTACK", "S_STINGER_LAUNCH", "S_STINGER_STACK", "S_LOCK")
freeslot("MT_STGP", "MT_STGS", "MT_LOCK")
freeslot("SPR2_BLDE", "SPR2_LNCH", "SPR_STGP", "SPR_STGS", "SPR_LOCK")
freeslot("sfx_upg01", "sfx_upg02", "sfx_upg03", "sfx_upg04", 
"sfx_ult01", "sfx_ult02", "sfx_ult03", "sfx_trns1", "sfx_trns2", "sfx_blde1", "sfx_mnlg1")

--constants and functions used throghout the project (rest are defined in other files too)
rawset(_G, "SPAWN_RADIUS_MAX", 10)
rawset(_G, "SPAWN_TIC_MAX", 1)
rawset(_G, "TARGET_DMG_RANGE", MF_SHOOTABLE|MF_ENEMY|MF_BOSS|MF_MONITOR)--|MF_MONITOR|MF_SPRING)
rawset(_G, "TARGET_NONDMG_RANGE", MF_SPRING)
rawset(_G, "TARGET_IGNORE_RANGE", MF_MISSILE)
--The targets that the blade attack should register (not necessarily try to kill)
rawset(_G, "TARGET_RANGE", TARGET_DMG_RANGE|TARGET_NONDMG_RANGE)
rawset(_G, "MAX_STINGERS", 3)
rawset(_G, "TELEPORT_SPEED", 70*FRACUNIT)
rawset(_G, "TELEPORT_STOP_SPEED", 3)
rawset(_G, "LENGTH_MELEE_RANGE", 100*FRACUNIT)
rawset(_G, "X_BLADE_ATTACK_MOMENTUM", 5*FRACUNIT)
rawset(_G, "Z_BLADE_ATTACK_MOMENTUM", 8*FRACUNIT)

--Adds stingers to the (player's) helcurt mobject 
--mo (mobj_t): the mobject to add stingers
--amount (int): the number of stingers to add (won't exceed the limit)
rawset(_G, "AddStingers", function(mo, amount)
	--add a stinger if possible	
	if(mo and mo.stingers ~= nil and mo.skin == "helcurt") then
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
	if(mo and mo.stingers ~= nil and mo.skin == "helcurt") then
		for i = 1, amount, 1 do
			if(mo.stingers > 0) then
				mo.hudstingers[mo.stingers - 1].frame = $|FF_FULLDARK
				mo.stingers = $ - 1
			end 
		end
	end
end)

rawset(_G, "SpawnAfterImage", function(mo)
	if(not mo or not mo.valid) then
		return false
	end
-- 	print("Spawning image")
	local image = P_SpawnGhostMobj(mo) -- P_SpawnMobj(mo.x, mo.y, mo.z, mo.type)
	image.state = mo.state
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

--Function Written by clairebun and was given to use on SRB2 discord page
--mo1 (mobj_t): first mobj to check for collision
--mo2 (mobj_t): second mobj to check for collision
--returns: true if two mobjects collide vertically, false otherwise
rawset(_G, "L_ZCollide", function(mo1, mo2)
    if mo1.z > mo2.height+mo2.z then return false end
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

--------------------------
--/ THESE HOOKS ARE RAN FIRST
----------------------------/

--Handle needed variables on spawn
addHook("PlayerSpawn", function(player)
	player.spinheld = 0 --Increments each tic it's held IN PRETHINK, use PF_SPINDOWN to get previous update
	player.jumpheld = 0 --Increments each tic it's held IN PRETHINK, use PF_JUMPDOWN to get previous update
	player.prevjumpheld = 0 --Value of jumpheld in previous tic
	--Did player jump? Resets to 0 when hits the floor
	player.hasjumped = 0
	player.killcount = 0
	player.mo.can_teleport = 0
	player.mo.teleported = 0
	player.mo.enhanced_teleport = 0
	player.mo.can_bladeattack = true
	player.mo.can_stinger = true
	player.lockon = nil
	player.mo.stingers = 0
	player.sting_timer = 0
	player.mo.stinger_charge_countdown = -1
	player.mo.isconcealed = 0
	player.mo.hudstingers = {} --keeping track of HUD elements that represent the string
	
	-- if(player.night_timer ~= nil) then
	-- 	EndHelcurtNightBuff(originplayer)
	-- end
	
	if(player.night_timer ~= nil and player.night_timer ~= 0) then
		SPEED_BUG_PREVENTION(player)
	end
	player.night_timer = 0
	-- end
	
	--DEPRECATED - Prevent changing to default particle color each time player respawns
	if(player.particlecolor == nil) then
		player.particlecolor = SKINCOLOR_DUSK
	end


	for i = 0, MAX_STINGERS-1, 1 do
		-- player.mo.hudstingers[i] = P_SpawnMobjFromMobj(player.mo, 
		-- 											player.mo.radius/3-5*FRACUNIT, 
		-- 											player.mo.radius/3-((1-1)*32/2)*FRACUNIT, 
		-- 											player.mo.height, MT_STGS)
		--The spawn location doesn't matter because the object
		--will be constantly set to the desired location (locked to the player)
		player.mo.hudstingers[i] = P_SpawnMobjFromMobj(player.mo, 0,0,0,MT_STGS)
		player.mo.hudstingers[i].frame = $|FF_FULLDARK
	end
	
end)

local debug_timer = 0
--The Base Thinker that plays before others,
--mostly used to record players input  before interacting with the abilities
addHook("PreThinkFrame", function()
	for player in players.iterate() do
		if(not player.mo or not player.mo.valid or not player.mo.skin == "helcurt")
			continue
		end
		--Special input players input
		if(player.cmd.buttons & BT_CUSTOM1) then
			if(debug_timer == 1) then
				print("Kill count: "..player.killcount)
				print("Can stinger: "..tostring(player.mo.can_stinger))
				print("Stingers: "..player.mo.stingers)
				debug_timer = $+1
			else
				debug_timer = $+1
			end
		elseif(debug_timer > 0) then
			debug_timer = 0
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

	-- 		print("D: "..debug_timer)

		
		--Gets the horizontal direction of inputs
		player.inputangle = player.cmd.angleturn*FRACUNIT + R_PointToAngle2(0, 0, player.cmd.forwardmove*FRACUNIT, -player.cmd.sidemove*FRACUNIT)
	-- 	player.mo.x = player.mo.x*cos(player.mo.angle) - player.mo.y*sin(player.mo.angle)
	-- 	player.mo.y = player.mo.y*cos(player.mo.angle) + player.mo.x*sin(player.mo.angle)

		
		if(player.mo.state == S_PLAY_JUMP and player.hasjumped == 0) then
			player.hasjumped = 1
		elseif(player.mo.eflags&MFE_JUSTHITFLOOR ~= 0) then
			player.hasjumped = 0
		end
	end
end)

--The Thinker that plays after other thikers,
--mostly used to clean up, record the previous state, 
--and jump and spin button holding
addHook("PostThinkFrame", function()
	for player in players.iterate() do
		if(not player.mo or not player.mo.valid or not player.mo.skin == "helcurt")
			continue
		end
		
		--Setting positions of HUD stingers 
		for i = 0, MAX_STINGERS-1, 1 do
			--How Desired y-coordinate should depend on amount of maximum stingers 
			--So their position should be dependant on number of maximum stingers (in case we want to change it)
			--But right now it only works with 3 stingers because I neither have time nor skills :(
			--   1 
			--  1 2 
			-- 1 2 3

			CorrectRotationHoriz(player.mo.hudstingers[i], player.mo.x, player.mo.y,
			player.mo.x-player.mo.radius, player.mo.y+player.mo.radius-player.mo.radius*i, player.mo.z+player.mo.height, player.mo.angle)
			
			--[[
			Same as correct rotation horiz function, 
			P_MoveOrigin(player.mo.hudstingers[i], 
						player.mo.x-player.mo.radius, 
						player.mo.y+player.mo.radius-player.mo.radius*i, 
						player.mo.z+player.mo.height)
			
			Yaw(player.mo.hudstingers[i], player.mo.x, player.mo.y,player.mo.angle)
			]]--

			-- Pitch(player.mo.hudstingers[i], player.mo.x, player.mo.z, player.mo.angle)
		end
		--player.mo.y+player.mo.radius/4-((i-1)*32/2
		
		
		-- if(player.cmd.buttons & BT_SPIN) then
		-- 	player.spinheld = $+1
		-- elseif(player.spinheld ~= 0 and player.cmd.buttons ~= BT_SPIN) then
		-- 	player.spinheld = 0
		-- end
		-- if(player.cmd.buttons & BT_JUMP) then
		-- 	player.jumpheld = $+1
		-- elseif(player.jumpheld ~= 0 and player.cmd.buttons ~= BT_JUMP) then
		-- 	player.jumpheld = 0
		-- end

		player.prevjumpheld = player.jumpheld
		player.mo.prevstate = player.mo.state
	end
end)


--Determines how to handle the killing of targets
addHook("MobjDeath", function(target, inflictor, source, dmgtype)
	// 	print("T: "..target.type)
	// 	print("I: "..inflictor.type)
	// 	print("S: "..source.type)
	// 	print("D: "..dmgtype)

		--If Helcurt is the death source for targets in defined target-range (enemies, monitors, etc? NOT RINGS)
		if(not source or not source.valid or not source.skin or not source.skin == "helcurt" or not source.player
		or not target or not (target.flags & TARGET_DMG_RANGE)) then
			return nil
		end
		
		-- print(source.skin)
		if(target.flags & MF_ENEMY|MF_BOSS) then
			source.player.killcount = $+1
		end
	end)

--/--------------------------
--/ ACTIONS
--/--------------------------

local function A_StingerLaunch(actor, par1, par2)
-- 	print("ACTION!")
-- 	P_InstaThrust(actor, actor.angle, STINGER_LAUNCH_SPEED)
-- 	SpawnAfterImage(actor)
end

local function A_BladeAttack(actor, par1, par2)
-- 	P_SetObjectMomZ(actor, -Z_BLADE_ATTACK_MOMENTUM, true)
-- 	P_Thrust(actor, actor.angle, X_BLADE_ATTACK_MOMENTUM)
-- 	actor.can_bladeattack = false

end

local function A_BladeHit(actor, par1, par2)
end

local function A_Pre_Transition(actor, par1, par2)
	actor.can_teleport = 0
	actor.teleported = 1
	S_StartSound(actor, sfx_trns1)
	actor.momz = $/10
	actor.momy = $/2
	actor.momx = $/2
	if(actor.enhanced_teleport ~= nil and actor.enhanced_teleport == 1) then
		if(actor.state == S_PRE_TRANSITION) then
			actor.state = states[S_PRE_TRANSITION].nextstate
			
			actor.enhanced_teleport = 0
			print("enhanced!")
		end
	end
end

--Start the teleportation transition
local function A_Start_Transition(actor, par1, par2)
-- 	actor.flags = $|MF_NOCLIPTHING
-- 	actor.angle = actor.player.inputangle
-- 	actor.can_teleport = false
-- 	actor.mo.can_bladeattack = true
	
	-- if(player.night_timer > 0) then
	-- 	P_InstaThrust(actor, actor.angle, TELEPORT_SPEED * )
	-- end
	
	--Thrusts forward, increased with the nightfall.
	--NOTE: consider making teleport's speed relative to helcurt's, the faster he moves
	--the fastere teleport is, but give the teleport the base speed so that Helcurt can teleport
	--from stand still
	P_InstaThrust(actor, actor.angle, (actor.player.night_timer == 0 and TELEPORT_SPEED or TELEPORT_SPEED + TELEPORT_SPEED/3))
	P_SetObjectMomZ(actor, 0, false)
end

--Perform single time once in transition
local function A_In_Transition(actor, par1, par2)
-- 	print("IN)"
-- 	actor.flags = $|MF_NOCLIPTHING
end

--End the transition
local function A_End_Transition(actor, par1, par2)
	S_StartSound(actor, sfx_trns2)
-- 	if(actor.player and actor.player.valid) then
		-- actor.can_bladeattack = true
-- 	end
	-- print("end!")
	actor.flags = $&~MF_NOCLIPTHING
	actor.momy = $/TELEPORT_STOP_SPEED
	actor.momx = $/TELEPORT_STOP_SPEED


	--[[
	--Potential increase in horizontal momentum after teleportation through decreasing stopping power
	if(actor.enhanced_teleport and actor.enhanced_teleport ~= nil) then
		print("enhance!")
		actor.momy = $/(TELEPORT_STOP_SPEED/2)
		actor.momx = $/(TELEPORT_STOP_SPEED/2)
	else
		actor.momy = $/TELEPORT_STOP_SPEED
		actor.momx = $/TELEPORT_STOP_SPEED
	end
	-- actor.momy = $/(TELEPORT_STOP_SPEED-FixedMul(TELEPORT_STOP_SPEED, actor.enhanced_teleport))
	-- actor.momx = $/(TELEPORT_STOP_SPEED-FixedMul(TELEPORT_STOP_SPEED, actor.enhanced_teleport))

	actor.enhanced_teleport = 0
	]]--
end

--/--------------------------
--/ MOBJECT INFOS
--/--------------------------

mobjinfo[MT_LOCK] = {
	spawnstate = S_LOCK,
	deathstate = S_NULL,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_FLOAT|MF_NOGRAVITY
}
--A stinger Projectile
mobjinfo[MT_STGP] = {
	spawnstate = S_STINGER_LAUNCH,
	-- height = 32*FRACUNIT,
	-- radius = 16*FRACUNIT,
	
	-- followitem = MT_PLAYER,
	deathstate = S_NULL,
	-- xdeathstate = S_NULL,
	speed = 2*FRACUNIT,
	flags = MF2_SUPERFIRE|MF_NOGRAVITY|MF_NOBLOCKMAP
}

--A stinger hud Stack 
mobjinfo[MT_STGS] = {
	spawnstate = S_STINGER_STACK,
	height = 128*FRACUNIT,
	radius = 128*FRACUNIT,
	deathstate = S_NULL,
	xdeathstate = S_NULL,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_FLOAT|MF_NOGRAVITY
}

--/--------------------------
--/ SOUNDS
--/--------------------------

sfxinfo[sfx_trns1] = {
	singular = false,
	priority = 64
}

sfxinfo[sfx_trns2] = {
	singular = false,
	priority = 65
}

sfxinfo[sfx_blde1] = {
	singular = false,
	priority = 60
}
sfxinfo[sfx_mnlg1] = {
	singular = false,
	priority = 60
}

sfxinfo[sfx_ult01] = {
	singular = false,
	priority = 60
}

sfxinfo[sfx_ult02] = {
	singular = false,
	priority = 60
}

sfxinfo[sfx_ult03] = {
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


--/--------------------------
--/ STATES
--/--------------------------


states[S_STINGER_LAUNCH] = {
	sprite = SPR_STGP,
-- 	action = A_StingerLaunch,
-- 	action = A_CustomPower,
-- 	var1 = pw_strong,
-- 	var2 = STR_FLOOR,
	tics = 100,
	nexstate = S_NULL
}

states[S_STINGER_STACK] = {
	sprite = SPR_STGS,
	tics = -1
}

states[S_LOCK] = {
	sprite = SPR_LOCK,
	tics = -1,
	nextstate = S_NULL
}

states[S_BLADE_HIT] = {
	sprite = SPR_PLAY,
	frame = SPR2_BLDE,
	tics = 200,
	action = A_BladeHit,
	nextstate = SPR2_FALL
}

states[S_BLADE_ATTACK] = {
	sprite = SPR_PLAY,
	frame = SPR2_LNCH,
	tics = 30,
	action = A_BladeAttack,
	nextstate = SPR2_FALL
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
	action = A_In_Transition,
	nextstate = S_END_TRANSITION
}

states[S_END_TRANSITION] = {
	sprite = SPR_PLAY,
	frame = SPR2_FALL,
	tics = -1,
	action = A_End_Transition,
	nextstate = S_PLAY_FALL
}