------------------------------------
--The teleportation (a.k.a, transition) is done through using three teleport states:
--Start Transition, In Transition, and End Transition.
--Star Transition launches the player ahead and End Transition deccelarates the player
--On Jump while jumping
------------------------------------


addHook("AbilitySpecial",
		function(player)
			if(not Valid(player.mo, "helcurt") or not PAlive(player)) then
				return nil
			end
			-- if(player.mo.can_teleport) then
			-- 	player.mo.prevstate = player.mo.state
			-- 	player.mo.state = S_PRE_TRANSITION
			-- end

			--Be able to perform teleport if haven't teleported yet
			--Implemented this way because teleport itself requires 
			--holding the jump button for multiple tics to perform, 
			--not just press once (this code block runs a single tic)
			if(player.mo.can_teleport == 0 and player.mo.teleported == 0) then
				player.mo.can_teleport = 1
			end
		end)

addHook("PlayerThink",
		function(player)
			if(not Valid(player.mo, "helcurt") or not PAlive(player)) then
				return nil
			end
			-- print(player.jumpheld)
			--Recharge teleport only when pressing jump button in the air
			-- if(player.mo.can_teleport == 0 and player.mo.teleported == 0 and
			-- not P_IsObjectOnGround(player.mo) and player.jumpheld ~= 0 and player.pflags&PF_JUMPDOWN == 0) then
			-- 	player.mo.can_teleport = 1
			-- end

			--Perform a teleport when one is available by HOLDING the jump button
			if(player.mo.can_teleport and player.cmd.buttons&BT_JUMP and player.jumpheld > TICS_PRESS_RANGE) then
				-- print('TEL')
				player.mo.prevstate = player.mo.state
				player.mo.state = S_PRE_TRANSITION
			end


			--DEPRECATED Cancel interupted preparation to teleport
-- 			if(player.mo.prevstate == S_PRE_TRANSITION and player.mo.state ~= S_PRE_TRANSITION and player.mo.state ~= S_START_TRANSITION) then
-- 				player.mo.prevstate = player.mo.state
-- 				player.mo.state = S_PLAY_FALL
-- 			end

			--NOT WORKING - Ensuring the teleport states are played if they are interupted
			-- if(player.mo.prevstate == S_IN_TRANSITION and player.mo.state ~= S_IN_TRANSITION and player.mo.state ~= S_END_TRANSITION) then
			-- 	player.mo.prevstate = player.mo.state
			-- 	player.mo.state = S_END_TRANSITION
			-- end
			
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
			-- if(player.mo.state == S_PRE_TRANSITION and 
			-- (not (player.cmd.buttons & BT_JUMP) or player.jumpheld > states[S_PRE_TRANSITION].tics+EXTRA_JUMP_TICS)) then
			-- 	print("cancel!")
			-- 	player.mo.prevstate = player.mo.state
			-- 	player.mo.state = S_PLAY_FALL
			-- end

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
			--Reset when hit the floor
			if(player.mo.eflags & MFE_JUSTHITFLOOR) then
				player.mo.can_teleport = 0
				player.mo.teleported = 0
			end
		end)