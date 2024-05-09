--Required number of kiils to summon the night
local KILLS_FOR_NIGHT = 10

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
    if(player.killnight > KILLS_FOR_NIGHT and player.cmd.buttons & BT_SPIN and player.cmd.buttons & BT_JUMP 
            and not (P_IsObjectOnGround(player.mo)) and
            player.mo.state ~= S_NIGHT_CHARGE 
            and player.night_timer == 0) then
        player.killnight = 0
        player.mo.prevstate = player.mo.state
        player.mo.state = S_NIGHT_CHARGE 
    end


    --While charging the night
    if(player.mo.state == S_NIGHT_CHARGE) then
        P_SetObjectMomZ(player.mo, 2*FRACUNIT, false)
    -- elseif(player.mo.prevstate == S_NIGHT_CHARGE and player.mo.state ~= states[S_NIGHT_CHARGE].nextstate) then
    --     print("Prevent!")
    end


    --Proceeding with the countdown
    if(player.night_timer > 1) then
            player.night_timer = $-1
            --Keep playing the repeating night sound 
            if(not S_SoundPlaying(player.mo, sfx_nght1) and not S_SoundPlaying(player.mo, sfx_nght2)) then
                S_StartSound(player.mo, sfx_nght2)
            end
            
    --Clearing up after the night ends
    elseif(player.night_timer == 1) then
        player.night_timer = $-1
        EndTheNight(player, server.og_skybox, server.current_mapinfo.skynum)
    end
end)


addHook("MobjThinker", function(eyesmo)
    if(not Valid(eyesmo) or not Valid(eyesmo.target, "helcurt")) then
        return nil
    end

    if(eyesmo.state == S_EYES_1) then
        P_MoveOrigin(eyesmo, eyesmo.target.x, eyesmo.target.y, eyesmo.target.z)

        --Change the sprites scale with a speed of a default scale per charging state tic
        -- eyesmo.spritexscale = $+(FRACUNIT / states[S_EYES_1].tics)
        -- eyesmo.spriteyscale = $+(FRACUNIT / states[S_EYES_1].tics)
        eyesmo.spritexscale = $+((STYX_EYES_SCALE/2) / states[S_EYES_1].tics)
        eyesmo.spriteyscale = $+((STYX_EYES_SCALE/2) / states[S_EYES_1].tics)

        SpawnAfterImage(eyesmo, FF_TRANS90)
    elseif(eyesmo.state == S_EYES_2) then
        --Move behind the player only half of the states tics
        if(states[S_EYES_2].tics*2/3 < eyesmo.tics) then
            P_MoveOrigin(eyesmo, eyesmo.target.x, eyesmo.target.y, eyesmo.target.z)
        end
        
        SpawnAfterImage(eyesmo, FF_TRANS30)
    end

    
    
end, MT_EYES)


--Temporary solution to the bug in which Helcurt keeps his speed buffs after a respawn if 
--he spawns during the night. It is caused due to the end of the night behavior not triggering.
rawset(_G, "SPEED_BUG_PREVENTION", function(originplayer)
	EndHelcurtNightBuff(originplayer)
end)