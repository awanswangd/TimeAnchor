extends CanvasLayer

func _ready() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		toggle_pause()

func toggle_pause() -> void:
	var is_paused = not get_tree().paused
	get_tree().paused = is_paused
	visible = is_paused
	if AudioManager != null and AudioManager.has_method("pause_bgm"):
		AudioManager.pause_bgm(is_paused)


func _on_resume_button_pressed() -> void:
	toggle_pause()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false 
	if AudioManager != null and AudioManager.has_method("stop_bgm"):
		AudioManager.stop_bgm()
	Transition.change_scene("res://Scene/main_menu.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
