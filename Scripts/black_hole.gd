extends Node2D

@onready var ring: Sprite2D = $Ring

func _process(delta: float) -> void:
	if ring != null:
		ring.rotation += delta * 0.5 

func set_hole_scale(new_scale: float) -> void:
	scale = Vector2(new_scale, new_scale)
