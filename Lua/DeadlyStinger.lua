-------------------------------------
--- This file defines behavior for the Deadly Stinger abilitiy
--- And yes, as of typing it these abilities don't rely much on actions, so most functionality is here
-------------------------------------

------------------------------------
---CONSTANTS
-------------------------------------
local MAX_ANGLE = ANGLE_90
local MIN_ANGLE = -ANGLE_90
--Angle adjustment for each stinger at their spawn
local STINGER_ANGLE_ADJ = 10*FRACUNIT
--DEPRECATED
local STINGER_SPAWN_DISTANCE = -100	
--Maximum distance for the stinger to lock-on and track the enemy
local MAX_HOMING_DISTANCE = 100*FRACUNIT

addHook("PlayerThink", function(player)
	if(not player or not player.mo or player.mo.skin ~= "helcurt") then
		return
	end
	
	-- if(P_IsObjectOnGround(player.mo)) then
	-- 	player.mo.stingers = 2
	-- end

	--Using Deadly Stinger 
	-- if(player.mo.state == S_BLADE_HIT and (not (player.cmd.buttons & BT_SPIN)) and player.spinheld > 10)-- and player.mo.stingers > 0)
	-- if(player.mo.state == S_PRE_TRANSITION and player.cmd.buttons & BT_SPIN)-- and player.mo.stingers > 0)
	-- print(player.jumpheld)
	-- print(player.cmd.buttons&BT_JUMP)

	-- if(not P_IsObjectOnGround(player.mo) and player.mo.stingers > 0 and  player.jumpheld == 1) then
	-- if(not P_IsObjectOnGround(player.mo) and player.jumpheld == 1) then
	-- if(player.cmd.buttons & BT_SPIN)
	-- print(player.jumpheld == 0 and player.pflags&PF_JUMPDOWN ~= 0)

	

	-- if(player.mo.can_stinger == 1 and player.jumpheld == 0 and player.pflags&PF_JUMPDOWN ~= 0 and player.hasjumped) then

	--Following if-statement executes when jump is released after jump in the air
	-- if(player.mo.can_stinger == 1 and player.jumpheld <= TICS_TO_JUMPHOLD and player.cmd.buttons ~= BT_JUMP and player.hasjumped) then
	-- print(player.jumpheld == 0 and player.cmd.buttons&BT_JUMP == 0)

	-- print("J: "..player.jumpheld)
	-- print("P: "..player.prevjumpheld)

	--press, SELF RELEASE
	--press, press, SELF RELEASE
	--press, press, press, SELF RELEASE
	--press, press, press... TRIGGER PRESS (automatic release)

	--[[
	if(player.jumpheld == 0 and player.hasjumped and player.mo.can_stinger == 0) then
		player.mo.can_stinger = 1
		-- print(player.mo.momz)
	end
	]]--
	
	-- if(player.prevjumpheld <= TICS_TO_JUMPHOLD and player.prevjumpheld ~= 0 and player.jumpheld == 0 and 
	-- player.mo.can_stinger == 1 and player.hasjumped) then
	
	-- print("P: "..player.mo.angle)
	-- print("A: "..player.mo.angle - ANGLE_180)
	if(player.prevjumpheld <= TICS_TO_JUMPHOLD and player.prevjumpheld ~= 0 and 
	player.jumpheld == 0 and player.mo.can_stinger == 1 and player.mo.stingers > 0)
	
		--Using Deadly Stinger 	
		player.mo.can_stinger = 0
		-- print("Release "..player.mo.stingers.." deadly stingers!")
			
		--Make sure capped stinger gives you same vertical boost as the one before cap, 
		--but additionally iproving your teleport
		local adj_stingers = player.mo.stingers
		if(player.mo.stingers == MAX_STINGERS) then
			adj_stingers = $-1
			-- print("make enhanced")
			player.mo.enhanced_teleport = 1
			-- states[S_PRE]
		end
		
		--Player's vertical boost
		-- P_SetObjectMomZ(player.mo, FixedSqrt(adj_stingers*(100*FRACUNIT)), false)
		
		--Releasing damaging stingers one by one
		local angle = player.mo.angle - FixedAngle((player.mo.stingers-1)*STINGER_ANGLE_ADJ/2) + ANGLE_180
		-- local angle = player.mo.angle - ANGLE_180  -- - FixedAngle((player.mo.stingers-1)*STINGER_ANGLE_ADJ/2)
		for i = 1, player.mo.stingers, 1 do
			if(i ~= 1) then
				angle = $+FixedAngle(STINGER_ANGLE_ADJ)
			end
			local stinger = SpawnDistance(player.mo.x, player.mo.y, player.mo.z + player.mo.height, 0, angle, MT_STGP)
			stinger.target = player.mo
			stinger.homing = 0
			--Horizontal angle
			stinger.angle = player.mo.angle
			--Vertical counter relative to the player
			stinger.anglecounter = MAX_ANGLE
			--The number of the current stinger
			stinger.num = i 
			-- stinger.scale = 2*FRACUNIT
			
			-- P_InstaThrust(stinger, angle, stinger.info.speed)
			-- P_SetObjectMomZ(stinger, -stinger.info.speed/2, false)
			
		end

		--Reset stingers after usage
		RemoveStingers(player.mo, MAX_STINGERS)
		-- player.mo.can_teleport = 1
		player.mo.can_bladeattack = true
	end
	
	
		
	-- end
	
	--Loose a stinger when the chain is broken (hit the floor)
	--[[
	if(player.mo.stingers > 0 and player.mo.eflags & MFE_JUSTHITFLOOR) then
		player.mo.stingers = $-1
	end
	]]--

	if(player.mo.eflags&MFE_JUSTHITFLOOR) then
		player.mo.can_stinger = 1
	end
