extends Node

@export var arena_tilemap: TileMapLayer
@export var decay_speed: float = 0.5 
@export var floor_atlas_coords: Vector2i = Vector2i(0, 0) 

var decay_timer: Timer
var initial_floor_blueprint: Dictionary = {}

func _ready() -> void:
	add_to_group("grid_manager")
	
	if arena_tilemap != null:
		var all_cells = arena_tilemap.get_used_cells()
		
		for cell in all_cells:
			var cell_coords = arena_tilemap.get_cell_atlas_coords(cell)
			
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
		if arena_tilemap.get_cell_atlas_coords(cell) == floor_atlas_coords:
			active_floors.append(cell)
			
	if active_floors.size() > 0:
		var random_index = randi() % active_floors.size()
		var target_cell = active_floors[random_index]
		arena_tilemap.set_cell(target_cell, -1) 

func is_original_floor(grid_pos: Vector2i) -> bool:
	return initial_floor_blueprint.has(grid_pos)
