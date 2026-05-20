extends StaticBody2D
var tentacle_hp: int = 3

func _ready() -> void:
	add_to_group("enemy") 
	add_to_group("boss")

func die() -> void:
	tentacle_hp -= 1
	
	modulate = Color.PURPLE
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if tentacle_hp <= 0:
		var gm = get_tree().get_first_node_in_group("game_manager")
		if gm != null and gm.has_method("tentacle_destroyed"):
			gm.tentacle_destroyed()
		queue_free()
