

local STAND_FRAME_TICS = 5

addHook("FollowMobj", function(player, mo)

    -- if(not Valid(player, "helcurt") or not PAlive(player) or not Valid(mo)) then
    --     return nil
    -- end

    if(mo.frame_timer == nil) then
        mo.frame_timer = 0
    end

    --Temporary solution to setting
    mo.spritexscale = skins[player.skin].highresscale
    mo.spriteyscale = skins[player.skin].highresscale
    
    mo.scale = player.mo.scale
    
    
    if(mo.frame_timer <= 0) then
        if(mo.frame < C) then
            mo.frame = $+1
        else 
            mo.frame = 0
        end
        mo.frame_timer = STAND_FRAME_TICS
    else
        mo.frame_timer = $-1
    end

end, MT_FOLLOW)
