
--information about the map so that the night won't last forever
local current_mapinfo = 0
--original skybox, it is stored separately because skybox is not stored in mapheaderinfo
local og_skybox = 0
--Duration of the night
local NIGHT_MAX_TIC = 5*TICRATE
local NIGHT_SKYBOX = 6

addHook("MapLoad", function(mapnum)
    -- print(mapthing.skynum)
    -- print(mapheader)
    current_mapinfo = mapheaderinfo[mapnum]
    --Searces for the skybox type to retrieve it
    for mp in mapthings.iterate do
            if(mp.type == 780) then
                og_skybox = mp.mobj
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
        P_SetupLevelSky(6)
        P_SetSkyboxMobj(nil)
    --Proceeding with the countdown
    elseif(player.night_timer > 1)
            player.night_timer = $-1
    --Clearing up after the night ends
    elseif(player.night_timer == 1)
        player.night_timer = $-1
        P_SetupLevelSky(current_mapinfo.skynum)
        P_SetSkyboxMobj(og_skybox)
    end
end)