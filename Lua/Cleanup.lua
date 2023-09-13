
///-------------------------
/// Mainly consists of behavior that should be in the last tics!
///-------------------------

addHook("PlayerThink", function(player)
	//HAS TO BE THE LAST STATE CHANGE/READ,
	//Records the previous state
	player.mo.prevstate = player.mo.state
end)