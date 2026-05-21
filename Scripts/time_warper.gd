extends CharacterBody2D

@export var base_speed: float = 120.0
@export var slow_speed: float = 40.0 
@export var damage: int = 10
@export var attack_cooldown: float = 1.5
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var current_speed: float
var player: Node2D
var can_move: bool = true
var energy_drop_scene = preload("res://Scene/EnergyDrop.tscn")

func _ready() -> void:
	add_to_group("enemy") 
	current_speed = base_speed
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player == null:
		return
	if not can_move:
		anim.stop() 
		return
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * current_speed
	move_and_slide()
	update_animation(direction)
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider != null and collider.is_in_group("player"):
			if collider.has_method("take_damage"):
				collider.take_damage(damage)
				start_attack_cooldown()

func update_animation(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		anim.play("walk_side")
		anim.flip_h = dir.x > 0
	else:
		anim.flip_h = false 
		if dir.y > 0:
			anim.play("walk_front") 
		else:
			anim.play("walk_back") 

func apply_time_warp(is_slowed: bool) -> void:
	if is_slowed:
		current_speed = slow_speed
		modulate = Color.BLUE 
	else:
		current_speed = base_speed
		modulate = Color.WHITE

func start_attack_cooldown() -> void:
	can_move = false 
	await get_tree().create_timer(attack_cooldown).timeout
	can_move = true

func die() -> void:
	if energy_drop_scene != null:
		var drop = energy_drop_scene.instantiate()
		drop.global_position = global_position
		get_parent().add_child(drop)
	queue_free()
