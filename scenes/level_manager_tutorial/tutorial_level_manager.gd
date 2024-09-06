extends LevelManager

var tutorial_step: int = 0
var dialogue_step: int = 0
const DIALOGUES: Dictionary = {
	"0" = { # intro
		"0" = "Welcome to first step.",
		"1" = "In this step, let's do this thing.",
	 },
	"1" = { # Show a loaded map beating creeps
		"0" = "See th",
		"1" = "Now let's do the next thing",
	 },
	"2" = { # point to money
		"0" = "Now let's do the next thing",
	 }
	# hover over mouse to see info
	# select G1
	# arrows and bright start strobing box show the path to take
	# place at position on path 1
	# press start then wait
	# won some money. see the wave counter? 
	# Next guys will be fast. Use a slowing tower on path 2
	# press start
	# that's it. Try some real levels now. click quit to go back
}

func _ready():
	super._ready()
