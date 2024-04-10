
--information about the map so that the night won't last forever
local current_mapinfo = 0
--original skybox, it is stored separately because skybox is not stored in mapheaderinfo
local og_skybox = 0
--Duration of the night
local NIGHT_MAX_TIC = 5*TICRATE
local NIGHT_SKYBOX = 6
local NIGHT_LIGHT_MULTIPLYER = 3/4

local function StartHelcurtNightBuff(originplayer)
    if(not Valid(originplayer.mo, "helcurt") or not PAlive(originplayer)) then
        return nil
    end
        --Increase in speed
        originplayer.acceleration = $+$/4
        originplayer.normalspeed = $+$/2
end

local function EndHelcurtNightBuff(originplayer)
    if(not Valid(originplayer.mo, "helcurt") or not PAlive(originplayer)) then
        return nil
    end

    local skin = skins[originplayer.skin]
    
    --Changes the speed back
    originplayer.acceleration = skin.acceleration
    originplayer.normalspeed = skin.normalspeed
end

local function StartTheNight(originplayer)
    if(not Valid(originplayer.mo, "helcurt")) then
        return nil
    end

    StartHelcurtNightBuff(originplayer)
    
    --Changes the background for the Night Fall
    P_SetupLevelSky(NIGHT_SKYBOX)
    P_SetSkyboxMobj(nil)  
    -- P_SwitchWeather(PRECIP_STORM)

    --Starting the monologue and night sound
    S_StartSound(originplayer.mo, sfx_mnlg1)
    S_StartSound(originplayer.mo, sfx_ult01)

    --Fading the background music
    S_FadeMusic(50, 20)
    -- S_SpeedMusic(FRACUNIT/2)
    
    --Make each sector of the map darker
    for sector in sectors.iterate do
        -- sector.oglightlevel = 0
        -- sector.oglightlevel = sector.lightlevel
        -- P_FadeLight(sector.tag, sector.lightlevel - sector.lightlevel/NIGHT_LIGHT_MULTIPLYER, 3)
       sector.lightlevel = $*3/4
    end
end

--Call this function ONLY IF THE NIGHT ABILITY IS ON, 
local function EndTheNight(originplayer, skybox, skynum)
    if(not Valid(originplayer.mo, "helcurt")) then
        return nil
    end

    EndHelcurtNightBuff(originplayer)

   --Changes the background back to the OG (OriGinal)
   P_SetupLevelSky(skynum)
   -- P_SwitchWeather(current_mapinfo.weather)
   if(og_skybox.valid and og_skybox ~= nil) then
       P_SetSkyboxMobj(skybox)
   end

   --Wrapping-up the night sound and bringing back original level sounds
   S_FadeMusic(100, 20)
   S_StopSoundByID(originplayer.mo, sfx_ult02)
   S_StartSound(originplayer.mo, sfx_ult03)
   S_SpeedMusic(FRACUNIT)
   
   for sector in sectors.iterate do
       -- P_FadeLight(sector.tag, -sector.lightlevel/2, 20)
       -- sector.lightlevel = sector.oglightlevel
       sector.lightlevel = $*4/3
   end
end

addHook("MapLoad", function(mapnum)
    current_mapinfo = mapheaderinfo[mapnum]
    --Searces for the skybox type to retrieve it
    for mp in mapthings.iterate do
        if(mp.type == 780) then
            og_skybox = mp.mobj
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
--         EndTheNight(player, og_skybox, current_mapinfo.skynum)
--     end
-- end)

addHook("PlayerThink", function(player)
    if(not Valid(player.mo, "helcurt") or not PAlive(player)) then
		return
	end
    
    --Calling the night!
    if(player.cmd.buttons & BT_SPIN and player.cmd.buttons & BT_JUMP and (P_IsObjectOnGround(player.mo)) and player.night_timer == 0) then
        player.night_timer = NIGHT_MAX_TIC
        StartTheNight(player)
    --Proceeding with the countdown
    elseif(player.night_timer > 1) then
            player.night_timer = $-1
            --Keep playing the repeating night sound 
            if(S_SoundPlaying(player.mo, sfx_ult01) == nil and S_SoundPlaying(player.mo, sfx_ult02) == nil) then
                S_StartSound(player.mo, sfx_ult02)
            end
    --Clearing up after the night ends
    elseif(player.night_timer == 1) then
        player.night_timer = $-1
        EndTheNight(player, og_skybox, current_mapinfo.skynum)
    end
end)

--Temporary solution to the bug in which Helcurt keeps his speed buffs after a respawn if 
--he spawns during the night. It is caused due to the end of the night behavior not triggering.
rawset(_G, "SPEED_BUG_PREVENTION", function(originplayer)
	EndHelcurtNightBuff(originplayer)
end)