-------------------------------------
--- This file defines behavior for the Deadly Stinger abilitiy
--- And yes, as of typing it these abilities don't rely much on actions, so most functionality is here
-------------------------------------

------------------------------------
---CONSTANTS
-------------------------------------

--Extra vertical boost for helcurt when charging the stingers (before release)
local EXTRA_CHARGE_BOOST = 10*FRACUNIT
--Slow down Helcurt by this factor once when started charging stingers
local CHARGE_SLOWDOWN_FACTOR = 3
local STINGER_VERT_BOOST = 10*FRACUNIT
local STINGER_HORIZ_BOOST = 15*FRACUNIT
--[[
local MAX_ANGLE = ANGLE_90
local MIN_ANGLE = -ANGLE_67h--ANGLE_90
]]--
local START_ANGLE = -ANGLE_90
local END_ANGLE = ANGLE_67h--ANGLE_90
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


	--FOR REAL BUGGY IF-STATEMENT
	if(player.prevjumpheld <= TICS_TO_JUMPHOLD and player.prevjumpheld ~= 0 and 
	player.jumpheld == 0 and player.mo.can_stinger == 1 and player.mo.stingers > 0) then
	
		--Using Deadly Stinger 	
		player.mo.can_stinger = 0
		-- print("Release "..player.mo.stingers.." deadly stingers!")
		
		--[[
		--Make sure capped stinger gives you same vertical boost as the one before cap, 
		--but additionally iproving your teleport
		local adj_stingers = player.mo.stingers
		if(player.mo.stingers == MAX_STINGERS) then
			adj_stingers = $-1
			-- print("make enhanced")
			player.mo.enhanced_teleport = 1
			-- states[S_PRE]
		end
		-- P_SetObjectMomZ(player.mo, FixedSqrt(adj_stingers*(100*FRACUNIT)), false)
		]]--
		
		--Helcurt's when he started charging his stinger attack (that circly thing process around Helcurt)
		player.mo.state = S_PLAYER_CHARGE
		P_SetObjectMomZ(player.mo, EXTRA_CHARGE_BOOST, false)
		player.mo.momx = $/CHARGE_SLOWDOWN_FACTOR
		player.mo.momy = $/CHARGE_SLOWDOWN_FACTOR
		player.mo.momz = $/CHARGE_SLOWDOWN_FACTOR

		-- local angle = player.mo.angle - FixedAngle((player.mo.stingers-1)*STINGER_ANGLE_ADJ/2) + ANGLE_180
		-- local angle = player.mo.angle - ANGLE_180  -- - FixedAngle((player.mo.stingers-1)*STINGER_ANGLE_ADJ/2)
		
		--Spawning each of his available stingers
		for i = 1, player.mo.stingers, 1 do
			--[[
			USELESS since stingers would be immediately relocated
			if(i ~= 1) then
				angle = $+FixedAngle(STINGER_ANGLE_ADJ)
			end
			local stinger = SpawnDistance(player.mo.x, player.mo.y, player.mo.z + player.mo.height, 0, angle, MT_STGP)
			]]--
			--Spawn location doesn't really matter because it would immediately be displaced with no regards to its position
			local stinger = P_SpawnMobj(player.mo.x, player.mo.y, player.mo.z, MT_STGP)
			stinger.target = player.mo --object that "shot" a stinger			
			stinger.homing_enemy = nil --Is a stinger locked-on to a target
			stinger.rollcounter = START_ANGLE --Vertical counter relative to the player
			stinger.num = i --The number of the current stinger
			stinger.released = player.mo.stingers --How many stingers were released (not the best way to do it I know but it works just fine)
			--[[
			--Horizontal angle
			stinger.angle = player.mo.angle
			]]--
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

--Handle's the clean-up of stinger's object removal
addHook("MobjRemoved", function(stinger)
	if(not stinger.valid) then
		return nil	
	end

	--Allow other stingers to home-in onto target that was
	--homed-in by this stinger
	if(stinger.homing_enemy ~= nil and stinger.homing_enemy.valid and stinger.homing_enemy.homing_source ~= nil and stinger.homing_enemy.homing_source.valid) then
		stinger.homing_enemy.homing_source = nil
	end

end, MT_STGP)
	