end)
--[[
--This thinker is used for correct following (not working 'cause idk how to iterate through mobjects)
addHook("PreThinkFrame", function()
	local num = 0
	for mapthing in mapthings.iterate do
		if(mapthing.mobj ~= nil and mapthing.mobj.type == MT_STGP) then
			num = $+1
		end
		print(num)
		-- if(i.mobj.type == MT_STGP) then
		-- 	num = $+1
		-- end
	end
end)
]]--

--Handle the Stinger Projectile
addHook("MobjThinker", function(stinger)
	
	
	if(not stinger or not stinger.valid) then
		return
	end
	
	--Basic visual properties
	stinger.frame = $|FF_FULLBRIGHT
	-- SpawnAfterImage(stinger)
	
	print(stinger.anglecounter)
	
	if(stinger.anglecounter >= MIN_ANGLE and stinger.anglecounter < MAX_ANGLE) then
		print('stop!')
		P_KillMobj(stinger)
		return
	end

	local pivotx = stinger.target.x
	local pivoty = stinger.target.y
	local pivotz = stinger.target.z + stinger.target.height/3

	local radius = stinger.target.radius*2

	--Currently turning coordinates (x is forward/backward, y is left/right, z is up/down)
	local x = pivotx --(FixedMul(radius, cos(stinger.anglecounter)) + stinger.target.x) + (FixedMul(radius, cos(stinger.anglecounter)) + stinger.target.x)
	local y = FixedMul(radius, cos(stinger.anglecounter)) + stinger.target.y
	local z = FixedMul(radius, sin(stinger.anglecounter)) + stinger.target.z
	CorrectRotationHoriz(stinger, pivotx, pivoty, x, y, z, stinger.target.angle)
	
	stinger.anglecounter = $+1*ANG1


	--Each rojectile must:
	--Spawn above the player (all of them in the same spot)
	--Circle around the player (player's center is the pivot point)
	--	Radius of the circle is shorter for some stingers
	--Shoot out in their respective directions downwards


	--Do not lock-on if already locked-n
	-- if(stinger.homing == 0) then
	if(false) then
		local enemy = nil
		local enemydistx = nil
		local enemydisty = nil
		local enemydistz = nil
		local enemydist3d = 0
		
		--Scan the area for the enemies
		searchBlockmap("objects", function(stinger_projectile, destmo)
			local distx = destmo.x - stinger_projectile.x
			local disty = destmo.y - stinger_projectile.y
			local distz = destmo.z - stinger_projectile.z
			local dist3d = FixedSqrt(abs(FixedMul(distx, distx) + FixedMul(disty, disty) + FixedMul(distz, distz)))

			-- print(FixedMul(distx, distx) + FixedMul(disty, disty) + FixedMul(distz, distz))
			if((destmo.flags & TARGET_DMG_RANGE) and (destmo.flags & MF_MISSILE ~= MF_MISSILE)
			and destmo ~= stinger_projectile.target 
			and (enemydist3d == 0 or enemydist3d >= dist3d) 
			and (destmo.stingerhoming == nil or destmo.stingerhoming == 0)) then
				-- print(enemydist3d/FRACUNIT.." = "..dist3d/FRACUNIT)
				enemydistx = distx
				enemydisty = disty
				enemydistz = distz
				enemydist3d = dist3d
				enemy = destmo
				
				-- print("m:"..MAX_HOMING_DISTANCE/FRACUNIT.."\nd:"..dist/FRACUNIT)
				-- print("x:"..distx/FRACUNIT.."\ny:"..disty/FRACUNIT.."\nz:"..distz/FRACUNIT)
			end
		end, stinger, stinger.x-500*FRACUNIT, stinger.x+500*FRACUNIT, stinger.y-500*FRACUNIT, stinger.y+500*FRACUNIT)

		--Move towards the enemy
		if(enemydist3d ~= 0 and MAX_HOMING_DISTANCE >= enemydist3d) then
			-- print(MAX_HOMING_DISTANCE/FRACUNIT.." vs "..enemydist3d/FRACUNIT)
			stinger.homing = 1
			enemy.stingerhoming = 1

			local time = FixedMul(FixedDiv(stinger.info.speed, enemydist3d), TICRATE) --THIS IS WRONG
			stinger.momx = enemydistx/time
			stinger.momy = enemydisty/time
			stinger.momz = enemydistz/time
			-- print("Time:"..time)
			-- print("Speed:"..FixedSqrt(abs(FixedMul(stinger.momx, stinger.momx) + 
			-- FixedMul(stinger.momy, stinger.momy) + FixedMul(stinger.momz, stinger.momz)))/FRACUNIT)			
		end
	end
end, MT_STGP)



--Handle the Stinger Projectile damage registration (damage itself is performed through MF_MISSILE flag)
addHook("MobjDamage", function(target, inflictor, source, damage, damagetype)
	-- if(not inflictor.skin == "helcurt" or not source or not source.valid or not source) then
	-- 	return
	-- end
	--Pass through only if helcurt damages targets in damage-range with the stinger 
	if(not inflictor.skin == "helcurt" or not source or not source.valid or not source.player
	or not source.player.target == inflictor or not target or not (target.flags & TARGET_DMG_RANGE)) then
			return nil
		end
	AddStingers(source, 1)

end)


addHook("SpinSpecial", function(player)
	if(not player or not player.mo or player.mo.skin ~= "helcurt") then
		return
	end

	--[[
	--Perform Deadly Stinger Attack!
	if(player.spinheld >= 10 and player.mo.can_stinger and player.mo.stingers > 0 and P_IsObjectOnGround(player.mo)) then
 		player.mo.can_bladeattack = false
		player.mo.can_stinger = false
		
		local angle = player.mo.angle - FixedAngle((player.mo.stingers-1)*STINGER_ANGLE_ADJ/2)
		
		for i = 1, player.mo.stingers, 1 do
			if(i ~= 1) then
				angle = $+FixedAngle(STINGER_ANGLE_ADJ)
			end
			local stinger = SpawnDistance(player.mo.x, player.mo.y, player.mo.z, STINGER_SPAWN_DISTANCE, angle, MT_STGP)
			stinger.target = player.mo
			P_InstaThrust(stinger, stinger.angle, stinger.info.speed)
		end
		player.mo.stingers = 0
	end
	]]--
end)

