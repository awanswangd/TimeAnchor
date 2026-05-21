extends Control

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var setting_button: Button = $VBoxContainer/SettingButton
@onready var quit_button: Button = $VBoxContainer/ExitButton
@onready var panel: Panel = $SettingPanel

@onready var bgm_slider: HSlider = $SettingPanel/BGMSlider
@onready var sfx_slider: HSlider = $SettingPanel/SFXSlider
var bgm_bus_id: int
var sfx_bus_id: int

@export var Bgm_Lobby: AudioStream

func _ready() -> void:
	AudioManager.play_bgm(Bgm_Lobby)
	play_button.pressed.connect(_on_play_pressed)
	setting_button.pressed.connect(_on_setting_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	bgm_bus_id = AudioServer.get_bus_index("BGM")
	sfx_bus_id = AudioServer.get_bus_index("SFX")
	
	bgm_slider.value_changed.connect(_on_bgm_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	
	bgm_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bgm_bus_id))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_id))

func _on_play_pressed() -> void:
	AudioManager.stop_bgm()
	Transition.change_scene("res://Scene/main.tscn")

func _on_setting_pressed() -> void:
	panel.show()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_close_button_pressed() -> void:
	panel.hide()

func _on_bgm_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bgm_bus_id, linear_to_db(value))

func _on_sfx_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus_id, linear_to_db(value))
