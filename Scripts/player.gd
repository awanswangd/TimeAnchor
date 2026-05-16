extends CharacterBody2D

# --- Variabel Konfigurasi ---
@export var speed: float = 200.0
@export var max_health: int = 100
@export var starting_energy: int = 5
@export var anchor_cost: int = 1

# Drag-and-drop file TimeAnchor.tscn dari panel FileSystem ke inspector Player
@export var time_anchor_scene: PackedScene 
@export var arena_tilemap: TileMapLayer
var void_damage_timer: float = 0.0
var void_damage_interval: float = 0.5

# --- Variabel Status ---
var current_health: int
var current_energy: int

# --- Signals (Untuk komunikasi dengan UI atau Game Manager) ---
signal health_changed(new_health)
signal energy_changed(new_energy)
signal anchor_placed(position)

func _ready() -> void:
	# Inisialisasi status awal
	current_health = max_health
	current_energy = starting_energy
	
	# Pancarkan signal awal agar UI bisa melakukan render angka yang tepat
	health_changed.emit(current_health)
	energy_changed.emit(current_energy)

func _physics_process(delta: float) -> void:
	handle_movement()
	check_void_damage(delta) # Panggil fungsi baru ini

func _unhandled_input(event: InputEvent) -> void:
	# Mendengarkan tombol yang ditekan (Spasi / Klik yang sudah diset di Input Map)
	if event.is_action_pressed("place_anchor"):
		try_place_anchor()

func handle_movement() -> void:
	# Input.get_vector otomatis menormalkan pergerakan diagonal
	# Menggunakan mapping bawaan Godot (W, A, S, D atau Panah)
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	velocity = input_dir * speed
	
	# Fungsi bawaan Godot 4 untuk kalkulasi fisika dan tabrakan
	move_and_slide()

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
	# Logika hancur/kalah
	queue_free()

func check_void_damage(delta: float) -> void:
	# 1. CEK ERROR: Apakah TileMap sudah masuk?
	if arena_tilemap == null:
		print("ERROR: arena_tilemap masih KOSONG! Tarik node TileMapLayer ke Inspector Player.")
		return
		
	void_damage_timer += delta
	
	if void_damage_timer >= void_damage_interval:
		void_damage_timer = 0.0
		
		var local_pos = arena_tilemap.to_local(global_position)
		var grid_pos = arena_tilemap.local_to_map(local_pos)
		var floor_id = arena_tilemap.get_cell_source_id(grid_pos)
		
		# 2. RADAR DEBUG: Print setiap 0.5 detik untuk melihat karakter menginjak apa
		print("Kordinat Kotak: ", grid_pos, " | ID Lantai: ", floor_id)
		
		if floor_id == -1:
			take_damage(10)
			print("Terinjak Void! Sisa HP: ", current_health)
