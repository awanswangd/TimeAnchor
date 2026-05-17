extends Node

@export var survival_duration: float = 5.0 # Tes 5 detik dulu
@export var warp_duration: float = 60.0 

var current_timer: float = 0.0
var is_warp_phase: bool = false
var ui_manager: CanvasLayer

# --- Sistem Bos Tentakel ---
var tentacle_scene = preload("res://Scene/Tentacle.tscn") # Pastikan path-nya benar!
var tentacles_left: int = 0

func _ready() -> void:
	ui_manager = get_parent().get_node("UIManager")
	if ui_manager != null and ui_manager.has_method("hide_warp_timer"):
		ui_manager.hide_warp_timer()
		
	current_timer = survival_duration

func _process(delta: float) -> void:
	if ui_manager == null: return
	
	current_timer -= delta
	
	if not is_warp_phase:
		if current_timer <= 0:
			start_warp_phase()
	else:
		if ui_manager.has_method("update_warp_timer"):
			ui_manager.update_warp_timer(current_timer)
			
		if current_timer <= 0:
			trigger_game_over_warp_failed()

func start_warp_phase() -> void:
	is_warp_phase = true
	current_timer = warp_duration
	print("ALARM! WARP SEQUENCE INITIATED!")
	
	spawn_tentacles()

func spawn_tentacles() -> void:
	# Koordinat kemunculan 4 tentakel (sesuaikan dengan ukuran layar kameramu)
	# Contoh ini untuk resolusi standar 1152x648
	var spawn_points = [
		Vector2(100, 100),   # Kiri Atas
		Vector2(1050, 100),  # Kanan Atas
		Vector2(100, 550),   # Kiri Bawah
		Vector2(1050, 550)   # Kanan Bawah
	]
	
	for point in spawn_points:
		var tentacle = tentacle_scene.instantiate()
		tentacle.global_position = point
		get_parent().add_child(tentacle)
		tentacles_left += 1
		
	print("4 TENTAKEL KOSMIK MUNCUL!")

func tentacle_destroyed() -> void:
	tentacles_left -= 1
	print("Sisa Tentakel: ", tentacles_left)
	
	if tentacles_left <= 0:
		trigger_you_win()

func trigger_game_over_warp_failed() -> void:
	print("WAKTU HABIS! KAPAL HANCUR!")
	if ui_manager.has_method("show_game_over"):
		ui_manager.show_game_over()
		set_process(false) 

func trigger_you_win() -> void:
	print("SEMUA TENTAKEL HANCUR! WARP BERHASIL!")
	if ui_manager.has_method("show_you_win"): # Pastikan UIManager punya fungsi ini (dari kode kita pas Subuh)
		ui_manager.show_you_win()
		set_process(false)
