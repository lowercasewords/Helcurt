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



--[[
--Handle the Stinger Projectile
addHook("MobjThinker", function(mo)
	if(not mo or not mo.valid) then
		return
	end
	SpawnAfterImage(mo)
end, MT_STGP)
]]--

--[[
--Handle the Stinger Projectile
addHook("MobjCollide", function(mo)
	if(not mo.valid or not mo.skin == "helcurt") then
		return
	end
end, MT_STGP)
]]--

addHook("SpinSpecial", function(player)
	if(not player or not player.mo or player.mo.skin ~= "helcurt") then
		return
	end

	--Perform Deadly Stinger Attack!
	if(player.spinheld >= 10 and player.can_stinger and player.stingers > 0 and P_IsObjectOnGround(player.mo)) then
 		player.can_bladeattack = false
		player.can_stinger = false
		
		local angle = player.mo.angle - FixedAngle((player.stingers-1)*STINGER_ANGLE_ADJ/2)
		
		for i = 1, player.stingers, 1 do
			if(i ~= 1) then
				angle = $+FixedAngle(STINGER_ANGLE_ADJ)
			end
			local stinger = SpawnDistance(player.mo.x, player.mo.y, player.mo.z, STINGER_SPAWN_DISTANCE, angle, MT_STGP)
			stinger.target = player.mo
			P_InstaThrust(stinger, stinger.angle, stinger.info.speed)
		end
		player.stingers = 0
	end
end)


--Determines how to handle the killing of targets
addHook("MobjDeath", function(target, inflictor, source, dmgtype)
// 	print("T: "..target.type)
// 	print("I: "..inflictor.type)
// 	print("S: "..source.type)
// 	print("D: "..dmgtype)
	--If Helcurt is the source of death
	if(not source or not source.valid or not source.skin or not source.skin == "helcurt" or not source.player) then
		return nil
	end
	source.player.killcount = $+1
end)