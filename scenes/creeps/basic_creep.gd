## For creeps that don't have any special behaviors that need code.
extends Creep

# This MUST be here or else you don't get the super class' export variables.
# Which is bullshit.
func _ready() -> void:
	super._ready()
