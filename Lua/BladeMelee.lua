-------------------------------------
--- This file defines behavior for the Blade Attack abilities performed in the air
--- And yes, as of typing it these abilities don't rely much on actions, so most functionality is here
-------------------------------------

--Horiontal offset for blade lock-on block searching 
-- local BLADE_BLOCK_SEARCH = 1000*FRACUNIT
--Horizontal distance at which the blade lock-on will lock on the target
local BLADE_LOCK_HORIZ_DISTANCE = 150*FRACUNIT
--Vertical distance at which the blade lock-on will lock on the target
local BLADE_LOCK_VERT_DISTANCE = 100*FRACUNIT
--Vertical boost after a successful blade attack to enable combos
local BLADE_VERT_BOOST = 6*FRACUNIT
--Vertical lockon spawn multipler offset to appear above the target
local LOCK_HEIGHT_MUL = 2
--Range system used in searchblock function to find targets
local BLADE_BLOCK_SEARCH = 100*FRACUNIT
--Maximum distance between enemy and Helcurt for latter to blade attack 
local BLADE_HIT_DISTANCE = 100*FRACUNIT

--/--------------------------
--/ Functinos
--/--------------------------
--[[
--Removes the lockon HUD from the existance
--player (player_t): the player whose lockon HUD should be removed
--returns: nil
local function StopLockOn(player)
	if(player.lockon and player.lockon.valid) then
		if(player.lockon.locktarget) then
			player.lockon.locktarget = nil
		end
		P_KillMobj(player.lockon)
		player.lockon = nil
	end
end


--Spawns a lockon above the lock target
--Notice that the player keeps the reference of the lockon HUD and lockon HUD keeps the reference of its lock target
--target (mobj_t): the lockon target
--player (mobj_t): the player that locks on the target
--returns: ??? NO DECIDED YET
local function SpawnLockOn(target, player)
	if(target.valid and target.health ~= 0 and target.flags&TARGET_IGNORE_RANGE == 0 and target.flags&TARGET_RANGE) then
		--Remove previous lockon since there can only be one
		StopLockOn(player)
		--spawn lockon and keep reference
		player.lockon = P_SpawnMobj(target.x, target.y, target.z + target.height*LOCK_HEIGHT_MUL, MT_LOCK)
		player.lockon.locktarget = target
	end
end
]]--

--Checks if the target is in the lockon range of the player 
--pmo (mobj_t): the player mobject initiating the lockon
--targetmo (mobj_t): the target mobject the lockon is performed on
--returns: true if target is is the lockon range of the player, false otherwise
local function LockDistanceCheck(pmo, targetmo)
	return pmo and pmo.valid and targetmo and targetmo.valid and 
		targetmo.flags & TARGET_RANGE and
		R_PointToDist2(pmo.x, pmo.y, targetmo.x, targetmo.y) <= BLADE_LOCK_HORIZ_DISTANCE and
		abs(targetmo.z - pmo.z) <= BLADE_LOCK_VERT_DISTANCE
end

--[[
--Handles Blade Damage 
--target (mobj_t): the damage receiver
--player (plzyer_t): the damage sender
-- returns: nil
local function BladeDamage(target, player)
	if(target.flags & TARGET_DMG_RANGE | ~TARGET_IGNORE_RANGE) then
		if(target.spawnhealth == nil) then
			P_KillMobj(target, player.mo, player.mo)
		else
			P_DamageMobj(target, player.mo, player.mo, 1)
		end
	end
	
	--start hitting state
	player.mo.prevstate = player.mo.state
	player.mo.state = S_BLADE_HIT
	
	--restore both teleport and blade attack
	-- player.mo.can_teleport = true
	player.mo.can_bladeattack = true
	
	--after-hit boost to grand momentum for combos or traversal
	P_SetObjectMomZ(player.mo, BLADE_VERT_BOOST, false)
	S_StartSound(player.mo, sfx_blde1, player)
	
	AddStingers(player.mo, 1)
	
	--remove the lockon
	StopLockOn(player)
end
]]--

--/--------------------------
--/ HOOKS
--/--------------------------

