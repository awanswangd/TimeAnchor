extends Camera2D

@export var default_strength: float = 30.0 # Kekuatan getaran standar
@export var shake_fade: float = 5.0 #Seberapa cepat getarannya mereda

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0

func _ready() -> void:
	add_to_group("camera")

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = move_toward(shake_strength, 0, shake_fade * delta)
		offset = Vector2(
			rng.randf_range(-shake_strength, shake_strength),
			rng.randf_range(-shake_strength, shake_strength)
		)
	else:
		offset = Vector2.ZERO

func apply_shake(strength: float = default_strength) -> void:
	shake_strength = strength
