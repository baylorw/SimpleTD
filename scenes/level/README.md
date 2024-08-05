Here's what finally worked:

LevelData
- LevelData = MarginContainer or PanelContainer (not Center)
- Must set all variables then (all onready before will be invalid)
- Must use full path name, the % don't carry over to the scene that loaded you
- Have to setup in code signal subscribers

```
var packed_scene = load(Globals.level_name)
var play_area = packed_scene.instantiate()
%LevelData.add_child(play_area)
kill_zone = %LevelData/Map/Paths/KillZone
kill_zone.body_entered.connect(_on_kill_zone_body_entered)
```
