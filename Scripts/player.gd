extends CharacterBody2D

#SIGNALS & PRELOADS
signal health_changed(new_health: int)
signal energy_changed(new_energy: int)
signal anchor_placed(position: Vector2)
signal player_died

var energy_drop_scene = preload("res://Scene/EnergyDrop.tscn")

#REFERENCES
@export_category("References")
@export var time_anchor_scene: PackedScene 
@export var arena_tilemap: TileMapLayer
@export var blackhole_pull: float = 50.0

#PLAYER STATS
@export_category("Player Stats")
@export var max_health: int = 100
@export var starting_energy: int = 100
@export var speed: float = 200.0

var current_health: int
var current_energy: int
var sprint_tick_timer: float = 0.0
var is_blackhole_active: bool = false
var is_invincible: bool = false 

#DASH SYSTEM
@export_group("Dash Settings")
@export var dash_speed_multiplier: float = 3.5 
@export var dash_duration: float = 0.2 
@export var dash_cooldown_time: float = 2.5 
@export var dash_energy_cost: int = 1 

var is_dashing: bool = false
var dash_direction: Vector2 = Vector2.ZERO
var dash_timer: float = 0.0
var current_cooldown: float = 0.0
var double_tap_window: float = 0.25
var double_tap_timer: float = 0.0
var last_key_pressed: String = ""

#TIME ANCHOR
@export_group("Anchor Settings")
@export var anchor_cost: int = 1
@export var anchor_cooldown_time: float = 3.0 
var anchor_current_cooldown: float = 0.0 

#REGEN SETTINGS (SISTEM HAFIZ)
@export_group("Regen Settings")
@export var regen_rate: float = 1.0 # Darah yang nambah per detik
@export var regen_delay: float = 2.0 # Tunggu 2 detik setelah dipukul buat regen
var time_since_last_hit: float = 0.0
var hp_float: float = 100.0

#ENVIRONMENT (VOID DAMAGE)
var void_damage_interval: float = 0.5
var void_damage_timer: float = 0.0

func _ready() -> void:
	add_to_group("player") 
	current_health = max_health
	current_energy = starting_energy
	hp_float = float(max_health) # Inisialisasi regen
	
	var hb = get_tree().get_first_node_in_group("health_bar")
	if hb != null and hb.has_method("init_health"):
		hb.call_deferred("init_health", max_health)
	
	var eb = get_tree().get_first_node_in_group("energy_bar")
	if eb != null and eb.has_method("init_energy"):
		eb.call_deferred("init_energy", starting_energy)
	
	health_changed.emit(current_health)
	energy_changed.emit(current_energy)

func _physics_process(delta: float) -> void:
	if anchor_current_cooldown > 0:
		anchor_current_cooldown -= delta
	check_double_tap(delta)
	handle_movement(delta)
	
	if not is_dashing:
		check_void_damage(delta)
		
	# --- SISTEM AUTO REGEN HAFIZ ---
	time_since_last_hit += delta
	if time_since_last_hit >= regen_delay and current_health < max_health:
		hp_float += regen_rate * delta
		var new_health = int(hp_float)
		
		if new_health > current_health:
			current_health = new_health
			if current_health > max_health:
				current_health = max_health
				
			health_changed.emit(current_health)
			var hb = get_tree().get_first_node_in_group("health_bar")
			if hb != null:
				hb.set_deferred("health", current_health)
	# --------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("place_anchor"):
		try_place_anchor()

func handle_movement(delta: float) -> void:
	if is_dashing:
		dash_timer -= delta
		velocity = dash_direction * (speed * dash_speed_multiplier)
		move_and_slide()
		
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider != null and collider.is_in_group("enemy"):
				if collider.is_in_group("boss"):
					continue
				if collider.has_method("die"):
					collider.die()
		if dash_timer <= 0:
			is_dashing = false 
			
	else:
		var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var current_speed = speed 
		
		if Input.is_action_pressed("sprint") and current_energy > 0 and input_dir != Vector2.ZERO:
			current_speed = speed * 1.6 
			sprint_tick_timer += delta
			
			if sprint_tick_timer >= 0.2:
				sprint_tick_timer = 0.0
				current_energy -= 1
				energy_changed.emit(current_energy) 
		else:
			sprint_tick_timer = 0.0 
			
		velocity = input_dir * current_speed
		if is_blackhole_active:
			velocity.y -= blackhole_pull
		move_and_slide()

