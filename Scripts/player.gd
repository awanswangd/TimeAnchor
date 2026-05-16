extends CharacterBody2D

@export var speed: float = 200.0
@export var max_health: int = 100
@export var starting_energy: int = 5
@export var anchor_cost: int = 1
@export var time_anchor_scene: PackedScene 
@export var arena_tilemap: TileMapLayer
var void_damage_timer: float = 0.0
var void_damage_interval: float = 0.5
var sprint_tick_timer: float = 0.0
var current_health: int
var current_energy: int
@export var dash_speed_multiplier: float = 3.5 # Seberapa cepat melesat saat dash
@export var dash_duration: float = 0.2 # Lama dash berlangsung (sangat singkat)
@export var dash_cooldown_time: float = 2.5 # Jeda antar dash
@export var dash_energy_cost: int = 1 # Biaya bensin untuk 1x dash
var is_dashing: bool = false
var dash_direction: Vector2 = Vector2.ZERO
var dash_timer: float = 0.0
var current_cooldown: float = 0.0
var last_key_pressed: String = ""
var double_tap_timer: float = 0.0
var double_tap_window: float = 0.25 # Waktu maksimal untuk tap kedua

signal health_changed(new_health)
signal energy_changed(new_energy)
signal anchor_placed(position)
signal player_died
var energy_drop_scene = preload("res://Scene/EnergyDrop.tscn")

func _ready() -> void:
	# Inisialisasi status awal
	add_to_group("player") 
	current_health = max_health
	current_energy = starting_energy
	
	# Pancarkan signal awal agar UI bisa melakukan render angka yang tepat
	health_changed.emit(current_health)
	energy_changed.emit(current_energy)

func _physics_process(delta: float) -> void:
	check_double_tap(delta) # Cek input dash dulu
	handle_movement(delta)
	if not is_dashing:
		check_void_damage(delta) # Cek void hanya saat tidak sedang dash

func _unhandled_input(event: InputEvent) -> void:
	# Mendengarkan tombol yang ditekan (Spasi / Klik yang sudah diset di Input Map)
	if event.is_action_pressed("place_anchor"):
		try_place_anchor()

func handle_movement(delta: float) -> void:
	if is_dashing:
		dash_timer -= delta
		velocity = dash_direction * (speed * dash_speed_multiplier)
		move_and_slide()
		
		# Deteksi tabrak mati
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider != null and collider.is_in_group("enemy"):
				print("DASH-KILL SUCCESS!")
				if collider != null and collider.is_in_group("enemy"):
					print("DASH-KILL SUCCESS!")
					if collider.has_method("die"):
						collider.die()
		if dash_timer <= 0:
			is_dashing = false 
			
	else:
		var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var current_speed = speed 
		
		if Input.is_action_pressed("sprint") and current_energy > 0 and input_dir != Vector2.ZERO:
			# Player pakai SHIFT
			current_speed = speed * 1.6 # Dibuat sedikit lebih lambat dari Dash biar terasa bedanya
			sprint_tick_timer += delta
			
			if sprint_tick_timer >= 0.2:
				sprint_tick_timer = 0.0
				current_energy -= 1
				energy_changed.emit(current_energy) 
		else:
			sprint_tick_timer = 0.0 
			
		velocity = input_dir * current_speed
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
				# Ketukan pertama
				last_key_pressed = action
				double_tap_timer = double_tap_window

func start_dash() -> void:
	is_dashing = true
	dash_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Jaga-jaga kalau input vector entah kenapa 0
	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2.RIGHT 
		
	dash_timer = dash_duration
	current_cooldown = dash_cooldown_time
	
	current_energy -= dash_energy_cost
	energy_changed.emit(current_energy)

func try_place_anchor() -> void:
	print("Mencoba menanam Anchor...")
	
	# Cek Tersangka 1: Apakah Scene Anchor sudah dimasukkan?
	if time_anchor_scene == null:
		print("GAGAL: time_anchor_scene masih KOSONG di Inspector Player!")
		return
		
	# Cek Tersangka 2: Apakah energi cukup?
	if current_energy < anchor_cost:
		print("GAGAL: Energi habis! Sisa energi: ", current_energy)
		return
		
	print("SUKSES: Syarat terpenuhi, Anchor muncul!")
	
	current_energy -= anchor_cost
	energy_changed.emit(current_energy)
	
	var anchor = time_anchor_scene.instantiate()
	anchor.global_position = global_position
	get_tree().current_scene.add_child(anchor)
	anchor_placed.emit(global_position)
		

func take_damage(amount: int) -> void:
	current_health -= amount
	health_changed.emit(current_health)
	
	# Efek visual sederhana saat terkena damage (opsional)
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

func check_void_damage(delta: float) -> void:
	if arena_tilemap == null:
		return
		
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
