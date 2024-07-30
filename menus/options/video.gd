extends TabBar

var old_window_size
var resolutions : Dictionary = { 
	"3840x2160": Vector2i(3840,2160),
	"2560x1440": Vector2i(2560,1440),
	"1920x1080": Vector2i(1920,1080),
	"1536x864": Vector2i(1536,864),
	"1366x768": Vector2i(1366,768),
	"1280x720": Vector2i(1280,720),
	"1440x900": Vector2i(1440,900),
	"1600x900": Vector2i(1600,900),
	"1024x768": Vector2i(1024,768),
	"1024x600": Vector2i(1024,600),
	"800x600": Vector2i(800,600)
}


func _ready():
	var screen_type = SettingsFile.config.get_value("Video", "fullscreen")
	if screen_type == DisplayServer.WINDOW_MODE_FULLSCREEN:
		%FullScreen.button_pressed = true
	
	var borderless_type = SettingsFile.config.get_value("Video", "borderless")
	%Borderless.button_pressed = borderless_type

	var vsync_index = SettingsFile.config.get_value("Video", "vsync")
	%VSync.selected = vsync_index
	
	for r in resolutions:
		%Resolution.add_item(r)
	var window_size = SettingsFile.config.get_value("Video", "resolution")
	for i in resolutions.size():
		var key = resolutions.keys()[i]
		if resolutions[key] == window_size:
			%Resolution.selected = i
			break

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

func _on_resolution_item_selected(index: int) -> void:
	if index <= 0:
		print("Invalid resolution index="+ str(index))
		return
	var selected_resolution = %Resolution.get_item_text(index)
	var desired_resolution = resolutions[selected_resolution]
	old_window_size = get_window().get_size()
	var actual_current_screen_resolution =  DisplayServer.screen_get_size()
	#print("Screen resolution="+str(actual_current_screen_resolution))
	print("switching from " + str(old_window_size) + " to " + str(desired_resolution))
	get_window().set_size(desired_resolution)
	center_window()
	
	#--- Have them confirm the switch is what they want.
	%ResolutionConfirmationDialog.show()
	await get_tree().create_timer(3).timeout
	if %ResolutionConfirmationDialog.visible:
		%ResolutionConfirmationDialog.hide()
		_on_resolution_confirmation_dialog_canceled()

func _on_resolution_confirmation_dialog_canceled():
	get_window().set_size(old_window_size)
	center_window()

func _on_resolution_confirmation_dialog_confirmed() -> void:
	var current_size = get_window().get_size()
	SettingsFile.config.set_value("Video", "resolution", current_size)
	SettingsFile.save_data()

func center_window():
	var center_point = DisplayServer.screen_get_position() + (DisplayServer.screen_get_size() / 2)
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(center_point - (window_size / 2))

## VSYNC_DISABLED = 0
## VSYNC_ENABLED  = 1
## VSYNC_ADAPTIVE = 2
## VSYNC_MAILBOX  = 3
func _on_v_sync_item_selected(index):
	DisplayServer.window_set_vsync_mode(index)
	SettingsFile.config.set_value("Video", "vsync", index)
	SettingsFile.save_data()
