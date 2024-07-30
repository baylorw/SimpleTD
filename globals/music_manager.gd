extends AudioStreamPlayer2D

var songs := {}

func _ready():
	load_songs()

func load_songs():
	print("loading songs")
	songs["adventure"] = load("res://assets/audio/music/time_for_adventure.mp3")
	songs["apple"] = load("res://assets/audio/music/Apple Cider.mp3")
	songs["celtic"] = load("res://assets/audio/music/Edgen - Celtic Lore.ogg")
	songs["fruit"] = load("res://assets/audio/music/fruits_basket.ogg")
	songs["insect"] = load("res://assets/audio/music/Insect Factory.mp3")
	songs["loser"] = load("res://assets/audio/effects/homer_confused.wav")

func play_song(song_name : String):
	if !songs.has(song_name):
		print("Invalid song: " + song_name)
	stream = songs[song_name]
	play()
