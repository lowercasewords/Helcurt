--How dark the area has to be to activate his passive
local CONCEAL_SHADOW_LEVEL = 180
--Default time to wait for a single stinger to charge  
local STINGER_CHARGE_TIMER = 5*TICRATE

--Conceals the player in the darkness
--Called every tic to maintain frame preferences!
local function Conceal(player)
	-- print("Conceal!")
	player.mo.isconcealed = 1
	player.mo.frame = $|FF_TRANS50--|FF_FULLBRIGHT
end


addHook("PlayerThink", function(player)
	if(not Valid(player.mo, "helcurt") or not PAlive(player)) then
		return
	end
	
	--[[
	Stinger recharge is removed because the player cannot control and track stingers,
	and since they change your momentum on release, it is important for a player track them
	
	--Code below automatically recharges the stingers (faster in darkness)
	-- print(player.mo.stinger_charge_countdown)
	--Have max stingers ALL THE TIME if concealed
	if(player.mo.isconcealed == 1 and player.mo.stingers < MAX_STINGERS) then
		AddStingers(player.mo, MAX_STINGERS)
	--Recharge stingers over time normally
	else
		--IF less than maxinteger stingers: start the countdown
		if(player.mo.stingers < MAX_STINGERS and player.mo.stinger_charge_countdown <= -1) then
			player.mo.stinger_charge_countdown = STINGER_CHARGE_TIMER
		--Keep counting if the countdown has not ended
		elseif(player.mo.stinger_charge_countdown > 0) then
			player.mo.stinger_charge_countdown = $-1
		--If countdown ended: give a stinger
		elseif(player.mo.stinger_charge_countdown == 0) then
			AddStingers(player.mo, 1)
			player.mo.stinger_charge_countdown = $-1
		end
	end
	]]--
end)

addHook("PostThinkFrame", function()
	for player in players.iterate() do
		if(not Valid(player.mo, "helcurt") or not PAlive(player)) then
			return
		end
		
		--Ensure a valid sector
		if(player.mo and player.mo.subsector and player.mo.subsector.sector) then
			local sector = player.mo.subsector.sector 
			-- print("level:         " ..sector.lightlevel)
			
			--Check for overall lightlevel to conceal if dark enough
			if(sector.lightlevel <= CONCEAL_SHADOW_LEVEL) then
				Conceal(player)
			else
				--Finds all floor-over-floor to check for lightlevel of shadows under blocks 
				for fof in sector.ffloors() do
					-- print(fof.flags&FF_REVERSEPLATFORM)--FF_PLATFORM)
					
					--Check for lightlevel under blocks to conceal if dark enough
					--Ignore certain fof's since they trigger conceal when it is not dark enough
					--(standing above water would have triggered this affect)
					if(fof.toplightlevel ~= nil and fof.toplightlevel <= CONCEAL_SHADOW_LEVEL and
				fof.flags^^FF_SWIMMABLE|FF_NOSHADE == 0) then
						Conceal(player)
						-- print("fov-level:     " ..fof.toplightlevel)
						break
					end
				end
				--Checking if its concealed is uncessessary
				player.mo.isconcealed = 0
			end
		end
	end
end)

-- COM_AddCommand("la", function(player, lightlevel)
-- 	for sector in sectors.iterate do
--        sector.lightlevel = lightlevel
--     end
-- end)
-- COM_AddCommand("l", function(player, lightlevel)
-- 	local sector = player.mo.subsector.sector 
-- 	sector.lightlevel = lightlevel
-- end)