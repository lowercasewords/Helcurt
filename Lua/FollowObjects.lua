addHook("FollowMobj", function(player, mo)

    -- CorrectRotationHoriz(mo, player.mo.x, player.mo.y,
	-- 								player.mo.x-player.mo.radius, 
	-- 								player.mo.y, 
	-- 								player.mo.z+player.mo.height*2, mo.angle)


    if(not Valid(player.mo, "helcurt") or not PAlive(player) or not Valid(mo)) then
        return nil
    end
    --Temporary solution to setting
    mo.spritexscale = skins[player.skin].highresscale
    mo.spriteyscale = skins[player.skin].highresscale
    
    mo.scale = player.mo.scale
    
end, MT_FOLLOW)