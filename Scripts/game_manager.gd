extends Node

enum Phase { ACT_1_TUTORIAL, ACT_2_SURVIVAL, ACT_3_BOSS }
var current_phase: Phase = Phase.ACT_1_TUTORIAL
@onready var black_hole_visual = get_node_or_null("BlackHole")
@export_category("Game Settings")
@export var tutorial_holes_amount: int = 5 #Jumlah lubang di Babak 1
@export var tutorial_enemy_amount: int = 3 #Jumlah musuh di Babak 1
@export var survival_duration: float = 120 #2 Menit untuk Babak 2
@export var warp_duration: float = 60 #Waktu nahan Black Hole di Babak 3

@export_category("Audio")
@export var bgm_act_1: AudioStream #Musik misterius/sepi
@export var bgm_act_2: AudioStream #Musik panik/survival
@export var bgm_act_3: AudioStream #Musik bos epik

var current_timer: float = 0.0
var tentacles_left: int = 0
var is_tutorial_setup_done: bool = false 
var is_game_active: bool = false 
var dialog_30s_played: bool = false
var dialog_10s_played: bool = false
var ui_manager: CanvasLayer
var dialog_scene = preload("res://Scene/DialogOverlay.tscn")
var tentacle_scene = preload("res://Scene/Tentacle.tscn") 

func _ready() -> void:
	get_tree().paused = false
	is_game_active = false
	ui_manager = get_parent().get_node("UIManager")
	
	if ui_manager != null and ui_manager.has_method("hide_warp_timer"):
		ui_manager.hide_warp_timer()
		
	await get_tree().create_timer(0.1).timeout
	start_act_1()

func _process(delta: float) -> void:
	if ui_manager == null or not is_game_active: 
		return
	
	match current_phase:
		Phase.ACT_1_TUTORIAL:
			process_act_1(delta)
		Phase.ACT_2_SURVIVAL:
			process_act_2(delta)
		Phase.ACT_3_BOSS:
			process_act_3(delta)

func start_act_1() -> void:
	current_phase = Phase.ACT_1_TUTORIAL
	Global.can_detonate = false
	var grid = get_tree().get_first_node_in_group("grid_manager")
	var spawner = get_tree().get_first_node_in_group("spawner")
	
	if grid != null:
		grid.pause_decay() 
		grid.punch_holes(tutorial_holes_amount) 
		
	if spawner != null:
		spawner.pause_spawning() 
		spawner.spawn_specific_amount(tutorial_enemy_amount) 
	
	if not Global.is_tutorial_done:
		mulai_monolog_tutorial()
	if bgm_act_1 != null:
		AudioManager.play_bgm(bgm_act_1)
	is_game_active = true

func process_act_1(_delta: float) -> void:
	var enemies_left = get_tree().get_nodes_in_group("enemy").size()
	var holes_left = check_remaining_holes()
	if ui_manager != null and ui_manager.has_method("update_objective"):
		ui_manager.update_objective("BABAK 1: Habisi %d Musuh & Tambal %d Lubang!" % [enemies_left, holes_left])
	if enemies_left <= 0 and holes_left <= 0:
		start_act_2()

func check_remaining_holes() -> int:
	var grid = get_tree().get_first_node_in_group("grid_manager")
	var arena = get_tree().get_first_node_in_group("arena")
	
	if grid != null and arena != null:
		var holes_count = 0
		var all_cells = arena.get_used_cells()
		
		for cell in all_cells:
			if arena.get_cell_atlas_coords(cell) == grid.hole_tile_coords:
				holes_count += 1
				
		return holes_count
	return 999

func start_act_2() -> void:
	current_phase = Phase.ACT_2_SURVIVAL
	current_timer = survival_duration	
	Global.can_detonate = true
	
	var grid = get_tree().get_first_node_in_group("grid_manager")
	var spawner = get_tree().get_first_node_in_group("spawner")
	
	if grid != null: grid.resume_decay() 
	if spawner != null: spawner.resume_spawning() 
	
	if ui_manager.has_method("show_warp_timer"):
		ui_manager.show_warp_timer()
	if ui_manager != null and ui_manager.has_method("update_objective"):
		ui_manager.update_objective("BABAK 2: Bertahan Hidup Hingga Waktu Teleportasi Habis!")

	munculkan_dialog([
			"Pilot|Kerja Bagus Kapten! Mesin belakang sudah beres, kita akan mulai teleportasi dalam 2 menit!",
			"Kapten|Bagus! Lakukan teleportasi sekarang!",
			"Pilot|T-Tunggu Kapten! Sensor mendeteksi gelombang anomali lagi! MEREKA DATANG LEBIH BANYAK!!",
			"Pilot|Kapten Teleportasi Akan siap dalam 2 menit, tolong bertahan hingga kita dapat berteleportasi!",
			"Pilot|Saya akan Memberikan Akses Untuk Meledakkan Time Anchor anda, Tolong tetap hidup kapten!",
			"Kapten|Baiklah, aku akan bertahan hidup!"
		])


