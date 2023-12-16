------------------------------------
--The teleportation (a.k.a, transition) is done through using three teleport states:
--Start Transition, In Transition, and End Transition.
--Star Transition launches the player ahead and End Transition deccelarates the player
--On Jump while jumping
------------------------------------

addHook("AbilitySpecial",
		function(player)
			if(not player or
			not player.mo or
			player.mo.skin ~= "helcurt") then
				return
			end
			if(player.can_teleport) then
				player.mo.prevstate = player.mo.state
				player.mo.state = S_PRE_TRANSITION
			end
		end)

addHook("PlayerThink",
		function(player)
			if(not player or
			not player.mo or
			player.mo.skin ~= "helcurt") then
				return
			end
			--DEPRECATED Cancel interupted preparation to teleport
-- 			if(player.mo.prevstate == S_PRE_TRANSITION and player.mo.state ~= S_PRE_TRANSITION and player.mo.state ~= S_START_TRANSITION) then
-- 				player.mo.prevstate = player.mo.state
-- 				player.mo.state = S_PLAY_FALL
-- 			end

			--NOT WORKING - Ensuring the teleport states are played if they are interupted
			if(player.mo.prevstate == S_IN_TRANSITION and player.mo.state ~= S_IN_TRANSITION and player.mo.state ~= S_END_TRANSITION) then
				player.mo.prevstate = player.mo.state
				player.mo.state = S_END_TRANSITION
			end
			
			
			--Handle In_Transition state for each frame
			if(player.mo.state == S_IN_TRANSITION) then
				P_SetObjectMomZ(player.mo, 0, false)
				--End transition when stopped holding the jump button
				if(player.jumpheld == 0) then
					player.mo.prevstate = player.mo.state
					player.mo.state = S_END_TRANSITION
					
				end
			end
			--Cancel Pre_Transition if player doesn't hold jump in specified interval
			if(player.mo.state == S_PRE_TRANSITION and (not (player.cmd.buttons & BT_JUMP) or player.jumpheld > states[S_PRE_TRANSITION].tics)) then
				player.mo.prevstate = player.mo.state
				player.mo.state = S_PLAY_FALL
			end

--[[
			----DEPRECATED Start another 
			if(player.mo.state == S_IN_TRANSITION or player.mo.state == S_END_TRANSITION) then
	-- 			print(player.spinheld)
				if(player.spinheld == 1)
	-- 				print(player.mo.momz)
					player.mo.momz = $-FRACUNIT*20
				end
			end
]]--
			--Recharge when hit the floor
			if(player.can_teleport == 0 and player.mo.eflags & MFE_JUSTHITFLOOR) then
				player.can_teleport = 1
			end
		end)