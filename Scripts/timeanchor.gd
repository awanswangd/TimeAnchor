extends StaticBody2D

@export var radius: int = 2 
@export var floor_id: int = 0 
var is_player_inside: bool = false
var tile_size: float = 64.0 
@onready var aura_visual: Sprite2D = $AuraArea/AuraVisual

func _ready() -> void:
	setup_aura_visual_size()
	restore_surrounding_tiles()

func _process(delta: float) -> void:
	if is_player_inside and Input.is_action_just_pressed("detonate"):
		detonate()

func _on_aura_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_inside = true
	if body.has_method("apply_time_warp"):
		body.apply_time_warp(true)

func _on_aura_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_inside = false
	if body.has_method("apply_time_warp"):
		body.apply_time_warp(false)

func setup_aura_visual_size() -> void:
	if aura_visual == null or aura_visual.texture == null:
		return
	var safe_diameter_in_pixels = (radius * 2 + 1) * tile_size
	var original_texture_size = aura_visual.texture.get_size().x
	var required_scale = safe_diameter_in_pixels / original_texture_size
	aura_visual.scale = Vector2(required_scale, required_scale)

func detonate() -> void:
	print("BOOM! Time Anchor Meledak!")
	var ui = get_tree().get_first_node_in_group("ui_manager")
	if ui != null and ui.has_method("add_detonation"):
		ui.add_detonation()
	var area = $AuraArea 
	if area == null: return
	var overlapping_bodies = area.get_overlapping_bodies()
	print("Benda yang kena ledakan: ", overlapping_bodies)
	for body in overlapping_bodies:
		if body.is_in_group("enemy") and body.has_method("die"):
			print("Musuh ini punya fungsi die, bunuh!")
			body.die() # Musuh mati (dan ngedrop bensin lagi!)
		else:
				print("ERROR: Musuh ini GA PUNYA fungsi die!")
	queue_free()

func restore_surrounding_tiles() -> void:
	var tilemap = get_tree().get_first_node_in_group("arena")
	if tilemap == null:
		print("ERROR: Tilemap tidak ditemukan! Pastikan TileMapLayer sudah masuk grup 'arena'.")
		return
	var local_pos = tilemap.to_local(global_position)
	var center_grid_pos = tilemap.local_to_map(local_pos)
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			var target_cell = center_grid_pos + Vector2i(x, y)
			var current_id = tilemap.get_cell_source_id(target_cell)
			if current_id == -1:
				tilemap.set_cell(target_cell, floor_id, Vector2i(0, 0))
				
				# (Kamu bisa menambahkan animasi atau partikel di sini nanti)
