

COM_AddCommand("hel_particlecolor", function(player, color)
	if(color == nil or color < 0 or color > 113) then
		print("Incorrect color!")
	else
		print("Setting particle to color"..color)
		player.particlecolor = color
	end
end, COM_LOCAL)


local MAX_TICS = TICRATE
local counter = 0


addHook("PlayerThink", function(player)
-- 	if(player.valid and player.mo and player.mo.valid and player.mo.skin and player.mo.skin.valid
-- 	and player.mo.skin == "helcurt")
	if(not Valid(player.mo, "helcurt") and not PAlive(player)) then
		return nil
	end 
	
	--Concealment particles
	if(player.mo.unconceal_timer > 0) then
		local particle = P_SpawnMobj(player.mo.x+P_RandomRange(SPAWN_RADIUS_MAX, -SPAWN_RADIUS_MAX)*FRACUNIT, 
									player.mo.y+P_RandomRange(SPAWN_RADIUS_MAX, -SPAWN_RADIUS_MAX)*FRACUNIT,  
									player.mo.z+P_RandomRange(0, player.mo.height/(2*FRACUNIT))*FRACUNIT,
									MT_SHDW)
		particle.color = player.mo.color--particlecolor
		particle.momx = player.mo.momx/2
		particle.momy = player.mo.momy/2
		P_SetObjectMomZ(particle, FRACUNIT/2, false)
	end

	if(counter <= 0) then
		counter = MAX_TICS
		searchBlockmap("lines", function(playmo, line)
			
			for i = 0, 1, 1 do
				local area = nil
				if(i == 0) then
				--Checks if the area is dark, retrieves either a fof or sector
					area = GetDarkArea(line.frontsector, CONCEAL_DARKNESS_LEVEL, line.frontsector.floorheight)
				elseif(line.backsector ~= nil) then
					area = GetDarkArea(line.backsector, CONCEAL_DARKNESS_LEVEL, line.backsector.floorheight)
				end

				--If dark area (either sector or fof was found)
				if(area ~= nil) then
					local linesarr = nil
					local bottom = nil
					local top = nil

					if(area.bottomheight ~= nil) then --If a FOF (floor over floor)
						linesarr = area.target.lines
						bottom = area.target.floorheight
						top = area.bottomheight
					else -- if a sector
						linesarr = area.lines
						bottom = area.floorheight
						top = area.ceilingheight
					end

						--Spawning behavior (chooses between current and random line of the sector)
						if(linesarr ~= nil and #linesarr >= 3) then

							local l1 = line --CAN'T THE FIRST LINE BE THE LINE IN THE BLOCKMAP FUNCTINO???
							local l2 = linesarr[P_RandomRange(0, #linesarr-1)]

							local x = P_RandomRange(l1.v1.x/FRACUNIT, l2.v1.x/FRACUNIT)*FRACUNIT
							local y = P_RandomRange(l1.v1.y/FRACUNIT, l2.v1.y/FRACUNIT)*FRACUNIT

							local subsector = R_PointInSubsectorOrNil(x, y)


							if(subsector ~= nil and subsector.sector ~= nil and ((subsector.sector == area) or (area.target ~= nil and subsector.sector == area.target))) then
								--Spawn with immediate state change (look in the end of the line I hope it's not changed in the end bc I would look dumb)
								P_SpawnMobj(x, y, P_RandomRange(bottom/FRACUNIT, top/FRACUNIT)*FRACUNIT, MT_SHDW).state = S_SHDW_HINT
								P_SpawnMobj(x, y, P_RandomRange(bottom/FRACUNIT, top/FRACUNIT)*FRACUNIT, MT_SHDW).state = S_SHDW_HINT
							
							end
							
						end

						return false
					
				end

				area = nil
			end
		end, 
		player.mo, 
		player.mo.x-2000*FRACUNIT, 
		player.mo.x+2000*FRACUNIT, 
		player.mo.y-2000*FRACUNIT, 
		player.mo.y+2000*FRACUNIT)
			
		else 
			counter = $ - 1
	end
end)


--[[

addHook("MobjThinker", function(mo)
	-- if(not Valid(mo)) then
	-- 	return nil 
	-- end

end, MT_SHDW)

]]--

