extends Node

@export var arena_tilemap: TileMapLayer
@export var decay_speed: float = 0.5 
@export var hole_tile_coords: Vector2i = Vector2i(7, 1)

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
		if arena_tilemap.get_cell_atlas_coords(cell) != hole_tile_coords:
			active_floors.append(cell)
			
	if active_floors.size() > 0:
		var target_cell = active_floors.pick_random() 
		arena_tilemap.set_cell(target_cell, 0, hole_tile_coords)

func get_original_floor_coords(grid_pos: Vector2i) -> Vector2i:
	if initial_floor_blueprint.has(grid_pos):
		return initial_floor_blueprint[grid_pos]
	return Vector2i(-1, -1) 
	
func pause_decay() -> void:
	if decay_timer != null:
		decay_timer.stop() 

func resume_decay() -> void:
	if decay_timer != null:
		decay_timer.start()

func get_total_blueprint_size() -> int:
	return initial_floor_blueprint.size()

func punch_holes(amount: int) -> void:
	for i in range(amount):
		destroy_random_floor()
