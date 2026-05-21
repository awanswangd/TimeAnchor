extends StaticBody2D
var tentacle_hp: int = 3

func _ready() -> void:
	add_to_group("enemy") 
	add_to_group("boss")

func die() -> void:
	tentacle_hp -= 1
	modulate = Color.RED 
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	modulate = Color.PURPLE
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	var gm = get_tree().get_first_node_in_group("game_manager")
	if tentacle_hp > 0:
		if gm != null and gm.has_method("tentacle_hit"):
			gm.tentacle_hit()
	if tentacle_hp <= 0:
		if gm != null and gm.has_method("tentacle_destroyed"):
			gm.tentacle_destroyed()
		queue_free()