--[[
--Defines the movement of the lockon HUD
addHook("MobjThinker", function(molock)
	if(molock.valid and molock.locktarget and molock.locktarget.valid) then
		P_SetOrigin(molock,
		 molock.locktarget.x, 
		 molock.locktarget.y, 
		 molock.locktarget.z + molock.locktarget.height*LOCK_HEIGHT_MUL)
		
	--Supposed to kill itself if target lost, but it needs a player to do it1
	-- elseif(molock.valid and (not molock.locktarget or not molock.locktarget.valid)) then
	-- 	StopLockOn(???)
		
	end
end, MT_LOCK)

addHook("SpinSpecial", function(player)
	if(not player or not player.mo or player.mo.skin ~= "helcurt") then
		return
	end
	--Perform a Blade Attack!
	if(player.spinheld == 1 
	and player.mo.state ~= S_BLADE_LAUNCH 
	and player.mo.can_bladeattack 
	and not P_IsObjectOnGround(player.mo)) then
		player.mo.prevstate = player.mo.state
		player.mo.state = S_BLADE_LAUNCH
	end
end)


--Don't get damaged while damaging
addHook("ShouldDamage", function(mo, inflictor) 
	if(not mo or not mo.valid or not mo.player or mo.skin ~= "helcurt") then
		return nil
	end
	
	--Don't get damaged whlie performing a Blade Attack
	if(mo.state == S_BLADE_LAUNCH and inflictor.flags & TARGET_DMG_RANGE) then
		return false
	end
end, MT_PLAYER)


--Decides/tries to damage the target when Helcurt collides with it
addHook("MobjMoveCollide", function(playmo, target)
	if(not playmo or not playmo.valid or not playmo.skin or not playmo.skin == "helcurt" or not playmo.player) then
		return nil
	end
	--Hit the target if attacking with blades and stop attacking furthermore
	if(playmo.state == S_BLADE_LAUNCH 
	and L_ZCollide(target, playmo) 
	and target.flags & TARGET_DMG_RANGE) then
		BladeDamage(target, playmo.player)
	end
end, MT_PLAYER)


--Handles removal of lock HUD
addHook("MobjDeath", function(molock)
	-- molock.player.molock = nil
	-- molock = nil
end, MT_LOCK)
]]--

