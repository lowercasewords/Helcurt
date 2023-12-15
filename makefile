OUTPK3 = out.pk3
EXECUTABLE = /Applications/Games/Sonic\ Robo\ Blast\ 2.app/Contents/MacOS/Sonic\ Robo\ Blast\ 2
DIRS = Skins Lua Sounds Soc Sprites
PRIORITY_FILES = Skins/S_SKIN.txt Lua/Def.lua

SKIN = skin helcurt
MAP = map01
CHEATS = "godmode 1" "devmode 1"

all: build launch
	echo "done!"

launch: 
	$(EXECUTABLE) -file $(OUTPK3) -warp $(MAP) + $(SKIN)

build:
	zip $(OUTPK3) $(DIRS)
	zip $(OUTPK3) $(PRIORITY_FILES)
	zip $(OUTPK3) -r $(DIRS) -x $(PRIORITY_FILES) -x *.DS_Store -x *.bak

clean:
	rm $(OUTPK3)
