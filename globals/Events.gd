extends Node

signal build_tower_button_pressed
signal dialog_finished
signal level_loaded
#signal step_finished
signal tower_built
signal tower_sold
signal tower_upgraded
signal tower_targeting_changed
signal wave_ended
signal wave_started

# Put formal, typeed signals in one place so people know where to get them
# User needs to know name of signal? Actually it takes strings so maybe not.
# This isn't for generic events, still need to know the name
#To use:
#Events.PLAYER_HEALTH_UPDATED.emit(health)
#Events.connect("PLAYER_HEALTH_UPDATED", on_player_health_updated)
