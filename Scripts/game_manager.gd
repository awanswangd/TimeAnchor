extends Node

@export var survival_duration: float = 5.0 # Tes 5 detik dulu
@export var warp_duration: float = 60.0 

var current_timer: float = 0.0
var is_warp_phase: bool = false
var ui_manager: CanvasLayer
var dialog_scene = preload("res://Scene/DialogOverlay.tscn")
var tentacle_scene = preload("res://Scene/Tentacle.tscn") 
var tentacles_left: int = 0

func _ready() -> void:
	ui_manager = get_parent().get_node("UIManager")
	if ui_manager != null and ui_manager.has_method("hide_warp_timer"):
		ui_manager.hide_warp_timer()
		
	current_timer = survival_duration
	if dialog_scene != null:
		var dialog_instance = dialog_scene.instantiate()
		dialog_instance.dialog_queue = [
			"Sistem|Peringatan: Integritas lambung kapal menurun kritis.",
			"Kapten|Sial! Kita terjebak di anomali waktu. Aku harus menggunakan Time Anchor!",
			"Kapten|Kumpulkan energi untuk menyalakan mesin Warp sebelum terlambat!"
		]
		get_parent().add_child.call_deferred(dialog_instance)

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
			if tentacles_left <= 0:
				trigger_you_win()
			else:
				trigger_game_over_warp_failed()

func start_warp_phase() -> void:
	is_warp_phase = true
	current_timer = warp_duration
	print("ALARM! WARP SEQUENCE INITIATED!")
	
	spawn_tentacles()

func spawn_tentacles() -> void:
	var arena = get_tree().get_first_node_in_group("arena")
	if arena == null:
		print("Waduh, TileMapLayer 'arena' ga ketemu!")
		return
	var used_rect = arena.get_used_rect()
	var padding = 2 
	var top_left_grid = Vector2i(used_rect.position.x + padding, used_rect.position.y + padding)
	var top_right_grid = Vector2i(used_rect.end.x - padding, used_rect.position.y + padding)
	var bottom_left_grid = Vector2i(used_rect.position.x + padding, used_rect.end.y - padding)
	var bottom_right_grid = Vector2i(used_rect.end.x - padding, used_rect.end.y - padding)

	var spawn_points = [
		arena.to_global(arena.map_to_local(top_left_grid)),
		arena.to_global(arena.map_to_local(top_right_grid)),
		arena.to_global(arena.map_to_local(bottom_left_grid)),
		arena.to_global(arena.map_to_local(bottom_right_grid))
	]
	
	for point in spawn_points:
		if tentacle_scene != null:
			var tentacle = tentacle_scene.instantiate()
			tentacle.global_position = point
			get_parent().add_child(tentacle)
			tentacles_left += 1
		else:
			print("ERROR: tentacle_scene belum di-load di GameManager!")
			
	print("4 TENTAKEL KOSMIK MUNCUL")

func tentacle_destroyed() -> void:
	tentacles_left -= 1
	print("Sisa Tentakel: ", tentacles_left)
	
	if tentacles_left <= 0:
		print("JALUR WARP BERSIH! BERTAHANLAH SAMPAI WAKTU HABIS!")
		if ui_manager != null and ui_manager.has_method("show_survival_objective"):
			ui_manager.show_survival_objective()
		
func trigger_game_over_warp_failed() -> void:
	print("WAKTU HABIS! KAPAL HANCUR!")
	if ui_manager.has_method("show_game_over"):
		ui_manager.show_game_over()
		set_process(false) 

func trigger_you_win() -> void:
	print("SEMUA TENTAKEL HANCUR! WARP BERHASIL!")
	if ui_manager.has_method("show_win"): 
		ui_manager.show_win()
		set_process(false)
