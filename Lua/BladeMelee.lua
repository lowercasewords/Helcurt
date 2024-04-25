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
local BLADE_BLOCK_SEARCH = 500*FRACUNIT
--Maximum distance between enemy and Helcurt for latter to blade attack 
local BLADE_HIT_DISTANCE = 50*FRACUNIT

--/--------------------------
--/ HOOKS
--/--------------------------

addHook("PlayerThink", function(player)
	if(not Valid(player.mo, "helcurt") or not PAlive(player)) then
		return nil
	end

	--Allow to use blade ability
	if(player.mo.can_blade == 0 and player.mo.hasjumped == 1) then
		player.mo.can_blade = 1
	elseif(player.mo.hasjumped == 0) then
		player.mo.can_blade = 0 
	end

	--Cancel spring empowerment if not in the state
	if(player.powers[pw_strong]&STR_SPRING ~= 0 and player.mo.state ~= S_BLADE_THURST) then
		player.powers[pw_strong] = $&~STR_SPRING
	end

	--If holding or pressing spin when able to attack (in the air)
	if(P_IsObjectOnGround(player.mo) == false and player.mo.state ~= S_NIGHT_CHARGE and player.spinheld ~= 0) then
		
		if(player.mo.state == S_BLADE_THURST) then
			--Continuous behavior 
			
			if(player.spinheld == TICS_PRESS_RANGE) then

				P_SetObjectMomZ(player.mo, BLADE_THRUST_FALL, false)
			elseif(player.spinheld > TICS_PRESS_RANGE) then
				-- print("down: "..player.mo.momz)
				P_SetObjectMomZ(player.mo, BLADE_THRUST_FALL/3, true)
			end
		--switch to blade attack when player wants
		elseif(player.mo.can_blade == 1 and player.spinheld <= 1 and player.jumpheld == 0 and (player.mo.state ~= S_BLADE_THURST or 
		player.mo.state == S_BLADE_THURST_HIT and player.mo.tics < states[S_BLADE_THURST_HIT].tics/2*3)) then
			
			player.mo.prevstate = player.mo.state
			player.mo.state = S_BLADE_THURST
		end
	end
	
	--Search for enemies to kill (Doesn't interupt the state)
	-- if(player.mo.state == S_BLADE_THURST or player.mo.state == S_BLADE_FALL) then
	if(player.mo.state == S_BLADE_THURST) then
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
		if(distcheck < checkmo.radius+playmo.radius+BLADE_HIT_DISTANCE and L_ZCollide(playmo, checkmo, checkmo.height+BLADE_HIT_DISTANCE) 
		and checkmo.valid and checkmo.health > 0 
		and checkmo.state ~= checkmo.info.painstate
		and checkmo.flags2 & (MF2_BOSSFLEE|MF2_FRET|MF2_BOSSDEAD|MF2_INVERTAIMABLE) == 0
		and checkmo.flags & MF_SHOOTABLE ~= 0
		and checkmo.flags & TARGET_DMG_RANGE ~= 0 and checkmo.flags & TARGET_IGNORE_RANGE == 0) then
			P_DamageMobj(checkmo, player.mo, player.mo, 1)
			-- P_KillMobj(checkmo, player.mo, player.mo)
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
end)