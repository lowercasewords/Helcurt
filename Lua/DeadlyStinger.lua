-------------------------------------
--- This file defines behavior for the Deadly Stinger abilitiy
--- And yes, as of typing it these abilities don't rely much on actions, so most functionality is here
-------------------------------------

------------------------------------
---CONSTANTS
-------------------------------------

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
	if(player.mo.state == S_BLADE_HIT and (not (player.cmd.buttons & BT_SPIN)) and player.spinheld > 10)-- and player.mo.stingers > 0)
	-- if(player.mo.state == S_PRE_TRANSITION and player.cmd.buttons & BT_SPIN)-- and player.mo.stingers > 0)
		-- if(player.cmd.buttons & BT_SPIN)
			
		-- print("Release "..player.mo.stingers.." deadly stingers!")
		
		--Make sure capped stinger gives you same vertical boost as the one before cap, 
		--but additionally iproving your teleport
		local adj_stingers = player.mo.stingers
		if(player.mo.stingers == MAX_STINGERS) then
			adj_stingers = $-1
			print("make enhanced")
			player.mo.enhanced_teleport = 1
			-- states[S_PRE]
		end
		
		--Player's vertical boost
		P_SetObjectMomZ(player.mo, FixedSqrt(adj_stingers*(100*FRACUNIT)), false)
		
		--Releasing damaging stingers one by one
		local angle = player.mo.angle - FixedAngle((player.mo.stingers-1)*STINGER_ANGLE_ADJ/2)
		for i = 1, player.mo.stingers, 1 do
			if(i ~= 1) then
				angle = $+FixedAngle(STINGER_ANGLE_ADJ)
			end
			local stinger = SpawnDistance(player.mo.x, player.mo.y, player.mo.z, 0, angle, MT_STGP)
			stinger.target = player.mo
			stinger.homing = 0
			
			P_InstaThrust(stinger, angle, stinger.info.speed)
		end

		--Reset stingers after usage
		RemoveStingers(player.mo, MAX_STINGERS)
		player.mo.can_teleport = 1
		player.can_bladeattack = true
	end
	
	--Loose a stinger when the chain is broken (hit the floor)
	--[[
	if(player.mo.stingers > 0 and player.mo.eflags & MFE_JUSTHITFLOOR) then
		player.mo.stingers = $-1
	end
	]]--
end)

--Handle the Stinger Projectile
addHook("MobjThinker", function(stinger)
	if(not stinger or not stinger.valid) then
		return
	end
	--Do not lock-on if already locked-n
	if(stinger.homing == 0) then
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
	if(player.spinheld >= 10 and player.can_stinger and player.mo.stingers > 0 and P_IsObjectOnGround(player.mo)) then
 		player.can_bladeattack = false
		player.can_stinger = false
		
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

