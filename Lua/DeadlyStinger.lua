-------------------------------------
--- This file defines behavior for the Deadly Stinger abilitiy
--- And yes, as of typing it these abilities don't rely much on actions, so most functionality is here
-------------------------------------

------------------------------------
---CONSTANTS
-------------------------------------

--Maximum distance for the stinger to lock-on and track the enemy
local MAX_HOMING_DISTANCE = 100*FRACUNIT

addHook("PlayerThink", function(player)
	if(not player or not player.mo or player.mo.skin ~= "helcurt") then
		return
	end

	--Start using Deadly Stinger in the Air
	if((player.prevjumpheld <= TICS_PRESS_RANGE and player.prevjumpheld ~= 0 and 
	player.jumpheld == 0 and player.mo.can_stinger == 1)) then
		player.mo.prevstate = player.mo.state
		player.mo.state = S_STINGER_AIR_1
		
	--Start using Deadly Stinger on the ground
	elseif(player.mo.state ~= S_STINGER_GRND_1 and player.mo.state ~= S_STINGER_GRND_2 and player.spinheld ~= 0 and 
	P_IsObjectOnGround(player.mo) and player.mo.ground_tic_cd <= 0) then
		player.mo.prevstate = player.mo.state
		player.mo.state = S_STINGER_GRND_1
	end

	--Allow to perform a stinger ability once when tapping jump button in the midair after a jump (or holding it for a little bit to avoid annoying controls)
	if(player.mo.hasjumped and player.jumpheld == 0 and player.mo.stung == 0) then
		player.mo.can_stinger = 1
	--Not allow when landed when landed
	elseif(player.mo.eflags&MFE_JUSTHITFLOOR) then
		player.mo.can_stinger = 0
		player.mo.stung = 0
	end

	-- print(player.mo.ground_tic_cd)
	--Recharge the ground stinger ability
	if(player.mo.ground_tic_cd > 0) then
		player.mo.ground_tic_cd = $-1
	end
end)

-- addHoook("PreThinkFrame"), function(stinger)
-- end, MT_STGP)

--Handle the Stinger Projectile
addHook("MobjThinker", function(stinger)
	if(not stinger or not stinger.valid) then
		return
	end
	
	SpawnAfterImage(stinger)

	if(stinger.state == S_AIR_2 and stinger.eflags&MFE_JUSTHITFLOOR) then
		stinger.state = S_AIR_3
	end
	
	-- print("A "..stinger.rollcounter/ANG1)
	--Stinger Charging behavior 
	if(stinger.state == S_AIR_1 or stinger.state == S_GRND_1 and stinger.target ~= nil and stinger.target.valid and
stinger.target.state ~= nil) then
		local pivotx = stinger.target.x
		local pivoty = stinger.target.y
		local pivotz = stinger.target.z + stinger.target.height/3
		local radius = 0
		local yawangle = 0

		--Radius of stinger's trajectory around helcurt
		if(stinger.state == S_AIR_1) then
			radius = stinger.target.radius*2
		elseif(stinger.state == S_GRND_1) then
			radius = stinger.target.radius*4
		end
		
		
		if(stinger.state == S_AIR_1) then
			--Starting with the base angle of 0, each added stinger would be moved by 45 degrees to the left
			yawangle = (stinger.num-1)*SEPARATION_AIR_ANGLE
			--Correcting stingers to be behind the player 
			yawangle = $-(stinger.released-1)*(SEPARATION_AIR_ANGLE/2)
		elseif(stinger.state == S_GRND_1) then
			--Starting with the base angle of 0, each added stinger would be moved by 45 degrees to the left
			yawangle = (stinger.num-1)*SEPARATION_GRND_ANGLE
			--Correcting stingers to be behind the player 
			yawangle = $-(stinger.released-1)*(SEPARATION_GRND_ANGLE/2)
		end
		
		
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

		
		--The direction of rolling, and yes I know this is not the best way to change directions
		--depending on the state
		if(stinger.state == S_AIR_1) then
			--Divide total angle distance to travel by the time it needs to take to travel, meaning that we just provide angular velocity.
			--in this case angular distance and time used area HALF of the true value because anything above 180 is negative and messes it up!
			stinger.rollcounter = $+((HALF_AIR_ANGLE)/(states[stinger.state].tics/2))
		elseif(stinger.state == S_GRND_1) then
			--Divide total angle distance to travel by the time it needs to take to travel, meaning that we just provide angular velocity.
			--in this case angular distance and time used area HALF of the true value because anything above 180 is negative and messes it up!
			stinger.rollcounter = $+((-HALF_GRND_ANGLE)/(states[stinger.state].tics/2))
		end
		

		--Each rojectile must:
		--Spawn above the player (all of them in the same spot)
		--Circle around the player (player's center is the pivot point)
		--Shoot out in their respective directions downwards
	
		
		return
	end

	--[[
	--Redirects towards the direction of the enemy ALMOST immediately when stinger thrust starts,
	--but doesn't actually tracks the enemy continuously to avoid bugs I have neither time nor 
	--desire to fix :3
	if(stinger.state == S_AIR_2 and stinger.tics < (states[stinger.state].tics)/2*3 and stinger.homing_enemy == nil) then
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
			stinger.homing_enemy = enemy
			stinger.momx = (enemy.x-stinger.x)/TICRATE
			stinger.momy = (enemy.y-stinger.y)/TICRATE
			stinger.momz = (enemy.z-stinger.z)/TICRATE
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


--Handle's the clean-up of stinger's object removal
addHook("MobjRemoved", function(stinger)
	if(not stinger.valid) then
		return nil	
	end

	-- print(stinger.state.."vs"..S_GRND_2)
	--Allow other stingers to home-in onto target that was
	--homed-in by this stinger
	if(stinger.homing_enemy ~= nil and stinger.homing_enemy.valid and stinger.homing_enemy.homing_source ~= nil and stinger.homing_enemy.homing_source.valid) then
		stinger.homing_enemy.homing_source = nil
	end
	
end, MT_STGP)

--Defines behavior when a stinger collides with an object
addHook("MobjMoveCollide", function(stinger, object)
	if(not stinger.valid or not object.valid) then
		return nil	
	end
	
	--Damage if collided with an enemy
	if(object.flags&TARGET_DMG_RANGE ~= 0 and object.flags&TARGET_IGNORE_RANGE == 0) then
		P_DamageMobj(object, stinger, stinger.target)
	-- elseif(object.type == TARGET_KILL_RANGE) then
	--Kill if collided with a spike or some of its variants
	elseif(object.type == MT_SPIKE or object.type == MT_WALLSPIKE or object.type == MT_POINTYBALL) then
		P_KillMobj(object, stinger, stinger.target)
	end
	

end, MT_STGP)

--Used in the Line Collide thinker both for front and back sector
local function WallBust(stinger, fof)
	if(fof.valid and fof.flags&FF_BUSTUP and fof.flags&FF_EXISTS) then
		EV_CrumbleChain(nil, fof)
		return false
	end
end

addHook("MobjLineCollide", function(stinger, line)
	
	if(not stinger.valid or not line.valid) then
		return nil	
	end
	
	--Checking the front side of the line
	for fof in line.frontsector.ffloors() do
		WallBust(stinger, fof)
	end
	--Checking the backside of the line if there's one
	if(line.backsector ~= nil) then
		for fof in line.backsector.ffloors() do
			WallBust(stinger, fof)
		end
	end
	-- print(line.frontside.special)
	-- print(line.backside.special)
	
end, MT_STGP)