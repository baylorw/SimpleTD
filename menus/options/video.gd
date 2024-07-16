extends TabBar

func _ready():
	var screen_type = SettingsFile.config.get_value("Video", "fullscreen")
	if screen_type == DisplayServer.WINDOW_MODE_FULLSCREEN:
		%FullScreen.button_pressed = true

	var borderless_type = SettingsFile.config.get_value("Video", "borderless")
	%Borderless.button_pressed = borderless_type

	var vsync_index = SettingsFile.config.get_value("Video", "vsync")
	%VSync.selected = vsync_index

func _on_full_screen_toggled(toggled_on):
	var window_mode = DisplayServer.WINDOW_MODE_WINDOWED
	if toggled_on:
		window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(window_mode)
	SettingsFile.config.set_value("Video", "fullscreen", window_mode)
	SettingsFile.save_data()

func _on_borderless_toggled(toggled_on):
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, toggled_on)
	SettingsFile.config.set_value("Video", "borderless", toggled_on)
	SettingsFile.save_data()

## VSYNC_DISABLED = 0
## VSYNC_ENABLED  = 1
## VSYNC_ADAPTIVE = 2
## VSYNC_MAILBOX  = 3
func _on_v_sync_item_selected(index):
	DisplayServer.window_set_vsync_mode(index)
	SettingsFile.config.set_value("Video", "vsync", index)
	SettingsFile.save_data()
