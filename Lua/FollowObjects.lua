addHook("FollowMobj", function(player, mo)

    -- CorrectRotationHoriz(mo, player.mo.x, player.mo.y,
	-- 								player.mo.x-player.mo.radius, 
	-- 								player.mo.y, 
	-- 								player.mo.z+player.mo.height*2, mo.angle)


    if(not Valid(player.mo, "helcurt") or not PAlive(player) or not Valid(mo)) then
        return nil
    end

    --Decides whether to switch follow object animation to a running state
    if(player.mo.state ~= player.mo.prevstate)  then
        --Regular running
        if(player.mo.state == S_PLAY_RUN) then
            states[S_FOLLOW_RUN].frame = FF_ANIMATE
            mo.state = A|S_FOLLOW_RUN
        elseif(player.mo.state == S_PLAY_FALL) then
            -- print("still")
            mo.state = S_FOLLOW_RUN
            mo.frame = C
        end
    end
    --Go back to a regular standing follow object state
    if(mo.state == S_FOLLOW_RUN and not (player.mo.state == S_PLAY_RUN or player.mo.state == S_PLAY_FALL)) then
        mo.state = S_FOLLOW_STAND
    end

    --Temporary solution to setting
    mo.spritexscale = skins[player.skin].highresscale
    mo.spriteyscale = skins[player.skin].highresscale
    
    mo.scale = player.mo.scale
    
end, MT_FOLLOW)