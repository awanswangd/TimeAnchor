extends Node

@export var arena_tilemap: TileMapLayer
@export var decay_speed: float = 0.5 

var decay_timer: Timer

var initial_floor_blueprint: Dictionary = {}

func _ready() -> void:
	add_to_group("grid_manager")
	
	if arena_tilemap != null:
		var all_cells = arena_tilemap.get_used_cells()
		
		for cell in all_cells:
			initial_floor_blueprint[cell] = arena_tilemap.get_cell_atlas_coords(cell)
			
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
		# Cek apakah kotak ini belum hancur menjadi void (-1)
		if arena_tilemap.get_cell_source_id(cell) != -1:
			active_floors.append(cell)
			
	if active_floors.size() > 0:
		# Cara baru Godot 4 yang lebih rapi untuk memilih acak
		var target_cell = active_floors.pick_random() 
		arena_tilemap.set_cell(target_cell, -1)

# --- FUNGSI BARU UNTUK TIME ANCHOR ---
# Fungsi ini tidak lagi sekadar menjawab "True/False", tapi langsung 
# mengembalikan gambar persis lantai tersebut sebelum hancur.
func get_original_floor_coords(grid_pos: Vector2i) -> Vector2i:
	if initial_floor_blueprint.has(grid_pos):
		return initial_floor_blueprint[grid_pos]
	return Vector2i(-1, -1) # Tanda khusus kalau ini di luar arena/bukan lantai
	
# --- FUNGSI TAMBAHAN UNTUK GAME MANAGER ---

func pause_decay() -> void:
	if decay_timer != null:
		decay_timer.stop() # Hentikan timer penghancur lantai

func resume_decay() -> void:
	if decay_timer != null:
		decay_timer.start() # Lanjutkan timer penghancur lantai

func get_total_blueprint_size() -> int:
	# Mengembalikan total jumlah kotak lantai asli
	return initial_floor_blueprint.size()

func punch_holes(amount: int) -> void:
	# Hancurkan lantai secara instan sebanyak 'amount'
	for i in range(amount):
		destroy_random_floor()
