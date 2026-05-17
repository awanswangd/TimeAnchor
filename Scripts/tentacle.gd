extends StaticBody2D

func _ready() -> void:
	add_to_group("enemy") 
	
func die() -> void:
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm != null and gm.has_method("tentacle_destroyed"):
		gm.tentacle_destroyed()
		
	print("Satu Tentakel Kosmik Hancur!")
	queue_free() 
