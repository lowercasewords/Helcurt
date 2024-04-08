--How dark the area has to be to activate his passive
local CONCEAL_DARKNESS_LEVEL = 210
--How dark the area has to be to activate his passive
local CONCEAL_SHADOW_DIFFERENCE = 20
--Default time to wait for a single stinger to charge  
local STINGER_CHARGE_TIMER = 5*TICRATE

--Conceals the player in the darkness
--Called every tic to maintain frame preferences!
local function Conceal(player)
	-- print("Conceal!")

	if(player.mo.isconcealed == 0) then
		S_StartSound(player.mo, sfx_hide1)
	end
	player.mo.isconcealed = 1
	player.mo.frame = $|FF_TRANS50--|FF_FULLBRIGHT
end


addHook("PlayerThink", function(player)
	if(not player or not player.mo or player.mo.skin ~= "helcurt") then
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
		if(not player or not player.mo or player.mo.skin ~= "helcurt") then
			return
		end
		
		
		
		--Ensure a valid sector
		if(player.mo and player.mo.subsector and player.mo.subsector.sector) then
			local sector = player.mo.subsector.sector 
			local should_conceal = 0

			--Check for overall lightlevel to conceal if dark enough
			if(sector.lightlevel <= CONCEAL_DARKNESS_LEVEL) then
				should_conceal = 1
			else
				--Finds all floor-over-floor to check for lightlevel of shadows under blocks 
				for fof in sector.ffloors() do
					
					--Check for lightlevel under blocks to conceal if dark enough
					--Ignore certain fof's since they trigger conceal when it is not dark enough
					--(standing above water would have triggered this affect)
					if(player.mo.z < fof.bottomheight and fof.toplightlevel < CONCEAL_DARKNESS_LEVEL and fof.flags&FF_SWIMMABLE == 0) then
						should_conceal = 1
						print(sector.lightlevel.." - "..fof.toplightlevel..": "..CONCEAL_DARKNESS_LEVEL)
						break
					end
				end
				print("---")
				-- print(player.mo.isconcealed)
				--Checking if its concealed is uncessessary
				-- player.mo.isconcealed = 0
			end
			if(should_conceal == 1) then
				Conceal(player)
			else 
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