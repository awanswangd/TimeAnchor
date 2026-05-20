extends Control

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var quit_button: Button = $VBoxContainer/ExitButton
@export var Bgm_Lobby: AudioStream

func _ready() -> void:
	AudioManager.play_bgm(Bgm_Lobby)
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	AudioManager.stop_bgm()
	Transition.change_scene("res://Scene/main.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
