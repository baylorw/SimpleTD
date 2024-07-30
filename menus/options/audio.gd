extends TabBar

@onready var tab_container = $".."

#var background_track

func _ready():
	%Master.value = SettingsFile.config.get_value("Audio", str(0))
	AudioServer.set_bus_volume_db(0, linear_to_db(%Master.value))
	%Music.value = SettingsFile.config.get_value("Audio", str(1))
	AudioServer.set_bus_volume_db(1, linear_to_db(%Music.value))
	%SFX.value = SettingsFile.config.get_value("Audio", str(2))
	AudioServer.set_bus_volume_db(2, linear_to_db(%SFX.value))
	
	Music.play_song("apple")

func _on_master_value_changed(value):
	set_volume(0, value)

func _on_music_value_changed(value):
	set_volume(1, value)

func _on_sfx_value_changed(value):
	set_volume(2, value)

func set_volume(bus_index, value):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index, value < 0.05)
	SettingsFile.config.set_value("Audio", str(bus_index), value)
	SettingsFile.save_data()

## NONE OF THIS WORKS
## Looks like Godot's TabBar events are broken. Events are never fired.
func _on_tab_changed(tab):
	print("Audio tab - _on_tab_changed() " + str(tab))
func _on_tab_button_pressed(tab):
	print("Audio tab - _on_tab_button_pressed() " + str(tab))
func _on_tab_clicked(tab):
	print("Audio tab - _on_tab_clicked() " + str(tab))
func _on_tab_selected(tab):
	print("Audio tab - _on_tab_selected() " + str(tab))
func _on_tab_hovered(tab):
	print("Audio tab - _on_tab_hovered() " + str(tab))
