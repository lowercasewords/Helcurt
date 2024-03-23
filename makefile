OUTPK3 = out.pk3
EXECUTABLE = /Applications/Games/Sonic\ Robo\ Blast\ 2.app/Contents/MacOS/Sonic\ Robo\ Blast\ 2
DIRS = Lua Sprites Skins Sounds Soc 
PRIORITY_FILES = Skins/S_SKIN Lua/Def.lua

SKIN = skin helcurt
MAP = map01
CHEATS = "godmode 1" "devmode 1"

# Sometimes LUA are not loaded so they need to be refreshed by going into slade and saving any file
all: clean build launch
	echo "done!"

launch: 
	$(EXECUTABLE) -file $(OUTPK3) -warp $(MAP) + $(SKIN)
build:
	#Zips correctly with correct indecies for S_SKIN and Def.lua, but
	#the game doesn't load other lua and sprite files at all for some reason,
	#despite them being in the pk3.
	# zip $(OUTPK3) $(DIRS)
	# zip $(OUTPK3) $(PRIORITY_FILES)
	# zip $(OUTPK3) -r $(DIRS) -x $(PRIORITY_FILES) -x *.DS_Store -x *.bak
	
	#Less fancy but it works. Use this until I can figure out the issue.
	#Note: the project won't get big and I don't want to waste time fixing
	#this minor issue, so this will be enough :3
	zip $(OUTPK3) Skins/S_SKIN
	zip $(OUTPK3) -r Soc
	zip $(OUTPK3) -r Skins
	zip $(OUTPK3) -r Lua
	zip $(OUTPK3) -r Sprites
	zip $(OUTPK3) -r Sounds
clean:
	-rm $(OUTPK3)
