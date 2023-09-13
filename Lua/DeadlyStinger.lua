
--/ ---------------------------------
--/ This file defines behavior for both the Deadly Stinger and Blade Attack abilities
--/ ---------------------------------

local STINGER_ANGLE_ADJ = 10*FRACUNIT
local STINGER_SPAWN_DISTANCE = -100

--Function Written by clairebun and was given on SRB2 discord page
--Returns true if two mobjects collide vertically, false otherwise
local function L_ZCollide(mo1,mo2)
    if mo1.z > mo2.height+mo2.z then return false end
    if mo2.z > mo1.height+mo1.z then return false end
    return true
end

--Handle the Stinger Projectile
addHook("MobjThinker", function(mo)
	if(not mo or not mo.valid or not mo.skin == "helcurt") then
		return
	end
	SpawnAfterImage(mo)
end, MT_STGP)

--Handle the Stinger Projectile
addHook("MobjCollide", function(mo)
	if(not mo.valid or not mo.skin == "helcurt") then
		return
	end
-- 	SpawnAfterImage(mo)
	
end, MT_STGP)


addHook("SpinSpecial", function(player)
	if(not player or not player.mo or player.mo.skin ~= "helcurt")
		return
	end
	--Perform a Blade Attack!
	if(player.spinheld == 1 and player.can_bladeattack and not P_IsObjectOnGround(player.mo)) then
		-- print("BLADE")
		player.mo.prevstate = player.mo.state
		player.mo.state = S_BLADE_ATTACK
	elseif(not P_IsObjectOnGround(player.mo))
-- 		print(player.can_bladeattack)
	end
	--Perform Deadly Stinger Attack!
	if(player.spinheld >= 10 and  player.can_stinger and /* player.stingers > 0 and */ P_IsObjectOnGround(player.mo)) then
		-- print("Stinger!")
-- 		player.can_bladeattack = false
		player.can_stinger = false
-- 		player.stingers = 1	-- ADDED FOR DEBUGGING PURPOSES SO THAT I WON'T NEED TO GRIND THEM
		local angle = player.mo.angle - FixedAngle((player.stingers-1)*STINGER_ANGLE_ADJ/2)
		for i = 1, player.stingers, 1 do
			if(i != 1) then
				angle = $+FixedAngle(STINGER_ANGLE_ADJ)
			end
			-- print("#"..i..": "..AngleFixed(angle)/FRACUNIT.."*")
			
			
			local stinger = SpawnDistance(player.mo.x, player.mo.y, player.mo.z, STINGER_SPAWN_DISTANCE, angle, MT_STGP)
			stinger.target = player.mo
			P_InstaThrust(stinger, stinger.angle, STINGER_LAUNCH_SPEED)

			--[[
			P_SpawnMobj(player.mo.x+P_RandomRange(SPAWN_RADIUS_MAX, -SPAWN_RADIUS_MAX)*FRACUNIT,
						player.mo.y+P_RandomRange(SPAWN_RADIUS_MAX, -SPAWN_RADIUS_MAX)*FRACUNIT,
						player.mo.z+P_RandomRange(0, player.mo.height/FRACUNIT/2)*FRACUNIT, --random range from feet to mid-body
						player.mo.z+FixedDiv(player.mo.height, 2),
						MT_STGP)
			--]]
		end
		player.stingers = 0
		--[[
		if(player.stingers >= 5) then
			player.stingers = 1
		else
			player.stingers = $+1
		end
		--]]
	end
end)


--Don't get damaged while damaging
addHook("ShouldDamage", function(mo, inflictor) 
	if(not mo or not mo.valid or not mo.player or mo.skin ~= "helcurt") then
		return nil
	end
	
	--Don't get damaged whlie performing a Blade Attack
	if(mo.state == S_BLADE_ATTACK and inflictor.flags & TARGET_RANGE) then
		return false
	end
end, MT_PLAYER)

