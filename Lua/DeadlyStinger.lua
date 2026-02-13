-- DeadlyStinger.lua
-- 
-- Implementes the main logic of Deadly Stinger ability.
--
-- Deadly Stinger ability is the primary way for Helcurt to deal damage,
-- which is being done automatically if certain conditions are met.

-- Helcurt Auto-Damage Aura
-- This script searches for enemies and damages them automatically.

local block_search_range = 2000*FRACUNIT
local stinger_range = 160 * FRACUNIT -- Adjust the "lethal" distance
local stinger_damage = 1 -- Standard badniks have 1 health

-- The Helcurt will attack an enemy once
local function BladeSlash(player, enemy) 

    local pm = player.mo
	if(not Valid(pm, "helcurt") or not PAlive(player)) then return false end
    -- P_Damage deals damage, (target, inflictor, source, damage)
    P_DamageMobj(enemy, pm, pm, stinger_damage)
    
    -- 5. Visual Feedback (Spawn a purple "hit" effect)
    local ghost = P_SpawnMobj(enemy.x, enemy.y, enemy.z + (enemy.height/2), MT_THOK)
    ghost.color = SKINCOLOR_PURPLE
    ghost.scale = pm.scale
    
    -- Optional: Play a sound
    S_StartSound(enemy, sfx_blde1) 


    return true
end

addHook("PlayerThink", function(player)
    -- 1. Safety Checks
	if(not Valid(player.mo, "helcurt") or not PAlive(player)) then return false end
    
    -- 2. Requirement Check: Only works if Concealed/Ambushing
    -- if not (player.helcurt_stealth or player.helcurt_ambush) then return end

    local pmo = player.mo

    -- 3. Search for targets in a small box around the player
    searchBlockmap("objects", function(me, enemy)
        if not (enemy and enemy.valid) then return end
        
        -- Filter for Enemies/Bosses that aren't already dead
        if (enemy.flags & MF_ENEMY or enemy.flags & MF_BOSS) and enemy.health > 0 then
            
            -- Calculate 3D distance
            local dist = P_AproxDistance(P_AproxDistance(enemy.x - pmo.x, enemy.y - pmo.y), enemy.z - pmo.z)
            
            -- 4. Execute Damage
            if dist <= stinger_range then
               BladeSlash(player, enemy)
               Conceal(pmo)
            end
        end
    end, pmo, pmo.x - block_search_range, pmo.x + block_search_range, pmo.y - block_search_range, pmo.y + block_search_range)
end)