--[[
	PERFORMED BY ADDING MF_MISSILE FLAG TO THE STINGER, so this code is obsolete :3

--Defines behavior when a stinger collides with an object
addHook("MobjMoveCollide", function(stinger, object)
	if(not stinger.valid or not object.valid) then
		return nil	
	end

	--Damage if colided with an enemy
	if(object.flags&TARGET_DMG_RANGE ~= 0 and object.flags&TARGET_IGNORE_RANGE == 0) then
		-- P_DamageMobj(object, stinger, stinger.target)
	end

end, MT_STGP)
]]--
--Handle the Stinger Projectile
addHook("MobjThinker", function(stinger)
	
	
	if(not stinger or not stinger.valid) then
		return
	end
	
	--Basic visual properties
	stinger.frame = $|FF_FULLBRIGHT
	SpawnAfterImage(stinger)
	
	--Charging behavior 
	if(stinger.state == S_STINGER_CHARGE) then

		--Finish charging when traveled half a circle around Helcurt
		-- if(stinger.rollcounter >= END_ANGLE and stinger.rollcounter < START_ANGLE) then
		if(stinger.rollcounter < START_ANGLE) then
			stinger.state = S_STINGER_THURST

			--Owner of the stinger
			local ownerspeed = FixedHypot(stinger.target.momx, stinger.target.momy)
			-- P_Thrust(stinger, stinger.target.angle, ownerspeed)

			--Point away from the player
			stinger.angle = 
				ANGLE_180 + 
				R_PointToAngle2(stinger.x, stinger.y, stinger.target.x, stinger.target.y) -
				stinger.target.angle +
				stinger.target.player.inputangle

			--Fixed momentum change for the stinger
			P_SetObjectMomZ(stinger, -STINGER_VERT_BOOST, false)
			P_Thrust(stinger, stinger.angle, STINGER_HORIZ_BOOST)
			
			--Helcurt's movement behavior during the thurst of stingers (performed only once even though it is a stinger thinker)
			if(stinger.num == stinger.released and not P_IsObjectOnGround(stinger.target)) then
			P_SetObjectMomZ(stinger.target, STINGER_VERT_BOOST, false)
			P_Thrust(stinger.target, stinger.target.player.inputangle, STINGER_HORIZ_BOOST)
				-- P_SetObjectMomZ(stinger.target, FixedSqrt(stinger.released*(100*FRACUNIT), false))
				-- P_SetObjectMomZ(stinger.target, STINGER_VERT_BOOST+stinger.released*STINGER_VERT_BOOST, false)
				-- if(stinger.target.player ~= nil) then
				-- P_InstaThrust(stinger.target, stinger.target.player.inputangle, STINGER_HORIZ_BOOST)--*stinger.released)
				-- end
				-- stinger.target.can_stinger = 1
			end	
			
			return
		end
		
		local pivotx = stinger.target.x
		local pivoty = stinger.target.y
		local pivotz = stinger.target.z + stinger.target.height/3

		local radius = stinger.target.radius*2
		
		--[[
		180
		180+45	 	180+45
		180+45		180		 180+45
		180+45+45   180+45	 180+45	   180+45+45
		180+45+45   180+45	 180	   180+45	  180+45+45

		0
			0+45	 	
		0		 0+45		
			0+45		 0+45+45
		0		 0+45			 0+45+45

				1
			2	  2
			2	1	2
		3	  2	  2	  3
		3	2	1	2	3
		]]--
		--Circle's around the player where's stinger's location is reset (I forgot how I did it but it works AHHAAHAHAHAHAHAAHAH)
		--[[
		local x = FixedMul(FixedMul(radius, cos(stinger.rollcounter)),cos(stinger.yawcounter-(stinger.num-1)*stinger.yawcounter)) + stinger.target.x
		local y = FixedMul(FixedMul(radius, cos(stinger.rollcounter)),sin(stinger.yawcounter-(stinger.num-1)*stinger.yawcounter)) + stinger.target.y
		local z = FixedMul(radius, sin(stinger.rollcounter)) + stinger.target.z
		]]--

		local yawangle = 0
		--Starting with the base angle of 0, each added stinger would be moved by 45 degrees to the left
		yawangle = (stinger.num-1)*ANGLE_45

		--Correcting stingers to be behind the player 
		yawangle = $-(stinger.released-1)*(ANGLE_45/2)

		--Making the stinger(s) circle

		--[[
		Circle's around the player where's stinger's location is reset (I forgot how I did it but it works AHHAAHAHAHAHAHAAHAH)
		This is what is happening below to the coordinates of each stinger
			x′=𝑟cos𝜃cos𝛼
			𝑦′=𝑟sin𝜃
			𝑧′=𝑟cos𝜃sin𝛼
		]]--
		local x = FixedMul(FixedMul(radius, cos(stinger.rollcounter)),cos(yawangle)) + stinger.target.x
		local y = FixedMul(FixedMul(radius, cos(stinger.rollcounter)),sin(yawangle)) + stinger.target.y
		local z = FixedMul(radius, sin(stinger.rollcounter)) + stinger.target.z
		--Corrects the stingers to be relative the player's facing direction horizontal angle
		CorrectRotationHoriz(stinger, pivotx, pivoty, x, y, z, stinger.target.angle)

		--[[
			NOT WORKING because of roll and yaw functions because I can't yaw and roll and the same time,
			I have no clue how I made it worked through other functions above
		-- Appear right above the player for initial
		P_MoveOrigin(stinger, stinger.target.x+10*FRACUNIT, stinger.target.y, stinger.target.z + stinger.target.height)
		
		--Rotate based on the roll, yaw, and pitch angles
		Roll(stinger, pivoty, pivotz, stinger.rollcounter)
		Yaw(stinger, pivotx, pivoty, stinger.target.angle)
		]]--
		
		stinger.rollcounter = $+1*ANGLE_45
		

		--Each rojectile must:
		--Spawn above the player (all of them in the same spot)
		--Circle around the player (player's center is the pivot point)
		--Shoot out in their respective directions downwards
	end

	--Redirects towards the direction of the enemy ALMOST immediately when stinger thrust starts,
	--but doesn't actually tracks the enemy continuously to avoid bugs I have neither time nor 
	--desire to fix :3
	if(stinger.state == S_STINGER_THURST and stinger.homing_enemy == nil) then
		--Distance from the enemy to attack
		local enemydist3d = nil
		--Enemy to attack
		local enemy = nil
		--Scan the area for the enemies by retrieving the closest enemy in range
		searchBlockmap("objects", function(stinger_projectile, destmo)
			--Gettings the distance between the stinger and currently scanning enemy
			local dist3d = FixedSqrt(abs(
				FixedMul(destmo.x - stinger_projectile.x, destmo.x - stinger_projectile.x) + 
				FixedMul(destmo.y - stinger_projectile.y, destmo.y - stinger_projectile.y) + 
				FixedMul(destmo.z - stinger_projectile.z, destmo.z - stinger_projectile.z)))
			-- print(FixedMul(distx, distx) + FixedMul(disty, disty) + FixedMul(distz, distz))
			if((destmo.flags & TARGET_DMG_RANGE) and (destmo.flags & MF_MISSILE ~= MF_MISSILE)
			and stinger_projectile.target ~= nil
			and destmo ~= stinger_projectile.target 
			and (enemy == nil or enemy.homing_source == nil)
			and (enemydist3d == nil or enemydist3d >= dist3d
			and MAX_HOMING_DISTANCE >= enemydist3d)) then
				-- print(enemydist3d/FRACUNIT.." = "..dist3d/FRACUNIT)
				enemydist3d = dist3d
				enemy = destmo
				-- print("m:"..MAX_HOMING_DISTANCE/FRACUNIT.."\nd:"..dist/FRACUNIT)
				-- print("x:"..distx/FRACUNIT.."\ny:"..disty/FRACUNIT.."\nz:"..distz/FRACUNIT)
			end
		end, stinger, stinger.x-500*FRACUNIT, stinger.x+500*FRACUNIT, stinger.y-500*FRACUNIT, stinger.y+500*FRACUNIT)

		--Move towards the enemy
		if(enemy ~= nil and enemydist3d ~= nil and enemy.homing_source == nil) then
			--Make it so that the target remembers who is the owner of the stinger that is homing on it
			enemy.homing_source = stinger.target
			-- print(MAX_HOMING_DISTANCE/FRACUNIT.." vs "..enemydist3d/FRACUNIT)
			stinger.homing_enemy = enemy
			stinger.momx = (enemy.x-stinger.x)/TICRATE--(enemy.x-stinger.x/stinger.momx)
			stinger.momy = (enemy.y-stinger.y)/TICRATE--(enemy.y-stinger.y/stinger.momy)
			stinger.momz = (enemy.z-stinger.z)/TICRATE--(enemy.z-stinger.z/stinger.momz)
			-- P_Thrust(stinger, )
			-- enemy = nil
			-- enemydist3d = nil
		end
	end

	--If stinger is available
	--(Stinger is available when
		--In the state of homing
		--No homing target already
	--Search for enemies in the area to retrieve the closest
	--If enemy is available 
	--Thurst in the direction of the enemy
	
	--[[
	--Do not lock-on if already locked-n (works bad with multiple Helcurt players) and is quite buggy
	--This code make stingers track the enemy no matter what
	if(stinger.state == S_STINGER_THURST and stinger.homing == 0) then
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

			local time = TICRATE--FixedMul(FixedDiv(stinger.info.speed, enemydist3d), TICRATE) --THIS IS WRONG
			stinger.momx = enemydistx/time
			stinger.momy = enemydisty/time
			stinger.momz = enemydistz/time
			-- print("Time:"..time)
			-- print("Speed:"..FixedSqrt(abs(FixedMul(stinger.momx, stinger.momx) + 
			-- FixedMul(stinger.momy, stinger.momy) + FixedMul(stinger.momz, stinger.momz)))/FRACUNIT)			
		end
	end
	]]--
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

