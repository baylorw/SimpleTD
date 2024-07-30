extends Node

const PATH = "user://settings.cfg"
var config = ConfigFile.new()

func _ready():
	print("SettingsFile _ready()")
	set_defaults()
	load_data()

func load_audio_settings():
	var master_value = SettingsFile.config.get_value("Audio", str(0))
	AudioServer.set_bus_volume_db(0, linear_to_db(master_value))
	var music_value = SettingsFile.config.get_value("Audio", str(1))
	AudioServer.set_bus_volume_db(1, linear_to_db(music_value))
	var sfx_value = SettingsFile.config.get_value("Audio", str(2))
	AudioServer.set_bus_volume_db(2, linear_to_db(sfx_value))

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
	load_audio_settings()
	load_control_settings()
	load_video_settings()

## These are the values to use if the settings file we load doesn't have a value for a setting.
func set_defaults():
	#--- Key bindings
	for action in InputMap.get_actions():
		if InputMap.action_get_events(action).size() != 0:
			config.set_value("Controls", action, InputMap.action_get_events(action)[0])
	#--- Video
	config.set_value("Video", "fullscreen", DisplayServer.WINDOW_MODE_WINDOWED)
	config.set_value("Video", "borderless", DisplayServer.WINDOW_MODE_WINDOWED)
	config.set_value("Video", "vsync", DisplayServer.WINDOW_MODE_WINDOWED)
	#--- Audio
	for bus_index in 3:
		config.set_value("Audio", str(bus_index), 100.0)

func load_video_settings():
	var screen_type = config.get_value("Video", "fullscreen")
	print("loaded screen_type=" + str(screen_type))
	DisplayServer.window_set_mode(screen_type)
	
	var borderless = config.get_value("Video", "borderless")
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, borderless)
	
	var vsync_index = config.get_value("Video", "vsync")
	DisplayServer.window_set_vsync_mode(vsync_index)
	
	var window_size = config.get_value("Video", "resolution")
	if (null != window_size):
		get_window().set_size(window_size)

func save_data():
	print("Saving config to " + PATH)
	#--- Saves to 
	# %appdata%\Godot\app_userdata\Complete Game Template
	# C:\Users\baylor\AppData\Roaming\Godot\app_userdata\Complete Game Template
	config.save(PATH)
