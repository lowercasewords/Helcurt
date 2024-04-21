------------------------------------
--The teleportation (a.k.a, transition) is done through using three teleport states:
--Start Transition, In Transition, and End Transition.
--Star Transition launches the player ahead and End Transition deccelarates the player
------------------------------------

addHook("PlayerThink",
		function(player)
			if(not Valid(player.mo, "helcurt") or not PAlive(player)) then
				return nil
			end


			--Perform a teleport when one is available by HOLDING the jump button
			if(player.mo.can_teleport == 1 and player.jumpheld > TICS_PRESS_RANGE) then
				player.mo.prevstate = player.mo.state
				player.mo.state = S_PRE_TRANSITION
			end

			--Recharge teleport only when holding jumpbutton in the air
			if(player.mo.can_teleport == 0 and player.mo.teleported == 0 and player.mo.hasjumped == 1 and player.jumpheld == 0) then
				player.mo.can_teleport = 1
			end

			if(player.mo.state == S_IN_TRANSITION) then
				P_SetObjectMomZ(player.mo, 0, false)
				--End transition when stopped holding the jump button
				if(player.jumpheld == 0) then
					player.mo.prevstate = player.mo.state
					player.mo.state = S_END_TRANSITION
					
				end
			end

			--Reset when hit the floor
			if(player.mo.hasjumped == 0) then
				player.mo.can_teleport = 0
				player.mo.teleported = 0
				player.mo.enhanced_teleport = 0
			end
		end)