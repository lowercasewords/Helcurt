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
"S_BLADE_THURST", "S_BLADE_THURST_HIT", "S_STACK", "S_LOCK",
"S_AIR_1", "S_GRND_1", "S_AIR_2", "S_GRND_2", "S_AIR_3",
"S_STINGER_AIR_1", "S_STINGER_AIR_2", 
"S_STINGER_GRND_1", "S_STINGER_GRND_2")
freeslot("MT_STGP", "MT_STGS", "MT_LOCK")
freeslot("SPR2_STNG", "SPR2_BLDE", "SPR2_LNCH", "SPR_STGP", "SPR_STGS", "SPR_STGA", "SPR_LOCK")
freeslot("sfx_upg01", "sfx_upg02", "sfx_upg03", "sfx_upg04", "sfx_hide1",
"sfx_ult01", "sfx_ult02", "sfx_ult03", "sfx_trns1", "sfx_trns2", "sfx_blde1", "sfx_mnlg1",
"sfx_stg01", "sfx_stg02", "sfx_stg03", "sfx_stg04", "sfx_stg05")

--constants and functions used throghout the project (rest are defined in other files too)
rawset(_G, "SPAWN_RADIUS_MAX", 10)
--Anything below or equal to this tics counts as pressing a button once instead of holding it
rawset(_G, "TICS_PRESS_RANGE", 5)
rawset(_G, "SPAWN_TIC_MAX", 1)

rawset(_G, "TARGET_DMG_RANGE", MF_SHOOTABLE|MF_SOLID|MF_ENEMY|MF_BOSS|MF_MONITOR)--|MF_MONITOR|MF_SPRING)
rawset(_G, "TARGET_NONDMG_RANGE", MF_SPRING)
-- rawset(_G, "TARGET_KILL_RANGE", MT_POINTYBALL|MT_EGGMOBILE_BALL|MT_SPIKEBALL|MT_SPIKE|MT_WALLSPIKE|MT_WALLSPIKEBASE|MT_SMASHINGSPIKEBALL)
rawset(_G, "TARGET_IGNORE_RANGE", MF_MISSILE)
--Maximum amount of extra stingers (not counting the one you always have)
rawset(_G, "MAX_STINGERS", 4)
rawset(_G, "TELEPORT_SPEED", 70*FRACUNIT)
rawset(_G, "TELEPORT_STOP_SPEED", 3)

rawset(_G, "LENGTH_MELEE_RANGE", 100*FRACUNIT)
rawset(_G, "BLADE_THURST_SPEED", 15*FRACUNIT)
rawset(_G, "BLADE_THURST_JUMP", 4*FRACUNIT)
rawset(_G, "BLADE_FALL_SPEED", -FRACUNIT)
rawset(_G, "STINGER_VERT_BOOST", 10*FRACUNIT)
rawset(_G, "STINGER_HORIZ_BOOST", 15*FRACUNIT)
rawset(_G, "STINGER_GRND_COOLDOWN", TICRATE)
--Half of the stinger's angular trajectory a it needs to travel
rawset(_G, "HALF_AIR_ANGLE", ANGLE_135)
--Half of the stinger's angular trajectory a it needs to travel
rawset(_G, "HALF_GRND_ANGLE", ANG105-ANG20)
rawset(_G, "SEPARATION_AIR_ANGLE", ANGLE_45)
rawset(_G, "SEPARATION_GRND_ANGLE", ANG30)
--Extra vertical boost for helcurt when charging the stingers (before release)
rawset(_G, "EXTRA_CHARGE_BOOST", 10*FRACUNIT)
--Slow down Helcurt by this factor once when started charging stingers
rawset(_G, "CHARGE_SLOWDOWN_FACTOR", 3)

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

--------------------------
--/ THESE HOOKS ARE RAN FIRST
----------------------------/

--Handle needed variables on spawn
addHook("PlayerSpawn", function(player)
	if(not player.mo or not player.mo.skin == "helcurt")  then
		return
	end
	player.spinheld = 0 --Increments each tic it's held IN PRETHINK, use PF_SPINDOWN to get previous update
	player.jumpheld = 0 --Increments each tic it's held IN PRETHINK, use PF_JUMPDOWN to get previous update
	player.prevjumpheld = 0 --Value of jumpheld in previous tic
	player.prevspinheld = 0
	--Did player jump? Resets to 0 when hits the floor
	player.mo.hasjumped = 0

	player.mo.can_teleport = 0
	player.mo.teleported = 0
	player.mo.enhanced_teleport = 0

	player.mo.can_stinger = 0
	--Cooldown for a ground stinger cooldown
	player.mo.ground_tic_cd = 0 
	player.mo.stung = 0
	player.mo.stingers = 0
	player.mo.stinger_charge_countdown = -1
	player.mo.hudstingers = {} --keeping track of HUD elements that represent the string

	player.killcount = 0
	player.lockon = nil
	--Amount of extra stingers Helcurt has currently (not counting the current one)
	player.mo.isconcealed = 0
	
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
		if(not player.mo or not player.mo.valid or not player.mo.skin == "helcurt") then
			continue
		end

		--Not allow to move during these states
		if(player.mo.state == S_IN_TRANSITION or 
		player.mo.state == S_STINGER_GRND_1 or 
		player.mo.state == S_STINGER_GRND_2) then
			player.cmd.forwardmove = 0
			player.cmd.sidemove = 0
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

		
	--Detect voluntery jumping
		if(player.mo.state == S_PLAY_JUMP and player.mo.hasjumped == 0) then
			player.mo.hasjumped = 1
		elseif(player.mo.eflags&MFE_JUSTHITFLOOR ~= 0) then
			player.mo.hasjumped = 0
		end
	end
end)



