

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
									player.mo.z+P_RandomRange(0, player.mo.height/FRACUNIT/2)*FRACUNIT,
									MT_SHDW)
		particle.color = player.mo.color--particlecolor
		P_SetObjectMomZ(particle, 2*FRACUNIT, false)
	end

	if(counter <= 0) then
		counter = MAX_TICS
		searchBlockmap("lines", function(playmo, line)
			
			local area = GetDarkArea(line.frontsector, CONCEAL_DARKNESS_LEVEL, line.frontsector.floorheight)
			print("  X : "..player.mo.x/FRACUNIT)
			print("  Y : "..player.mo.y/FRACUNIT)

			--If dark area (either sector or fof was found)
			if(area ~= nil) then
				if(area.bottomheight ~= nil) then --If a FOF (floor over floor)

					local linesarr = area.target.lines
					
					if(#linesarr >= 3) then
						local l1 = linesarr[P_RandomRange(0, #linesarr-1)]
						local l2 = linesarr[P_RandomRange(0, #linesarr-1)]

						-- print("1 x1: "..l1.v1.x/FRACUNIT)
						-- print("1 y1: "..l1.v1.y/FRACUNIT)

						local x = P_RandomRange(l1.v1.x/FRACUNIT, l2.v1.x/FRACUNIT)*FRACUNIT
						local y = P_RandomRange(l1.v1.y/FRACUNIT, l2.v1.y/FRACUNIT)*FRACUNIT

						P_SpawnMobj(x, y, P_RandomRange(area.target.floorheight/FRACUNIT, area.bottomheight/FRACUNIT)*FRACUNIT, MT_SHDW).state = S_SHDW_HINT
						P_SpawnMobj(x, y, P_RandomRange(area.target.floorheight/FRACUNIT, area.bottomheight/FRACUNIT)*FRACUNIT, MT_SHDW).state = S_SHDW_HINT
						
					end

					return false
				else -- if a sector
					print("sector")
					-- P_SpawnMobj(playmo.x, playmo.y, area.floorheight + 15*FRACUNIT, MT_STGP)
				end

				
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
