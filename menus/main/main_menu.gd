extends Control

@onready var languages_ddlb: OptionButton = $LanguagesDDLB

var english_index = 1
var languages := {
	"British":  "uk",
	"German":   "de",
	"English":  "en",
	"French":   "fr",
	"Japanese": "jp",
	"Latin":    "pl",
	"Spanish":  "es",
	"Thai":     "th"
}

func _ready() -> void:
	#Music.play_song("celtic")
	Music.play_song("insect")
	load_language_options()
	show_current_language()

func show_current_language():
	# TODO:  Put this in settings file
	var current_locale = TranslationServer.get_locale()
	if !languages.values().has(current_locale):
		current_locale = "en"
	var index = languages.values().find(current_locale)
	languages_ddlb.select(index)
	
func load_language_options():
	languages_ddlb.clear()
	for i in languages.size():
		var key   = languages.keys()[i]
		var value = languages[key]
		languages_ddlb.add_item(key, i)
		var props = { "locale": value }
		languages_ddlb.set_item_metadata(i, props)
	languages_ddlb.selected = english_index

func _on_option_button_item_selected(index: int) -> void:
	#var metadata = languages_ddlb.get_selected_metadata()
	var metadata = languages_ddlb.get_item_metadata(index)
	var locale = metadata["locale"]
	TranslationServer.set_locale(locale)

func _on_about_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/about/about_screen.tscn")
	
func _on_new_game_button_pressed():
	get_tree().change_scene_to_file("res://menus/level_selection/level_selection.tscn")

func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://menus/options/options_menu.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
