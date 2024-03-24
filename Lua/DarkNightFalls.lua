
--information about the map so that the night won't last forever
local current_mapinfo = 0
--original skybox, it is stored separately because skybox is not stored in mapheaderinfo
local og_skybox = 0
--Duration of the night
local NIGHT_MAX_TIC = 5*TICRATE
local NIGHT_SKYBOX = 6
local NIGHT_LIGHT_MULTIPLYER = 3/4

addHook("MapLoad", function(mapnum)
    -- print(mapthing.skynum)
    -- print(mapheader)
    current_mapinfo = mapheaderinfo[mapnum]
    --Searces for the skybox type to retrieve it
    for mp in mapthings.iterate do
            if(mp.type == 780) then
                og_skybox = mp.mobj
                break
            end         
        end
    
end)

addHook("PlayerThink", function(player)
    if(not player or not player.mo or player.mo.skin ~= "helcurt") then
		return
	end
    
    --Calling the night!
    if(player.cmd.buttons & BT_SPIN and player.night_timer == 0) then
        player.night_timer = NIGHT_MAX_TIC
        
        --Changes is speed
        player.acceleration = $+$/2
        player.normalspeed = $+$/2

        --Changes the background for the Night Fall
        P_SetupLevelSky(6)
        P_SetSkyboxMobj(nil) 
        -- P_SwitchWeather(PRECIP_STORM)
        for sector in sectors.iterate do
            -- sector.oglightlevel = 0
            -- sector.oglightlevel = sector.lightlevel
            -- P_FadeLight(sector.tag, sector.lightlevel - sector.lightlevel/NIGHT_LIGHT_MULTIPLYER, 3)
           sector.lightlevel = $*3/4
        end
    --Proceeding with the countdown
    elseif(player.night_timer > 1) then
            player.night_timer = $-1
    --Clearing up after the night ends
    elseif(player.night_timer == 1) then
        local skin = skins[player.skin]
        player.night_timer = $-1

        --Changes the speed back
        player.acceleration = skin.acceleration
        player.normalspeed = skin.normalspeed
      
        --Changes the background back to the OG (OriGinal)
        P_SetupLevelSky(current_mapinfo.skynum)
        if(og_skybox.valid) then
            P_SetSkyboxMobj(og_skybox)
        end
        -- P_SwitchWeather(current_mapinfo.weather)

        for sector in sectors.iterate do
            -- P_FadeLight(sector.tag, -sector.lightlevel/2, 20)
            -- sector.lightlevel = sector.oglightlevel
            sector.lightlevel = $*4/3
        end
    end
end)