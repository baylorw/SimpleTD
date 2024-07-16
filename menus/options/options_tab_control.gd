extends TabContainer

func _on_tab_changed(tab):
	if tab == 1:
		Music.play()
	else:
		Music.stop()
