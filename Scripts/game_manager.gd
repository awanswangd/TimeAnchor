extends Node

@export var ui_manager: CanvasLayer # <--- Tambahkan @export di sini

@export var survival_duration: float = 5.0 # Kita set 5 detik dulu buat ngetes
@export var warp_duration: float = 60.0 

var current_timer: float = 0.0
var is_warp_phase: bool = false

func _ready() -> void:
	ui_manager = get_parent().get_node("UIManager")
	if ui_manager == null:
		print("Waduh, UIManager beneran ga ketemu! Pastikan nama nodenya persis 'UIManager' ya.")
		return
	if ui_manager.has_method("hide_warp_timer"):
		ui_manager.hide_warp_timer() 
		
	current_timer = survival_duration

func _process(delta: float) -> void:
	if ui_manager == null: return # Biar ga error kalau kosong
	
	current_timer -= delta
	
	if not is_warp_phase:
		if current_timer <= 0:
			start_warp_phase()
	else:
		# Fase Warp
		if ui_manager.has_method("update_warp_timer"):
			ui_manager.update_warp_timer(current_timer)
		if current_timer <= 0:
			trigger_game_over_warp_failed()

func start_warp_phase() -> void:
	is_warp_phase = true
	current_timer = warp_duration
	print("ALARM! WARP SEQUENCE INITIATED!")
	ui_manager.warp_timer_label.modulate = Color.RED 

func trigger_game_over_warp_failed() -> void:
	print("WAKTU HABIS! KAPAL HANCUR!")
	if ui_manager.has_method("show_game_over"):
		ui_manager.show_game_over()
		set_process(false)