addHook("PlayerThink", function(player)
	if(not player or not player.mo.valid or not player.mo or player.mo.skin ~= "helcurt") then
		return
	end

	--Activate only in the air if pressing or holding spin
	if(player.mo.hasjumped == 1 and player.spinheld ~= 0 and not P_IsObjectOnGround(player.mo)) then
		if(player.mo.state == S_BLADE_FALL) then
			print(player.mo.momy)
		end
		--switch to blade falling state once
		if(player.mo.state ~= S_BLADE_FALL and player.mo.state ~= S_BLADE_THURST and 
		player.cmd.forwardmove == 0 and player.cmd.sidemove == 0) then
			player.mo.prevstate = player.mo.state
			player.mo.state = S_BLADE_FALL
		--switch to blade thrusting state once
		elseif(player.mo.state ~= S_BLADE_THURST and player.mo.hasbthrusted == 0 and 
		(player.cmd.forwardmove ~= 0 or player.cmd.sidemove ~= 0)) then
			player.mo.prevstate = player.mo.state
			player.mo.state = S_BLADE_THURST
		end
	--Canceling the blade thrusting or blade falling
	elseif(player.spinnheld == 0 and (player.mo.state == S_BLADE_FALL or player.mo.state == S_BLADE_THURST)) then
		player.mo.prevstate = player.mo.state
		player.mo.state = states[$].nextstate
	end
	--Search for enemies to kill (Doesn't interupt the state)
	if(player.mo.state == S_BLADE_THURST or player.mo.state == S_BLADE_FALL) then
		--Search and filter through objects in small range to (hopefully) find the target
		searchBlockmap("objects", function(playmo, checkmo)
		--Gettings the horizontal distance between the stinger and currently scanning enemy
		local distcheck = R_PointToDist2(playmo.x,playmo.y,checkmo.x,checkmo.y)
		
		--[[
		--LOOKHERE:::::::: This thing overflows and malfunctions which is why it needs abs values for, it works but 
		--should probably check for melee range values
		local distcheck = 
		FixedSqrt(abs(
			FixedMul(checkmo.x - playmo.x, checkmo.x - playmo.x) + 
			FixedMul(checkmo.y - playmo.y, checkmo.y - playmo.y) + 
			FixedMul(checkmo.z - playmo.z, checkmo.z - playmo.z)))
		]]--
		--Damage the enemy and enter a state of hitting an enemy only if the target is valid and in the hit distance in all 3 directions
		if(distcheck < BLADE_HIT_DISTANCE and L_ZCollide(playmo, checkmo, BLADE_HIT_DISTANCE-checkmo.height) 
		and checkmo.flags & TARGET_DMG_RANGE ~= 0 and checkmo.flags & TARGET_IGNORE_RANGE == 0) then
			P_DamageMobj(checkmo, player.mo, player.mo, 1)
			playmo.prevstate = playmo.state 
			playmo.state = S_BLADE_THURST_HIT
			return true
		end
		end, 
		player.mo, 
		player.mo.x-BLADE_BLOCK_SEARCH, 
		player.mo.x+BLADE_BLOCK_SEARCH, 
		player.mo.y-BLADE_BLOCK_SEARCH, 
		player.mo.y+BLADE_BLOCK_SEARCH)
	end

	--Ignore horizontal movement while thrusting
	if(player.mo.state == S_BLADE_THURST) then
		P_SetObjectMomZ(player.mo, 0, false)
	end

	--Recharge when hit the floor
	if(player.mo.eflags&MFE_JUSTHITFLOOR ~= 0) then
		player.mo.hasbthrusted = 0
	end
	

	-- print("f:"..player.cmd.forwardmove)
	-- print("s:"..player.cmd.sidemove)
	

	--[[
	--Stop the attacking state if released the spin
	if(player.spinheld == 0 and player.mo.state == S_BLADE_LAUNCH) then
		--print(player.mo.momz)

		player.mo.prevstate = player.mo.state 
		player.mo.state = states[S_BLADE_LAUNCH].nextstate
	end
	]]--
	--[[
	--Lock-on behavior
	local target = nil
	if(not P_IsObjectOnGround(player.mo) and player.mo.can_bladeattack) then
		--Tries to find the target to lock-on
		searchBlockmap("objects", function(mo, mfound)
			if(LockDistanceCheck(mo, mfound) and mfound.health ~= 0) then
				--Lockon on single existing target
				if(target == nil) then
					target = mfound
				--Lock-on the closest target
				elseif(R_PointToDist2(mo.x, mo.y, mfound.x, mfound.y) < R_PointToDist2(mo.x, mo.y, target.x, target.y)) then
					target = mfound
				end
			end
		end, player.mo, player.mo.x - BLADE_BLOCK_SEARCH, player.mo.x + BLADE_BLOCK_SEARCH,
		player.mo.y - BLADE_BLOCK_SEARCH, player.mo.y + BLADE_BLOCK_SEARCH)
	end

	if(target ~= nil) then
		SpawnLockOn(target, player)
	end

	--Performs a homing attack on the lockon target if any
	if(player.mo.can_bladeattack and 
	player.mo.state == S_BLADE_LAUNCH 
	and player.lockon and player.lockon.valid 
	and player.lockon.locktarget and player.lockon.locktarget.valid) then
		player.mo.can_bladeattack = false
		P_MoveOrigin(player.mo, 
					player.lockon.locktarget.x, 
					player.lockon.locktarget.y, 
					player.lockon.locktarget.z + player.lockon.locktarget.height*(3/2))
	end

	--Removal of the lock HUD if target is no longer in range
	if(player.lockon and player.lockon.valid 
	and player.lockon.locktarget and player.lockon.locktarget.valid 
	and not LockDistanceCheck(player.mo, player.lockon.locktarget)) then
		StopLockOn(player)
	end

-- 	--dissallow to break walls and boost springs
-- 	if(player.mo.prevstate == S_BLADE_LAUNCH) then--) or
-- 		if(player.mo.state ~= S_BLADE_LAUNCH) then
-- 			print("prevent")
-- 			player.powers[pw_strong] = ~STR_FLOOR|~STR_SPRING
-- 		end
-- 	end

	--Reset cooldown when land on the floor
	if(player.mo.eflags & MFE_JUSTHITFLOOR 
	or (player.mo.prevstate == S_BLADE_LAUNCH and player.mo.state == S_BLADE_HIT)) then
		player.mo.can_bladeattack = true
		player.powers[pw_strong] = $&~STR_FLOOR&~STR_SPRING
		StopLockOn(player)
	end
	]]--
end)
