extends CanvasLayer
@onready var setting_button: Button = $VBoxContainer/SettingButton
@onready var spanel: Panel = $SettingPanel
@onready var bgm_slider: HSlider = $SettingPanel/BGMSlider
@onready var sfx_slider: HSlider = $SettingPanel/SFXSlider
var bgm_bus_id: int
var sfx_bus_id: int

func _ready() -> void:
	hide()
	bgm_bus_id = AudioServer.get_bus_index("BGM")
	sfx_bus_id = AudioServer.get_bus_index("SFX")
	
	bgm_slider.value_changed.connect(_on_bgm_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	
	bgm_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bgm_bus_id))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_id))

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

func _on_setting_button_pressed() -> void:
	spanel.show()
	
func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false 
	if AudioManager != null and AudioManager.has_method("stop_bgm"):
		AudioManager.stop_bgm()
	Transition.change_scene("res://Scene/main_menu.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_close_button_pressed() -> void:
	spanel.hide()

func _on_bgm_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bgm_bus_id, linear_to_db(value))

func _on_sfx_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus_id, linear_to_db(value))
