extends Node

@export var arena_tilemap: TileMapLayer
@export var decay_speed: float = 0.5 

# Masukkan koordinat atlas lantai Anda dari Langkah 1 (ganti jika bukan 0,0)
@export var floor_atlas_coords: Vector2i = Vector2i(0, 0) 

var decay_timer: Timer
var initial_floor_blueprint: Dictionary = {}

func _ready() -> void:
	# Daftarkan node ini ke grup secara otomatis lewat kode agar anti-lupa
	add_to_group("grid_manager")
	
	if arena_tilemap != null:
		# Ambil semua kotak yang digambar di dalam TileMap
		var all_cells = arena_tilemap.get_used_cells()
		
		for cell in all_cells:
			var cell_coords = arena_tilemap.get_cell_atlas_coords(cell)
			
			# HANYA catat ubin yang koordinat atlasnya cocok dengan lantai
			if cell_coords == floor_atlas_coords:
				initial_floor_blueprint[cell] = true
				
	decay_timer = Timer.new()
	decay_timer.wait_time = decay_speed
	decay_timer.autostart = true
	decay_timer.timeout.connect(destroy_random_floor)
	add_child(decay_timer)

func destroy_random_floor() -> void:
	if arena_tilemap == null:
		return
		
	var active_floors = []
	
	for cell in initial_floor_blueprint.keys():
		# Jika kotak tersebut saat ini masih berupa lantai utuh
		if arena_tilemap.get_cell_atlas_coords(cell) == floor_atlas_coords:
			active_floors.append(cell)
			
	if active_floors.size() > 0:
		var random_index = randi() % active_floors.size()
		var target_cell = active_floors[random_index]
		arena_tilemap.set_cell(target_cell, -1) # Ubah jadi Void (-1)

# Fungsi validasi untuk Time Anchor
func is_original_floor(grid_pos: Vector2i) -> bool:
	return initial_floor_blueprint.has(grid_pos)
