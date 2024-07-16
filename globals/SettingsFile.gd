extends Node

const PATH = "user://settings.cfg"
var config = ConfigFile.new()

func _ready():
	print("Persistence _ready()")
	#--- Default values in case load_data() doesn't load keys for these.
	for action in InputMap.get_actions():
		if InputMap.action_get_events(action).size() != 0:
			config.set_value("Controls", action, InputMap.action_get_events(action)[0])
	config.set_value("Video", "fullscreen", DisplayServer.WINDOW_MODE_WINDOWED)
	config.set_value("Video", "borderless", DisplayServer.WINDOW_MODE_WINDOWED)
	config.set_value("Video", "vsync", DisplayServer.WINDOW_MODE_WINDOWED)
	for bus_index in 3:
		config.set_value("Audio", str(bus_index), 100.0)

	load_data()
	
## Only do this if you're letting the user remap keys.
func load_control_settings():
	#--- By default we won't let users remap keys.
	return
	
	#var keys = config.get_section_keys("Controls")
	#for action in InputMap.get_actions():
		#if keys.has(action):
			#var value = config.get_value("Controls", action)
			#InputMap.action_erase_events(action)
			#InputMap.action_add_event(action, value)

func load_data():
	print("Persistence load_data()")
	if config.load(PATH) != OK:
		save_data()
		return
	print("Persistence - config file existed so loading settings")
	load_control_settings()
	load_video_settings()
	
func load_video_settings():
	var screen_type = config.get_value("Video", "fullscreen")
	print("loaded screen_type=" + str(screen_type))
	DisplayServer.window_set_mode(screen_type)
	
	var borderless = config.get_value("Video", "borderless")
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, borderless)
	
	var vsync_index = config.get_value("Video", "vsync")
	DisplayServer.window_set_vsync_mode(vsync_index)

func save_data():
	print("Saving config to " + PATH)
	#--- Saves to 
	# %appdata%\Godot\app_userdata\Complete Game Template
	# C:\Users\baylor\AppData\Roaming\Godot\app_userdata\Complete Game Template
	config.save(PATH)
