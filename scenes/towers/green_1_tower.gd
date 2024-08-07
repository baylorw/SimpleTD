class_name Green1Tower extends GreenTower

func _ready() -> void:
	super._ready()
	max_targets = 1
	purpose = "Fast tower."

func get_description() -> String:
	return super.get_description()
