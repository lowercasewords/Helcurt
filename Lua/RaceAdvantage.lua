--How dark the area has to be to activate his passive
local CONCEAL_DARKNESS_LEVEL = 210
--How dark the area has to be to activate his passive
local CONCEAL_SHADOW_DIFFERENCE = 20
--Default time to wait for a single stinger to charge  
local STINGER_CHARGE_TIMER = 5*TICRATE

--Conceals the player in the darkness (called once)
local function Conceal(mo)
	S_StartSound(mo, sfx_hide1)
	mo.unconceal_timer = UNCONCEAL_MAX_TICS
end

--Conceal effects to be put every tic 
local function ConcealEffects(mo)
	mo.frame = $|FF_TRANS50--|FF_FULLBRIGHT
end

--Stops concealing the player in the darkness (called once)
local function Unconceal(mo)
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
	if(player.mo.unconceal_timer == 1 and player.mo.stingers < MAX_STINGERS) then
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
		local dark_enough = 0
		
		--Try to find a place dark enough to be concealed in
		if(player.mo.subsector and player.mo.subsector.sector) then
			local sector = player.mo.subsector.sector 

			--Check for overall lightlevel to conceal if dark enough
			if(sector.lightlevel <= CONCEAL_DARKNESS_LEVEL) then
				dark_enough = 1

			--Finds all floor-over-floor to check for lightlevel of shadows under blocks 
			else
				for fof in sector.ffloors() do
					
					--Check for lightlevel under blocks to conceal if dark enough
					--Ignore certain fof's since they trigger conceal when it is not dark enough
					--(standing above water would have triggered this affect)
					if(player.mo.z < fof.bottomheight and fof.toplightlevel < CONCEAL_DARKNESS_LEVEL and fof.flags&FF_SWIMMABLE == 0) then
						dark_enough = 1
						break
					end
				end
			end

			--Conceal if possible and not concealed already
			if(dark_enough == 1 and player.mo.unconceal_timer <= 0) then
				Conceal(player.mo)
			--If time is up on concealment -> Unconceal
			elseif(player.mo.unconceal_timer == 0) then
				Unconceal(player.mo)
			end
		end
		
		--While concealed
		if(player.mo.unconceal_timer >= 0) then
		 	ConcealEffects(player.mo)
			--Counting down the timer to be concealed when not dark enough
			if(dark_enough == 0) then
				player.mo.unconceal_timer = $-1
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