class_name TutorialStepManager extends Node

@export var tutorial_manager: TutorialManager

var current_step : TutorialStep
var step_number := 0

func _ready() -> void:
	#--- Tell all the states to let us know when they're done.
	for step:TutorialStep in get_children():
		#print("child " + step.name)
		step.finished.connect(on_step_finished)
	
	#--- There's an initialization race condition going on. Not sure if this helps.
	#await owner.ready

func start():
	current_step = get_child(step_number)
	#print_debug("FSM starting, passing in tutorial_manager=" + str(tutorial_manager))
	print("TutorialStepManager starting")
	current_step.enter(tutorial_manager)

func on_step_finished(step_name: String) -> void:
	print("on_step_finished() name=" + step_name)
	if (step_name != current_step.name):
		# Why am i in race condition hell? Events fire 5 times!!!
		printerr("WRONG EVENT: finished for %s when i am on %s" % [step_name, current_step.name])
		return
	tutorial_manager.hide_tutorial_stuff()
	current_step.exit()

	print("FINISHED step#=%s, step_object=%s" % [step_number, current_step.name])

	step_number += 1
	if step_number >= get_child_count():
		print("We ran out of steps. Why are we still here?")
		#SceneNavigation.go_to_level_manager()
		return
	current_step = get_child(step_number)
	print("STARTING step#=%s, step_object=%s" % [step_number, current_step.name])
	current_step.enter(tutorial_manager)
