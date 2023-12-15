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
freeslot("sfx_trns1", "sfx_trns2", "sfx_blde1")

--constants and functions used throghout the project
rawset(_G, "SPAWN_RADIUS_MAX", 10)
rawset(_G, "SPAWN_TIC_MAX", 1)
rawset(_G, "TARGET_DMG_RANGE", MF_SHOOTABLE|MF_ENEMY|MF_BOSS|MF_MONITOR)--|MF_MONITOR|MF_SPRING)
rawset(_G, "TARGET_NONDMG_RANGE", MF_SPRING)
--The targets that the blade attack should register (not necessarily try to kill)
rawset(_G, "TARGET_RANGE", TARGET_DMG_RANGE|TARGET_NONDMG_RANGE)
rawset(_G, "MAX_STINGERS", 5)
rawset(_G, "TELEPORT_SPEED", 70*FRACUNIT)
rawset(_G, "TELEPORT_STOP_SPEED", 3)
rawset(_G, "LENGTH_MELEE_RANGE", 100*FRACUNIT)
rawset(_G, "X_BLADE_ATTACK_MOMENTUM", 5*FRACUNIT)
rawset(_G, "Z_BLADE_ATTACK_MOMENTUM", 8*FRACUNIT)

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

--------------------------
--/ THESE HOOKS ARE RAN FIRST
----------------------------/

--Handle needed variables on spawn
addHook("PlayerSpawn", function(player)
	player.spinheld = 0 --Increments each tic it's held IN POST THINK, use BT_SPIN to get current update
	player.jumpheld = 0 --Increments each tic it's held IN POST THINK, use BT_JUMP to get current update
	player.killcount = 0
	player.can_teleport = 1
	player.can_bladeattack = true
	player.can_stinger = true
	player.lockon = nil
	player.stingers = 0
	player.sting_timer = 0
	
	--DEPRECATED - Prevent changing to default particle color each time player respawns
	if(player.particlecolor == nil) then
		player.particlecolor = SKINCOLOR_DUSK
	end
end)

local debug_timer = 0
--The Base Thinker that plays before others,
--mostly used to record players input before interacting with the abilities
addHook("PreThinkFrame", function()
	for player in players.iterate() do
		if(not player.mo or not player.mo.valid or not player.mo.skin == "helcurt")
			continue
		end
		--Special input players input
		if(player.cmd.buttons & BT_CUSTOM1) then
			if(debug_timer == 1) then
				print("Kill count: "..player.killcount)
				print("Can stinger: "..tostring(player.can_stinger))
				print("Stingers: "..player.stingers)
				debug_timer = $+1
			else
				debug_timer = $+1
			end
		elseif(debug_timer > 0) then
			debug_timer = 0
		end
			
	-- 		print("D: "..debug_timer)

		
		--Gets the horizontal direction of inputs
		player.inputangle = player.cmd.angleturn*FRACUNIT + R_PointToAngle2(0, 0, player.cmd.forwardmove*FRACUNIT, -player.cmd.sidemove*FRACUNIT)
	-- 	player.mo.x = player.mo.x*cos(player.mo.angle) - player.mo.y*sin(player.mo.angle)
	-- 	player.mo.y = player.mo.x*cos(player.mo.angle) + player.mo.y*sin(player.mo.angle)
	end
end)

--The Thinker that plays after other thikers,
--mostly used to clean up and record the previous state
addHook("PostThinkFrame", function()
	for player in players.iterate() do
		if(not player.mo or not player.mo.valid or not player.mo.skin == "helcurt")
			continue
		end

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

		player.mo.prevstate = player.mo.state
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
-- 	actor.player.can_bladeattack = false

end

local function A_BladeHit(actor, par1, par2)
end

local function A_Pre_Transition(actor, par1, par2)
	actor.player.can_teleport = 0
	S_StartSound(actor, sfx_trns1)
	actor.momz = $/10
	actor.momy = $/2
	actor.momx = $/2
end

--Start the teleportation transition
local function A_Start_Transition(actor, par1, par2)
-- 	actor.flags = $|MF_NOCLIPTHING
-- 	actor.angle = actor.player.inputangle
-- 	actor.player.can_teleport = false
-- 	actor.player.can_bladeattack = true
	
	P_InstaThrust(actor, actor.angle, TELEPORT_SPEED)
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
		-- actor.player.can_bladeattack = true
-- 	end
	print("end!")
	actor.flags = $&~MF_NOCLIPTHING
	actor.momy = $/TELEPORT_STOP_SPEED
	actor.momx = $/TELEPORT_STOP_SPEED
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
	-- scale = 3*FRACUNIT,
	-- followitem = MT_PLAYER,
	deathstate = S_NULL,
	-- xdeathstate = S_NULL,
	speed = 50*FRACUNIT,
	flags = MF_MISSILE|MF2_SUPERFIRE|MF_NOGRAVITY
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
	tics = 6,
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