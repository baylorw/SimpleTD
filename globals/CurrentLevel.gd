extends Node

var base_health := 10
var base_health_max := 10
var creeps_killed := 0
var money := 300
var money_starting := 300

var wave_number := 0
var wave_number_max := 3
#--- If a wave has 20 creeps spawning twice per second, which creep is it on?
var wave_tick := 0

enum LevelStatus {BUILD, WAVE, WON, LOST}
var level_status : LevelStatus = LevelStatus.BUILD

func reset():
	level_status = LevelStatus.BUILD
	base_health = base_health_max
	money = money_starting
	wave_number = 0
	creeps_killed = 0
