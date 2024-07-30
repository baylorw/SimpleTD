extends AudioStreamPlayer2D

var sounds := {}

func _ready():
	load_sounds()

func load_sounds():
	print("loading sfx")
	sounds["cannon"] = load("res://assets/audio/effects/cannon_shell.wav")
	sounds["gatling"] = load("res://assets/audio/effects/gatling.wav")
	sounds["homer_confused"] = load("res://assets/audio/effects/homer_confused.wav")
	sounds["jump"] = load("res://assets/audio/effects/jump.wav")
	sounds["sakura"] = load("res://assets/audio/effects/sakura.wav")

func play_sound(sound_name : String):
	if !sounds.has(sound_name):
		print("Invalid SDX=" + sound_name)
	stream = sounds[sound_name]
	play()