--[[
--Decides/tries to damage the target when Helcurt collides with it
addHook("MobjCollide", function(playmo, target)
	if(not playmo or not playmo.valid or not playmo.skin or not playmo.skin == "helcurt") then
		return nil
	end
	--Hit the target if attacking with blades and stop attacking furthermore
	if(playmo.state == S_BLADE_ATTACK and L_ZCollide(target, playmo) and target.flags & TARGET_RANGE) then
		print("Before hitting")
		P_DamageMobj(target, playmo, playmo, 1)
		S_StartSound(playmo, sfx_blde1)
		P_SetObjectMomZ(playmo, -playmo.momz/2, false)
		--Allow attack chaining
		playmo.player.can_bladeattack = true
		playmo.momy = $/2
		playmo.momy = $/2
	end
end, MT_PLAYER)
--]]

--Behavior of the Helcurt's stinger to hit the targert
addHook("MobjCollide", function(target, mostinger)
	if(not mostinger or not mostinger.valid) then
			return nil
	end
	-- P_DamageMobj(target, stinger, ???, 1)
end, MT_STGP)

--Determines how to handle damaging of targets by helcurt
--Doesn't detect monitors, use MobjDeath for what I think
addHook("MobjDamage", function(target, inflictor, source)
	--Detecting if Helcurt is hitting a target 
	if(not source or not source.valid or not source.skin == "helcurt" or not
	source.player or not source.player.valid) then
		return nil;
	end
	--If damage was done with a blade attack
	if(source.state == S_BLADE_ATTACK) then
		--Manual animation
		source.frame = D
		--add a stinger if possible
		if(source.player.stingers < MAX_STINGERS) then
			source.player.stingers = $+1
		end
	end
end)

--Determines how to handle the killing of targets
addHook("MobjDeath", function(target, inflictor, source, dmgtype)
	--If Helcurt is the source of death
	if(source ~= nil and source.valid and source.skin ~= nil and source.skin == "helcurt") then
		source.player.killcount = $+1
	end
end)

addHook("PlayerThink", function(player)
	if(not player and not player.mo and player.mo.skin ~= "helcurt") then
		return
	end
	
	local block_search = 100*FRACUNIT
	local reach_distance = 100*FRACUNIT
-- 	if(player.spinheld >= 1) then
		searchBlockmap("objects", function(mo, mfound)
-- 			if(R_PointToDist2(mo.x, mo.y, mfound.x, mfound.y) <= reach_distance) then
-- 				P_TeleportMove(mo, mfound.x, mfound.y, mfound.z)
-- 	end
			print(reach_distance/FRACUNIT.." vs "..R_PointToDist2(mo.x, mo.y, mfound.x, mfound.y)/FRACUNIT)
			if(/*playmo.state == S_BLADE_ATTACK and */L_ZCollide(mfound, mo) and
			mfound.flags & TARGET_RANGE and R_PointToDist2(mo.x, mo.y, mfound.x, mfound.y) <= reach_distance) then
				P_DamageMobj(mfound, mo, mo, 1)
			end
		end, player.mo, player.mo.x - block_search, player.mo.x + block_search,
		player.mo.y - block_search, player.mo.y + block_search)
		P_SpawnMobj(player.mo.x - block_search, player.mo.y + block_search, player.mo.z, MT_UNKNOWN)
		P_SpawnMobj(player.mo.x - block_search, player.mo.y - block_search, player.mo.z, MT_UNKNOWN)
		P_SpawnMobj(player.mo.x + block_search, player.mo.y + block_search, player.mo.z, MT_UNKNOWN)
		P_SpawnMobj(player.mo.x + block_search, player.mo.y - block_search, player.mo.z, MT_UNKNOWN)
-- 		P_SpawnMobj(player.mo.x, player.mo.y, player.mo.z, MT_UNKNOWN)
		--[[
		, player.mo.x + block_search, player.mo.x - block_search,
		player.mo.y + block_search, player.mo.y - block_search)
		]]--
	--Be able to attack again
	if(player.mo.eflags & MFE_JUSTHITFLOOR) then
-- 		print("Restore!")
		player.can_bladeattack = true
		player.can_stinger = true
	end
end)
