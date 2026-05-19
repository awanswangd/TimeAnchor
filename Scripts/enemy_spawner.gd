extends Node2D

var enemy_scene = preload("res://Scene/TimeWarper.tscn")

@export var spawn_radius: float = 600.0 
@export var spawn_interval: float = 1.5 

var player: Node2D
var spawn_timer: Timer

func _ready() -> void:
	add_to_group("spawner") # Tambahin ke grup biar gampang dicari GameManager
	player = get_tree().get_first_node_in_group("player")
	
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	# autostart dibikin false juga, nunggu disuruh GameManager
	spawn_timer.autostart = false 
	spawn_timer.timeout.connect(spawn_enemy)
	add_child(spawn_timer)

# --- FUNGSI KONTROL DARI GAME MANAGER ---
func pause_spawning() -> void:
	spawn_timer.stop()

func resume_spawning() -> void:
	spawn_timer.start()

func spawn_specific_amount(amount: int) -> void:
	for i in range(amount):
		spawn_enemy()
# ----------------------------------------

func spawn_enemy() -> void:
	if player == null or enemy_scene == null: return
		
	var enemy = enemy_scene.instantiate()
	var random_angle = randf() * TAU 
	var spawn_direction = Vector2.RIGHT.rotated(random_angle)
	var spawn_position = player.global_position + (spawn_direction * spawn_radius)
	
	var arena = get_tree().get_first_node_in_group("arena")
	if arena != null:
		var used_rect = arena.get_used_rect()
		var tile_size = 64.0 
		var padding = 2.0 
		var batas_kiri = (used_rect.position.x + padding) * tile_size
		var batas_kanan = (used_rect.end.x - padding) * tile_size
		var batas_atas = (used_rect.position.y + padding) * tile_size
		var batas_bawah = (used_rect.end.y - padding) * tile_size
		spawn_position.x = clamp(spawn_position.x, batas_kiri, batas_kanan)
		spawn_position.y = clamp(spawn_position.y, batas_atas, batas_bawah)

	enemy.global_position = spawn_position
	get_parent().add_child(enemy)
