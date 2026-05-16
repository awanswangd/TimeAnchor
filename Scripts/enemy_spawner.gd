extends Node2D

# Ganti "res://TimeWarper.tscn" dengan path file musuhmu yang sebenarnya.
# Klik kanan file musuh di panel FileSystem -> "Copy Path" -> Paste di dalam tanda kutip.
var enemy_scene = preload("res://Scene/TimeWarper.tscn")

@export var spawn_radius: float = 600.0 
@export var spawn_interval: float = 1.5 

var player: Node2D
var spawn_timer: Timer

func _ready() -> void:
	# Memastikan node player bisa ditemukan
	player = get_tree().get_first_node_in_group("player")
	
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(spawn_enemy)
	add_child(spawn_timer)

func spawn_enemy() -> void:
	if player == null or enemy_scene == null:
		return
		
	var enemy = enemy_scene.instantiate()
	
	# Logika lingkaran spawn di luar jangkauan kamera
	var random_angle = randf() * TAU 
	var spawn_direction = Vector2.RIGHT.rotated(random_angle)
	var spawn_position = player.global_position + (spawn_direction * spawn_radius)
	
	enemy.global_position = spawn_position
	add_child(enemy)