func process_act_2(delta: float) -> void:
	current_timer -= delta
	if ui_manager.has_method("update_warp_timer"):
		ui_manager.update_warp_timer(current_timer)
		
	if current_timer <= 30.0 and not dialog_30s_played:
		dialog_30s_played = true
		munculkan_dialog(["Pilot|30 Detik sebelum warping! Tahan posisi Kapten!"])
		
	if current_timer <= 10.0 and not dialog_10s_played:
		dialog_10s_played = true
		AudioManager.stop_bgm()
		AudioManager.play_bgm(bgm_act_3)
		munculkan_dialog(["Pilot|Gawat! Radar mendeteksi fluktuasi energi ruang angkasa yang aneh tepat di belakang kapal!"])
	
	if current_timer <= 0:
		start_act_3()

func start_act_3() -> void:
	current_phase = Phase.ACT_3_BOSS
	current_timer = warp_duration
	AudioManager.play_bgm(bgm_act_3)
	if black_hole_visual != null:
		black_hole_visual.show()
	var player = get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("set_blackhole_active"):
		player.set_blackhole_active(true)
	var canvas_ambient = get_node_or_null("../CanvasModulate") 
	if canvas_ambient != null:
		canvas_ambient.color = Color(0.15, 0.05, 0.25)
	munculkan_dialog([
		"Pilot|KAPTEN!! Sebuah Black Hole terbuka persis di belakang kita!",
		"Pilot|Ada entitas kosmik mengerikan muncul dari dalamnya!",
		"Pilot|Tentakel-tentakel hitam itu menahan laju kapal! Hancurkan semua tentakelnya pakai ledakan Anchor sebelum kita tersedot ke dalam Void!!"
	])
	spawn_tentacles()

func process_act_3(delta: float) -> void:
	current_timer -= delta
	if ui_manager.has_method("update_warp_timer"):
		ui_manager.update_warp_timer(current_timer)
		
	if black_hole_visual != null and black_hole_visual.has_method("set_hole_scale"):
		var progress = (warp_duration - current_timer) / warp_duration
		progress = clamp(progress, 0.0, 1.0)
		var current_scale = lerp(2.0, 6.0, progress)
		black_hole_visual.set_hole_scale(current_scale)
		
	if ui_manager != null and ui_manager.has_method("update_objective"):
		if tentacles_left > 0:
			ui_manager.update_objective("BABAK FINAL: Hancurkan %d Tentakel Kosmik!" % tentacles_left)
		else:
			ui_manager.update_objective("BABAK FINAL: Bertahan Hingga Teleportasi Selesai!")
	
	var player = get_tree().get_first_node_in_group("player")
	if player != null and "blackhole_pull" in player:
		#Makin kecil current_timer, nilainya makin gede. Max pull bisa sampai 140
		player.blackhole_pull = 20.0 + (60.0 - current_timer) * 2.0
		
	if current_timer <= 0:
		if tentacles_left <= 0:
			trigger_you_win()
		else:
			trigger_game_over_warp_failed()

func trigger_game_over_warp_failed() -> void:
	set_process(false)
	if ui_manager != null and ui_manager.has_method("hide_hud"):
		ui_manager.hide_hud()
	munculkan_dialog([
		"Pilot|KAPTEN! Waktu habis! Integritas lambung 0%! Mesin warp mati!",
		"System|CRITICAL ERROR. HULL BREACH DETECTED. WELCOME TO THE VOID."
		])
		
	if ui_manager.has_method("show_game_over"):
		ui_manager.show_game_over()
		set_process(false) 
		if ui_manager != null and ui_manager.has_method("hide_hud"):
			ui_manager.hide_hud()

func trigger_you_win() -> void:
	set_process(false)
	munculkan_dialog([
		"Pilot|Luar biasa Kapten! Semua cengkeraman entitas kosmik itu sudah hancur!",
		"Kapten|Jalur sudah bersih! Tarik tuasnya sekarang!!",
		"Pilot|Warping in 3... 2... 1... KITA BERHASIL LOLOS!"
	])
	if ui_manager.has_method("show_win"): 
		ui_manager.show_win()

func spawn_tentacles() -> void:
	var arena = get_tree().get_first_node_in_group("arena")
	if arena == null:
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
			

func tentacle_destroyed() -> void:
	tentacles_left -= 1
	if tentacles_left <= 0:
		if ui_manager != null and ui_manager.has_method("show_survival_objective"):
			ui_manager.show_survival_objective()
		

func munculkan_dialog(teks_array: Array, kembalikan_hud: bool = true) -> void:
	if dialog_scene != null:
		var dialog_instance = dialog_scene.instantiate()
		dialog_instance.dialog_queue = teks_array
		get_parent().add_child.call_deferred(dialog_instance)
		
		if ui_manager != null and ui_manager.has_method("hide_hud"):
			ui_manager.hide_hud()
			
		if kembalikan_hud:
			dialog_instance.tree_exited.connect(func():
				if ui_manager != null and ui_manager.has_method("show_hud"):
					ui_manager.show_hud()
			)

func mulai_monolog_tutorial() -> void:
	munculkan_dialog([
		"Kapten|Sialan! Lambung kapal mulai runtuh ditarik anomali waktu!",
		"Kapten|Aku harus bergerak pakai (W, A, S, D) dan pakai energi buat Dash (Double Tap).",
		"Kapten|Kalau ada lantai berlubang, aku bisa menambalnya dengan Time Anchor (Klik Kiri)...",
		"Kapten|Tapi hati-hati, Anchor itu bakal meledak! Aku harus bertahan hidup!"
	])
	Global.is_tutorial_done = true