func check_double_tap(delta: float) -> void:
	if current_cooldown > 0:
		current_cooldown -= delta
		
	if double_tap_timer > 0:
		double_tap_timer -= delta
	else:
		last_key_pressed = "" 
		
	var actions = ["ui_left", "ui_right", "ui_up", "ui_down"]
	
	for action in actions:
		if Input.is_action_just_pressed(action):
			if last_key_pressed == action and double_tap_timer > 0:
				if current_cooldown <= 0 and current_energy >= dash_energy_cost:
					start_dash()
					last_key_pressed = "" 
					return
			else:
				last_key_pressed = action
				double_tap_timer = double_tap_window

func start_dash() -> void:
	is_dashing = true
	dash_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2.RIGHT 
	
	dash_timer = dash_duration
	current_cooldown = dash_cooldown_time
	
	var skill_ui = get_tree().get_first_node_in_group("skill_ui")
	if skill_ui != null and skill_ui.has_method("start_dash_cooldown"):
		skill_ui.start_dash_cooldown()
	
	current_energy -= dash_energy_cost
	energy_changed.emit(current_energy)
	var eb = get_tree().get_first_node_in_group("energy_bar")
	if eb != null:
		eb.set_deferred("energy", current_energy)
		
	# --- MEKANIK I-FRAME 0,3 DETIK ---
	is_invincible = true
	await get_tree().create_timer(0.3).timeout
	is_invincible = false
	# ---------------------------------

func try_place_anchor() -> void:
	if anchor_current_cooldown > 0: return
	if time_anchor_scene == null: return
	if current_energy < anchor_cost: return
		
	current_energy -= anchor_cost
	anchor_current_cooldown = anchor_cooldown_time
	energy_changed.emit(current_energy)
	var eb = get_tree().get_first_node_in_group("energy_bar")
	if eb != null:
		eb.set_deferred("energy", current_energy)
		
	var cam = get_tree().get_first_node_in_group("camera")
	if cam != null and cam.has_method("apply_shake"):
		cam.apply_shake(4.5)
		
	var anchor = time_anchor_scene.instantiate()
	anchor.global_position = global_position
	get_tree().current_scene.add_child(anchor)
	anchor_placed.emit(global_position)
	
	var skill_ui = get_tree().get_first_node_in_group("skill_ui")
	if skill_ui != null and skill_ui.has_method("start_anchor_cooldown"):
		skill_ui.start_anchor_cooldown()

func take_damage(amount: int) -> void:
	# --- CEK I-FRAME SEBELUM NGURANGIN DARAH ---
	if is_invincible:
		return
	# -------------------------------------------
		
	if current_health <= 0:
		return
		
	current_health -= amount
	health_changed.emit(current_health)
	
	# --- RESET TIMER REGEN & SINKRONISASI ---
	time_since_last_hit = 0.0
	hp_float = float(current_health)
	# ----------------------------------------
	
	var cam = get_tree().get_first_node_in_group("camera")
	if cam != null and cam.has_method("apply_shake"):
		cam.apply_shake(3.5)
	var hb = get_tree().get_first_node_in_group("health_bar")
	if hb != null:
		hb.set_deferred("health", current_health)

	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if current_health <= 0:
		die()

func die() -> void:
	player_died.emit()
	hide() 
	set_physics_process(false)
	set_process_unhandled_input(false)
	var ui = get_tree().get_first_node_in_group("ui_manager")
	if ui != null and ui.has_method("show_game_over"):
		ui.show_game_over()

func check_void_damage(delta: float) -> void:
	if arena_tilemap == null: return
		
	void_damage_timer += delta
	
	if void_damage_timer >= void_damage_interval:
		void_damage_timer = 0.0
		
		var local_pos = arena_tilemap.to_local(global_position)
		var grid_pos = arena_tilemap.local_to_map(local_pos)
		var floor_id = arena_tilemap.get_cell_source_id(grid_pos)
		
		if floor_id == -1: 
			if current_energy > 0:
				current_energy -= 1 
				energy_changed.emit(current_energy)
			else:
				take_damage(10) 

func set_blackhole_active(active: bool) -> void:
	is_blackhole_active = active
