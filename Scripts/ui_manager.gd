extends CanvasLayer
@onready var gameplay_hud: Control = $GameplayHUD
@onready var health_label: Label = $GameplayHUD/HealthBar/HealthLabel
@onready var energy_label: Label = $GameplayHUD/EnergyBar/EnergyLabel
@onready var game_over_panel: Panel = $GameOverPanel
@onready var restart_button: Button = $GameOverPanel/HBoxContainer/RestartButton
@onready var exit_button: Button = $GameOverPanel/HBoxContainer/MenuButton
@onready var warp_timer_label: Label = $GameplayHUD/WarpTimerLabel
@onready var you_win_panel: Panel = $WinningPanel
@onready var win_restart_button: Button = $WinningPanel/HBoxContainer/WinRestartButton
@onready var win_menu_button: Button = $WinningPanel/HBoxContainer/WinMenuButton
@onready var health_bar: ProgressBar = $GameplayHUD/HealthBar
@onready var energy_bar: ProgressBar = $GameplayHUD/EnergyBar
@onready var endgame_overlay: ColorRect = $EndgameOverlay

func _ready() -> void:
	restart_button.pressed.connect(restart_game)
	exit_button.pressed.connect(exit_game)
	if is_instance_valid(win_restart_button): win_restart_button.pressed.connect(restart_game)
	if is_instance_valid(win_menu_button): win_menu_button.pressed.connect(exit_game)
	var player = get_tree().get_first_node_in_group("player")
	if player != null:
		player.health_changed.connect(update_health)
		player.energy_changed.connect(update_energy)
		player.player_died.connect(show_game_over)
		
		update_health(player.current_health)
		update_energy(player.current_energy)

func update_health(new_health: int) -> void:
	if is_instance_valid(health_label):
		health_label.text = "HP: " + str(new_health)
	if is_instance_valid(health_bar):
		health_bar.value = new_health

func update_energy(new_energy: int) -> void:
	if is_instance_valid(energy_label):
		energy_label.text = "Energi: " + str(new_energy)
	if is_instance_valid(energy_bar):
		energy_bar.value = new_energy

func update_warp_timer(time_left: float) -> void:
	if warp_timer_label != null:
		var minutes: int = int(time_left) / 60
		var seconds: int = int(time_left) % 60
		warp_timer_label.text = "%02d:%02d" % [minutes, seconds]

func update_objective(teks_objektif: String) -> void:
	var obj_label = get_node_or_null("GameplayHUD/ObjectiveLabel") 
	
	if obj_label != null:
		obj_label.text = teks_objektif
		obj_label.show() 

func show_game_over() -> void:
	hide_hud()
	if game_over_panel != null:
		game_over_panel.show()
	get_tree().paused = true

func show_win() -> void:
	hide_hud()
	if you_win_panel != null:
		you_win_panel.show()
	get_tree().paused = true 

func show_warp_timer() -> void:
	if warp_timer_label != null:
		warp_timer_label.show()

func hide_warp_timer() -> void:
	if warp_timer_label != null:
		warp_timer_label.hide()

func show_survival_objective() -> void:
	var obj_label = get_node_or_null("ObjectiveLabel")
	if obj_label != null:
		obj_label.text = "BERTAHAN HINGGA WAKTU HITUNG MUNDUR SELESAI!"
		obj_label.show()
		await get_tree().create_timer(2.0).timeout
		obj_label.hide()

func restart_game() -> void:
	get_tree().paused = false 
	Transition.change_scene("res://Scene/main.tscn") 

func exit_game() -> void:
	get_tree().paused = false 
	Transition.change_scene("res://Scene/main_menu.tscn")

func hide_hud() -> void:
	if gameplay_hud != null:
		gameplay_hud.hide()
		
func show_hud() -> void:
	if gameplay_hud != null:
		gameplay_hud.show()

func play_victory_cinematic() -> void:
	hide_hud()
	get_tree().paused = true 
	
	endgame_overlay.color = Color(1, 1, 1, 0) 
	endgame_overlay.show()
	
	var tween = create_tween() 
	tween.tween_property(endgame_overlay, "color:a", 1.0, 0.4)
	
	await get_tree().create_timer(0.5, true).timeout
	
	if you_win_panel != null:
		you_win_panel.show()
		
	var tween_fade = create_tween()
	tween_fade.tween_property(endgame_overlay, "color:a", 0.0, 1.5)
	
	await tween_fade.finished
	endgame_overlay.hide()

func play_void_defeat_cinematic() -> void:
	hide_hud()
	get_tree().paused = true
	
	endgame_overlay.color = Color(0.5, 0, 0, 0) 
	endgame_overlay.show()
	
	var tween_glitch = create_tween()
	tween_glitch.tween_property(endgame_overlay, "color:a", 0.8, 0.1)
	tween_glitch.tween_property(endgame_overlay, "color:a", 0.2, 0.1)
	tween_glitch.tween_property(endgame_overlay, "color:a", 1.0, 0.5) 
	tween_glitch.parallel().tween_property(endgame_overlay, "color", Color(0, 0, 0, 1), 0.7) 
	
	await get_tree().create_timer(1.0, true).timeout
	
	if game_over_panel != null:
		var title_label = game_over_panel.get_node_or_null("TitleLabel") # Sesuaikan nama node teksmu
		if title_label != null:
			title_label.text = "TERSEDOT KE DALAM VOID\n[BAD ENDING]"
		game_over_panel.show()
