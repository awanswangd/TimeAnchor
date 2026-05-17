extends CanvasLayer

@onready var health_label: Label = $HealthLabel
@onready var energy_label: Label = $EnergyLabel
@onready var game_over_panel: Panel = $GameOverPanel
@onready var restart_button: Button = $GameOverPanel/HBoxContainer/RestartButton
@onready var exit_button: Button = $GameOverPanel/HBoxContainer/ExitButton
@onready var warp_timer_label: Label = $WarpTimerLabel
@onready var you_win_panel: Panel = $WinningPanel
func _ready() -> void:
	restart_button.pressed.connect(restart_game)
	
	var player = get_tree().get_first_node_in_group("player")
	if player != null:
		player.health_changed.connect(update_health)
		player.energy_changed.connect(update_energy)
		player.player_died.connect(show_game_over)
		
		update_health(player.current_health)
		update_energy(player.current_energy)

func update_health(new_health: int) -> void:
	health_label.text = "HP: " + str(new_health)

func update_energy(new_energy: int) -> void:
	energy_label.text = "Energi: " + str(new_energy)

func show_game_over() -> void:
	game_over_panel.show() 
	get_tree().paused = true

func show_win() -> void:
	if you_win_panel != null:
		you_win_panel.show()
	get_tree().paused = true 

func hide_warp_timer() -> void:
	var label = get_node_or_null("WarpTimerLabel")
	if label != null:
		label.text = ""
		label.hide()

func show_survival_objective() -> void:
	var obj_label = get_node_or_null("ObjectiveLabel")
	if obj_label != null:
		obj_label.text = "BERTAHAN HINGGA WAKTU HITUNG MUNDUR SELESAI!"
		obj_label.show()
		await get_tree().create_timer(2.0).timeout
		obj_label.hide()

func update_warp_timer(waktu: float) -> void:
	var label = get_node_or_null("WarpTimerLabel")
	if label != null:
		label.show()
		label.text = "WARP DALAM: " + str(ceil(waktu))

func restart_game() -> void:
	get_tree().paused = false 
	get_tree().reload_current_scene() 
