addHook("MapLoad", function(mapnum)
    server.current_mapinfo = mapheaderinfo[mapnum]
    --Searces for the skybox type to retrieve it
    for mp in mapthings.iterate do
        if(mp.type == 780) then
            server.og_skybox = mp.mobj
            break
        end         
    end

end)

-- addHook("MapChange", function(player)
--     if(not player or not player.mo or player.mo.skin ~= "helcurt") then
-- 		return
-- 	end
--     if(player.night_timer ~= 0) then
--         -- EndHelcurtNightBuff(player)
--         EndTheNight(player, server.og_skybox, server.current_mapinfo.skynum)
--     end
-- end)

addHook("PlayerThink", function(player)
    if(not Valid(player.mo, "helcurt") or not PAlive(player)) then
		return
	end
    
    --Start charging the night
    if(player.cmd.buttons & BT_SPIN and player.cmd.buttons & BT_JUMP 
        and not (P_IsObjectOnGround(player.mo)) and
        player.mo.state ~= S_NIGHT_CHARGE 
        and player.night_timer == 0) then
            
        player.mo.prevstate = player.mo.state
        player.mo.state = S_NIGHT_CHARGE 
    end

    --While charging the night
    if(player.mo.state == S_NIGHT_CHARGE) then
        P_SetObjectMomZ(player.mo, 0, false)
    end

    --Proceeding with the countdown
    if(player.night_timer > 1) then
            player.night_timer = $-1
            --Keep playing the repeating night sound 
            if(S_SoundPlaying(player.mo, sfx_ult01) == nil and S_SoundPlaying(player.mo, sfx_ult02) == nil) then
                S_StartSound(player.mo, sfx_ult02)
            end
            
    --Clearing up after the night ends
    elseif(player.night_timer == 1) then
        player.night_timer = $-1
        EndTheNight(player, server.og_skybox, server.current_mapinfo.skynum)
    end
end)

--Temporary solution to the bug in which Helcurt keeps his speed buffs after a respawn if 
--he spawns during the night. It is caused due to the end of the night behavior not triggering.
rawset(_G, "SPEED_BUG_PREVENTION", function(originplayer)
	EndHelcurtNightBuff(originplayer)
end)