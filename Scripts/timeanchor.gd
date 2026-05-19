extends StaticBody2D

@export var radius: int = 2 
@export var floor_id: int = 0 
@export var floor_atlas_coords: Vector2i = Vector2i(0, 0) 
var is_player_inside: bool = false
var tile_size: float = 64.0 
@onready var aura_visual: Sprite2D = $AuraArea/AuraVisual
@export var sfx_explosion_suspense: AudioStream
@export var sfx_explosion: AudioStream

func _ready() -> void:
	setup_aura_visual_size()
	restore_surrounding_tiles()

func _process(delta: float) -> void:
	if is_player_inside and Input.is_action_just_pressed("detonate"):
		if not Global.can_detonate:
			return
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
	AudioManager.play_sfx(sfx_explosion_suspense, true)
	await get_tree().create_timer(1.0).timeout
	AudioManager.play_sfx(sfx_explosion, true)
	var cam = get_tree().get_first_node_in_group("camera")
	if cam != null and cam.has_method("apply_shake"):
		cam.apply_shake(15.0)
		
	var ui = get_tree().get_first_node_in_group("ui_manager")
	if ui != null and ui.has_method("add_detonation"):
		ui.add_detonation()
		
	var area = $AuraArea 
	if area == null: return
	
	var overlapping_bodies = area.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.is_in_group("enemy") and body.has_method("die"):
			body.die() 
		area.monitoring = false 
	if aura_visual != null:
		aura_visual.hide()
	$Sprite2D.hide() 
	var particles = get_node_or_null("ExplosionParticles")
	if particles != null:
		particles.emitting = true
	await get_tree().create_timer(1.0).timeout
	queue_free()

func restore_surrounding_tiles() -> void:
	var tilemap = get_tree().get_first_node_in_group("arena")
	var grid_manager = get_tree().get_first_node_in_group("grid_manager") 
	
	if tilemap == null or grid_manager == null:
		return
		
	var local_pos = tilemap.to_local(global_position)
	var center_grid_pos = tilemap.local_to_map(local_pos)
	
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			var target_cell = center_grid_pos + Vector2i(x, y)
			var current_id = tilemap.get_cell_source_id(target_cell)
			
			if current_id == -1:
				# Tanyakan gambar aslinya ke GridManager
				var original_coords = grid_manager.get_original_floor_coords(target_cell)
				
				# Jika jawabannya bukan Vector2i(-1, -1), berarti area itu dulunya lantai
				if original_coords != Vector2i(-1, -1):
					# Kembalikan lantai menggunakan gambar spesifiknya!
					tilemap.set_cell(target_cell, floor_id, original_coords)
