--Particle slots
freeslot("MT_SHDW", "SPR_SHDW", "S_SHDW_PRT")

local spawn_tic_counter = 0

COM_AddCommand("hel_particlecolor", function(player, color)
	if(color == nil or color < 0 or color > 113) then
		print("Incorrect color!")
	else
		print("Setting particle to color"..color)
		player.particlecolor = color
	end
end, COM_LOCAL)

states[S_SHDW_PRT] = {
	sprite = SPR_SHDW,
	tics = 4
}

mobjinfo[MT_SHDW] = {
	spawnstate = S_SHDW_PRT,
	height = 16*FRACUNIT,
	radius = 8*FRACUNIT,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_FLOAT|MF_NOGRAVITY
}


addHook("PlayerThink", function(player)
-- 	if(player.valid and player.mo and player.mo.valid and player.mo.skin and player.mo.skin.valid
-- 	and player.mo.skin == "helcurt")
	if(player.mo.skin == "helcurt" and player.mo.isconcealed) then
		local particle = P_SpawnMobj(player.mo.x+P_RandomRange(SPAWN_RADIUS_MAX, -SPAWN_RADIUS_MAX)*FRACUNIT, 
									player.mo.y+P_RandomRange(SPAWN_RADIUS_MAX, -SPAWN_RADIUS_MAX)*FRACUNIT,  
									player.mo.z+P_RandomRange(0, player.mo.height/FRACUNIT/2)*FRACUNIT,
									MT_SHDW)
		particle.color = player.mo.color--particlecolor
		P_SetObjectMomZ(particle, 2*FRACUNIT, false)
	end
end)