--The Thinker that plays after other thikers,
--mostly used to clean up, record the previous state, 
--and jump and spin button holding
addHook("PostThinkFrame", function()
	for player in players.iterate() do
		if(not player.mo or not player.mo.valid or not player.mo.skin == "helcurt") then
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
								player.mo.x-player.mo.radius, 
								-- player.mo.y+player.mo.radius-player.mo.radius*i, 
								player.mo.y - (player.mo.radius*i) + (player.mo.radius/3) * MAX_STINGERS, 
								player.mo.z+player.mo.height, player.mo.angle)
			
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
		--[[
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
		]]--

		player.prevjumpheld = player.jumpheld
		player.prevspinheld = player.spinheld
		player.mo.prevstate = player.mo.state
	end
end)


--Determines how to handle the killing of targets
addHook("MobjDeath", function(target, inflictor, source, dmgtype)
	-- print("T: "..target.type)
	-- print("I: "..inflictor.type)
	-- print("S: "..source.type)
	-- print("D: "..dmgtype)

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

--[[
local function A_BladeLaunch(actor, par1, par2)
-- 	P_SetObjectMomZ(actor, -BLADE_THURST_JUMP, true)
-- 	P_Thrust(actor, actor.angle, BLADE_THURST_SPEED)
-- 	actor.can_bladeattack = false
	if(not actor and not actor.valid and not actor.player) then 
		return
	end
	--allow to break walls and boost springs
	actor.player.powers[pw_strong] = $|STR_BUST|STR_SPRING
	--Initial downwards momentum 
	P_SetObjectMomZ(actor, -5*FRACUNIT, true)
	
	-- --If spin is held while in blade attack mode, keep falling
	-- elseif(actor.player.spinheld >= 1 and actor.player.spinheld < TICRATE/2
	-- and actor.state == S_BLADE_LAUNCH) then
	-- 	P_SetObjectMomZ(actor, -FRACUNIT, true)
	-- end
	
end

local function A_BladeHit(actor, par1, par2)
	
end
]]--

---------------- CUSTOM OBJECT ACTIONS ---------------- 

--Action performed by a stinger when charging is complete in the air
local function A_Air2(actor, var1, var2)
	if(actor.target == nil or actor.target.player == nil) then
		return nil
	end
	--Point away from the player
	actor.angle = 
		ANGLE_180 + 
		R_PointToAngle2(actor.x, actor.y, actor.target.x, actor.target.y) -
		actor.target.angle +
		actor.target.player.inputangle

	--Fixed momentum change for the stinger
	P_SetObjectMomZ(actor, -STINGER_VERT_BOOST, false)
	P_Thrust(actor, actor.angle, STINGER_HORIZ_BOOST)

	--Contribute to the vertical boost of hte player
	P_SetObjectMomZ(actor.target, STINGER_VERT_BOOST/5, true)	

end

--Action performed by a stinger when charging is complete on the ground
local function A_Grnd2(actor, var1, var2)
	--Point away from the player
	-- actor.angle = actor.target.angle
	
	local forward = 150*FRACUNIT
	
	local c = cos(actor.target.angle) 
	local s = sin(actor.target.angle)
	
	local x = actor.target.x + FixedMul(forward, c) - FixedMul(0, s)
	local y = actor.target.y + FixedMul(0, c) + FixedMul(forward, s)

	actor.angle = R_PointToAngle2(actor.x, actor.y, x, y)

	--Fixed momentum change for the stinger
	P_Thrust(actor, actor.angle, STINGER_HORIZ_BOOST*2)
end

local function A_Air3(actor, var1, var2)
	local ownerspeed = FixedHypot(actor.momx, actor.momy)

	actor.angle = R_PointToAngle2(actor.x, actor.y, actor.target.x, actor.target.y)
	P_InstaThrust(actor, actor.angle, ownerspeed+STINGER_HORIZ_BOOST*2)
	
end

---------------- PLAYER ACTIONS ---------------- 


--Thursts in the direction of the movement input while canceling all vertical momentum
local function A_BladeThrust(actor, par1, par2)
	if(actor == nil or actor.player == nil or actor.player.inputangle == 0 or actor.player.inputangle == nil) then
		return
	end
	local ownerspeed = FixedHypot(actor.momx, actor.momy)
	-- P_InstaThrust(actor, actor.player.inputangle, ownerspeed/3+BLADE_THURST_SPEED)
	P_SetObjectMomZ(actor, BLADE_THURST_JUMP/2, false)
	P_InstaThrust(actor, actor.player.inputangle, ownerspeed/2+BLADE_THURST_SPEED)
	
	--Empower springs
	actor.player.powers[pw_strong] = $|STR_SPRING
end

local function A_BladeThrustHit(actor, par1, par2)
	if(actor == nil) then
		return 
	end
	local ownerspeed = FixedHypot(actor.momx, actor.momy)
	
	-- P_InstaThrust(actor, actor.player.inputangle, ownerspeed-BLADE_THURST_SPEED/2)
	P_Thrust(actor, actor.player.inputangle + ANGLE_180, ownerspeed/5)
	P_SetObjectMomZ(actor, 2*BLADE_THURST_JUMP, false)
	-- P_Thrust(actor, actor.player.inputangle, -BLADE_THURST_SPEED)
	-- actor.momx = $*cos(actor.angle)-BLADE_THURST_SPEED
	-- actor.momy = $*sin(actor.angle)-BLADE_THURST_SPEED

	--Recharge the stinger ability (technically just air stinger you're in the air)
	actor.can_stinger = 1
	actor.stung = 0

	--Allow to teleport
	actor.can_teleport = 1
	--Allow to performed an enhanced teleport
	actor.enhanced_teleport = 1
end

local function A_Pre_Transition(actor, par1, par2)
	actor.can_teleport = 0
	actor.teleported = 1
	S_StartSound(actor, sfx_trns1)
	actor.momz = $/10
	actor.momy = $/2
	actor.momx = $/2
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
-- 	actor.flags = $|MF_NOCLIPTHING
	-- print("in")
	
end

--End the transition
local function A_End_Transition(actor, par1, par2)
	S_StartSound(actor, sfx_trns2)
-- 	if(actor.player and actor.player.valid) then
		-- actor.can_bladeattack = true
-- 	end
	-- print("end!")
	actor.flags = $&~MF_NOCLIPTHING
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
	playmo.can_stinger = 0
	playmo.stung = 1
	-- print("Release "..playmo.stingers.." deadly stingers!")
	
	playmo.momx = $/CHARGE_SLOWDOWN_FACTOR
	playmo.momy = $/CHARGE_SLOWDOWN_FACTOR
	playmo.momz = $/CHARGE_SLOWDOWN_FACTOR
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


	--Reset stingers after usage
	RemoveStingers(playmo, MAX_STINGERS)
end

local function A_StingerAir1(actor, var1, var2)
	--Helcurt's when he started charging his stinger attack (that circly thing process around Helcurt)
	P_SetObjectMomZ(actor, EXTRA_CHARGE_BOOST, false)
	Stinger(actor, var1, var2)
end

local function A_StingerGrnd1(actor, var1, var2)
	-- P_Thurst(pla)
	Stinger(actor, var1, var2)
	local ownerspeed = FixedHypot(actor.momx, actor.momy)

	actor.ground_tic_cd = STINGER_GRND_COOLDOWN
	P_SetObjectMomZ(actor, 2*FRACUNIT, false)
	P_Thrust(actor, actor.player.inputangle, ownerspeed + STINGER_HORIZ_BOOST)
end

local function A_StingerAir2(actor, var1, var2)
	P_SetObjectMomZ(actor, STINGER_VERT_BOOST, false)
	P_Thrust(actor, actor.player.inputangle, STINGER_HORIZ_BOOST)
end

local function A_StingerGrnd2(actor, var1, var2)
	
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
	spawnstate = S_AIR_1,
	deathstate = S_NULL,
	height = 16*FRACUNIT,
	radius = 32*FRACUNIT,
	speed = 2*FRACUNIT,
	flags = MF_NOGRAVITY
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

--/--------------------------
--/ STATES
--/--------------------------


---------------- CUSTOM OBJECT STATES ---------------- 

states[S_STACK] = {
	sprite = SPR_STGS,
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
	nextstate = S_AIR_3
}

states[S_GRND_1] = {
	sprite = SPR_STGP,
	frame = FF_FULLBRIGHT|A,
	tics = 10,
	nextstate = S_GRND_2
}

states[S_GRND_2] = {
	sprite = SPR_STGP,
	frame = FF_FULLBRIGHT|A,
	tics = TICRATE,
	action = A_Grnd2,
	nextstate = S_NULL
}

states[S_AIR_3] = {
	sprite = SPR_STGP,
	frame = FF_FULLBRIGHT,
	tics = TICRATE,
	action = A_Air3,
	nextstate = S_NULL
}

---------------- PLAYER STATES ----------------

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
	tics = 10,
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
	frame = SPR2_STND,
	tics = 10*TICRATE,
	action = A_BladeThrust,
	nextstate = S_PLAY_FALL
}

states[S_BLADE_THURST_HIT] = {
	sprite = SPR_PLAY,
	frame = SPR2_RUN,
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